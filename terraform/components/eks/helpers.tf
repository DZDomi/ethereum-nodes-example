locals {
  my_ip = format("%s/32", replace(data.http.my_ip.response_body, "\n", ""))
}