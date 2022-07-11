module "vpc" {
  source = "../../"

  context = var.context
  cidr = "172.70.0.0/16"

  azs             = ["apne2-az1", "apne2-az3"]

  public_subnets  = ["172.70.1.0/24", "172.70.2.0/24"]
  public_subnet_names  = ["pub-a1", "pub-c1"]
  public_subnet_suffix = "pub"

  private_subnets = [ "172.70.50.0/24", "172.70.51.0/24" ]
  private_subnet_names = [ "toolchain-a1","toolchain-c1" ]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = true

  intra_subnets = [
    "172.70.10.0/24", "172.70.11.0/24",
    "172.70.20.0/24", "172.70.21.0/24",
    "172.70.30.0/24", "172.70.31.0/24",
    "172.70.40.0/24", "172.70.41.0/24"
    ]

  intra_subnet_names = [
    "edge-a1","edge-c1",
    "mgmt-a1","mgmt-c1",
    "front-a1","front-c1",
    "back-a1","back-c1"
  ]

  create_database_subnet_route_table = true
  database_subnets =  [ "172.70.70.0/24", "172.70.71.0/24" ]
  database_subnet_names = [ "rds-a1", "rds-c1"]
  database_subnet_suffix = "rds"
  # database_subnet_tags = {}

}


