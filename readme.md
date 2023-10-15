# Overview

This example repository provides the infrastructure and deployment configuration for an ethereum
execution and consensus client. Additionally, it offers monitoring via prometheus and grafana.
All the mentioned software is running on AWS in an EKS cluster with ARM (Graviton) nodes.

# Setup

## Prerequisites

### Tools

This repository was created with the following tools and their corresponding releases.
In order to successfully deploy the infrastructure, the software below needs to be installed on your local machine:

* [terraform](https://github.com/hashicorp/terraform) (`>= 1.6.1`)
  * [terraform aws provider](https://github.com/hashicorp/terraform-provider-aws) (`>= 5.21.0`)
  * [terraform http provider](https://github.com/hashicorp/terraform-provider-http) (`>= 3.4.0`)
* [helm](https://github.com/helm/helm) (`>= 3.13.1`)
* [helmfile](https://github.com/helmfile/helmfile) (`>= 0.157.0`)
  * [helmfile diff plugin](https://github.com/databus23/helm-diff) (`>= 3.8.1`)
* [kubectl](https://github.com/kubernetes/kubectl) (`>= 1.27.2`)
* docker (`>= 24.0.5`, just make sure you have a working `buildx` configuration)
* [aws-cli](https://github.com/aws/aws-cli/tree/v2) (`>= 2.7.33`)
* (optional) [aws-vault](https://github.com/99designs/aws-vault) (`>= 7.2.0`)

### AWS Region

This repository assumes the AWS `eu-central-1` region for all resources created.
If this does not suit your requirements you can replace all occurrences in this repo with your desired region.

## Terraform

### Overview

Everything related to terraform is in the `terraform/` directory. It is split into
the `components/` and the `modules/` folder. Each of those directories contain the different units for deployment:

* `components`:
  * `networking`: Contains the VPC, private and public subnets, plus additionally NAT gateways (one per AZ)
  * `ecr`: Contains simple ECR repositories for the created docker images in the later sections
  * `eks`: Contains configuration for creating an EKS cluster with different worker groups (`system` and `nodes` (blockchain nodes))
* `modules`:
  * `subnet`: Module for deploying a single subnet
  * `natgw`: Module for deploying a single NAT gateway

For the sake of this simple example repository, most of KMS related settings have been omitted.
In a production environment encryption on EBS/ECR and other services should be activated.

Also, the state is currently only stored locally into each component. In a shared developer setting a
remote state like S3 or terraform cloud is required.

### Deployment

The terraform components need to be run in a specific order, because some components depend on others.
The order of the deployment units is the following:

* `networking` (apply time approx: 2-3 minutes)
* `ecr` (apply time approx: 30 seconds)
* `eks` (apply time approx: 15+ minutes)

Before going into each component make sure you have valid credentials for the AWS account you want to deploy the infrastructure into.
`aws-vault` is a great tool for setting up valid credentials before running any terraform/aws commands.

To apply a component run the following:

```hcl
cd terraform/components/<component>
terraform init
terraform apply
```

**IMPORTANT: Currently the `networking` component creates a VPC with the IP CIDR of `10.5.0.0/16`.
Please make sure you do not have any overlapping VPC in the account you will provision the stack into.**

After all the components have been applied, you should have a running EKS cluster with:

* 3 system nodes (for prometheus, grafana, go-monitor)
* 3 worker nodes (for blockchain daemons)

## Docker images

### Overview

Each of the custom deployments we are going to run, requires a docker image to run.
These images are:

* `geth`: Execution client, can be found under `docker/geth/Dockerfile`
* `prsym`: Consensus client, can be found under `docker/prsym/Dockerfile`
* `go-monitor`: Custom go tool, that will output the connected peers of the execution client. Can be found under `go-monitor/build/Dockerfile`

### Deployment

Make sure you copy the `.env.example` from the root directory into `.env` and adjust the `AWS_ACCOUNT_ID` value accordingly to your account.

After this you can run the following script from the root directory:

```shell
./scripts/build-images.sh
```

This will log into ECR, create the before mentioned docker images and push them into ECR.

## Prometheus & Grafana

### Overview

For this simple example we are going to use the helm chart of both grafana
and prometheus. 

### Deployment

Make sure you have valid AWS credentials, so you can run the following command to set the newly 
created cluster as the current kube context:

```shell
aws eks update-kubeconfig --name ethereum-nodes-example
```

You can verify the connection with:

```shell
kubectl get nodes
```

which should show 6 running nodes.

Now you can navigate into `kubernetes/tools` and run the following command:

```shell
helmfile apply
```

This will download the helm repos (prometheus & grafana) and apply them into your cluster.

#### Connect to grafana

You can get the current grafana password with this command:

```shell
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

After this you can port forward it to your local machine with:

```shell
kubectl port-forward -n grafana service/grafana 3000:80
```

and navigate to your favourite browser, where you can login with `admin` and the password from before.

#### Setup prometheus data source

Navigate to http://localhost:3000/connections/datasources/new and create a new prometheus data source.
For the prometheus server url you have to specify:

```text
http://prometheus-server.prometheus.svc.cluster.local
```

You can leave the other inputs untouched and just click on save.

#### Importing dashboards

In the `kubernetes/miscellaneous/grafana/` folder you will find 2 dashboards for prysm and geth. 
You can import those with the grafana UI under: http://localhost:3000/dashboard/import 

## Execution & Consensus client & go-monitor

### Overview

Both geth and prysm will run in a statefulset with a dedicated persistent volume for each pod (3 execution and consensus clients per default).
They are communicating via rpc and jwt auth. The statefulsets are deployed in public subnets,
so they can communicate via p2p with the other peers. The go-monitor tool will connect to the execution client
and output the connected peers every interval (15 seconds per default).

### Deployment

First you need to generate a new jwt auth secret for the communication between your ethereum daemons.
For this you can run the following command:

```shell
openssl rand -hex 32 | tr -d "\n"
```

Take the output from the command and set it in `kubernetes/ethereum/secrets.yaml` in both `SETME` fields.

After this is set, **make sure you have a valid connection to your kubernetes cluster**, so you can run the following command:

```shell
./scripts/deploy-kubernetes.sh
```

This will create the following kubernetes objects:

* custom storage class for cryptocurrency nodes (gp3 + higher iops)
* namespaces for geth/prysm/go-monitor
* secrets for geth/prysm
* configmap for go-monitor
* service for geth/prysm
* statefulset for geth/prysm
* deployment for go-monitor

If everything was successful you can check the logs of geth/prysm/go-monitor with:

```shell
kubectl logs -f -n geth statefulsets/geth
kubectl logs -f -n prysm statefulsets/prysm
kubectl logs -f -n go-monitor deployments/monitor
```

## Cleanup

To remove all the created components just run `terraform destroy` in the reverse order of the creation. **Also make sure
to remove all created volumes in AWS, because the retention policy in kubernetes is enabled for the blockchain storage.**