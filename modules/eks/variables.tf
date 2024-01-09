variable "vpc_id" {
  description = "The VPC ID where the cluster and workers will be deployed."
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs to launch resources in."
  type        = list(string)
}