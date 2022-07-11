module "vpc" {
  source  = "../../"

  context = var.context

  cidr = "172.38.0.0/16"

  enable_nat_gateway = true
  # single_nat_gateway = true # 1 ea
  # one_nat_gateway_per_az = true # 2 ea
  one_nat_gateway_per_az = false # max(subnet_length)


  azs             = ["apne2-az2", "apne2-az4"]
  public_subnets  = ["172.38.1.0/24", "172.38.2.0/24"]
  public_subnet_names  = ["pub-b1", "pub-d1"]
  public_subnet_suffix = "pub"

  # private_subnets = [ "172.38.10.0/24", "172.38.11.0/24" ]

  intra_subnets = [ "172.38.10.0/24", "172.38.11.0/24" ]
  intra_subnet_names = [ "app-a1","app-c1", ]
  intra_subnet_suffix = "app"

  create_database_subnet_route_table = true
  database_subnets =  [ "172.38.40.0/24", "172.38.41.0/24" ]
  database_subnet_names = [ "data-a1", "data-c1"]
  database_subnet_suffix = "data"
  # database_subnet_tags = {}

  # backend subnet 하고만 액세스 가능하도록 NACL 설정
  database_dedicated_network_acl = true
  database_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "172.38.10.0/24"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "172.38.11.0/24"
    }
  ]

}


