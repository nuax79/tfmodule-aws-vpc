module "vpc" {
  source = "../../"

  context = var.context

  cidr = "172.30.0.0/16"

  azs             = ["apne2-az1", "apne2-az2"]
  public_subnets  = ["172.30.1.0/24", "172.30.2.0/24"]
  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnet_suffix = "pub"

  intra_subnets = [ "172.30.10.0/24", "172.30.11.0/24" ]
  intra_subnet_names = [ "app-a1","app-b1", ]
  # intra_subnet_suffix = ""

}


