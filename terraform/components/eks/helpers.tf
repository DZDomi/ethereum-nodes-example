locals {
  my_ip = format("%s/32", data.http.my_ip.response_body)
}