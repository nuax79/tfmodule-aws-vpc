module "vpc" {
  source = "../../"

  context = var.context
  cidr = "172.20.0.0/16"

  azs             = ["apne2-az1", "apne2-az3"]
  public_subnets  = ["172.20.1.0/24", "172.20.2.0/24"]
  public_subnet_names  = ["pub-a1", "pub-c1"]
  public_subnet_suffix = "pub"

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = true

  private_subnets = [
    "172.20.10.0/24", "172.20.11.0/24",/*
    "172.20.20.0/24", "172.20.21.0/24",
    "172.20.30.0/24", "172.20.31.0/24",
    "172.20.40.0/24", "172.20.41.0/24" */
    ]

  private_subnet_names = [
    "edge-a1","edge-c1",/*
    "mgmt-a1","mgmt-c1",
    "front-a1","front-c1",
    "back-a1","back-c1" */
  ]

}


