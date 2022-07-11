# terraform-aws-vpc
hasicorp terraform-aws-vpc 모듈의 name 및 tagging policy를 세밀하게 조정 하도록 보완하는 프로젝트


# AWS VPC Terraform module

Terraform module which creates VPC resources on AWS.

아래의 AWS 자원들에 대해 프로비저닝을 지원 합니다.:

* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [Network ACL](https://www.terraform.io/docs/providers/aws/r/network_acl.html)
* [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [VPN Gateway](https://www.terraform.io/docs/providers/aws/r/vpn_gateway.html)
* [VPC Flow Log](https://www.terraform.io/docs/providers/aws/r/flow_log.html)
* [VPC Endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html):
    * Gateway: S3, DynamoDB
    * Interface: S3, EC2, SSM, EC2 Messages, SSM Messages, SQS, ECR API, ECR DKR, API Gateway, KMS,
      ECS, ECS Agent, ECS Telemetry, SES, SNS, STS, Glue, CloudWatch(Monitoring, Logs, Events),
      Elastic Load Balancing, CloudTrail, Secrets Manager, Config, Codeartifact(API, Repositories), CodeBuild, CodeCommit,
      Git-Codecommit, Textract, Transfer Server, Kinesis Streams, Kinesis Firehose, SageMaker(Notebook, Runtime, API),
      CloudFormation, CodePipeline, Storage Gateway, AppMesh, Transfer, Service Catalog, AppStream API, AppStream Streaming,
      Athena, Rekognition, Elastic File System (EFS), Cloud Directory, Elastic Beanstalk (+ Health), Elastic Map Reduce(EMR),
      DataSync, EBS, SMS, Elastic Inference Runtime, QLDB Session, Step Functions, Access Analyzer, Auto Scaling Plans,
      Application Auto Scaling, Workspaces, ACM PCA, RDS, CodeDeploy, CodeDeploy Commands Secure, DMS

* [RDS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
* [DHCP Options Set](https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html)
* [Default VPC](https://www.terraform.io/docs/providers/aws/r/default_vpc.html)
* [Default Network ACL](https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)


## VPC 프로비저닝 샘플

### Simple VPC 구성
기본적인 VPC 구성으로 vpc, igw, nat, public subnet, private subnet 이 구성 됩니다.

public subnet 엔 internet gateway 가 바인딩 되고, private subnet 엔 nat gateway 가 바인딩 됩니다.

[simple-vpc](./examples/simple-vpc/main.tf)


### Interanet VPC 구성
VPC 구성 중 NAT gateway 가 제외된, igw, public subnet, intra subnet 이 구성 됩니다.

public subnet 엔 internet gateway 가 바인딩 됩니다.

[intra-vpc](./examples/intra-vpc/main.tf)


### Completed VPC 구성
권장하는 VPC 구성으로 vpc, igw, nat, public subnet, private subnet, intra subent, database subnet이 구성 됩니다.

public subnet 엔 internet gateway 가 바인딩 되고, private subnet 엔 nat gateway 가 바인딩 됩니다.

[completed-vpc](./examples/completed-vpc/main.tf)


## NAT Gateway 정의 

* private 서브넷 전체를 통틀어 1개의 NAT Gateway를 구성 
    * `enable_nat_gateway = true`
    * `single_nat_gateway = true`
    * `one_nat_gateway_per_az = false`

* private 서브넷에 각각 1개의 NAT Gateway를 구성 
    * `enable_nat_gateway = true`
    * `single_nat_gateway = false`
    * `one_nat_gateway_per_az = false`

* availability zone 별 1개의 NAT Gateway를 구성
      * `enable_nat_gateway = true`
    * `single_nat_gateway = false`
    * `one_nat_gateway_per_az = true`

If both `single_nat_gateway` and `one_nat_gateway_per_az` are set to `true`, then `single_nat_gateway` takes precedence.

### One NAT Gateway per subnet (default)

By default, the module will determine the number of NAT Gateways to create based on the the `max()` of the private subnet lists (`database_subnets`, `elasticache_subnets`, `private_subnets`, and `redshift_subnets`). The module **does not** take into account the number of `intra_subnets`, since the latter are designed to have no Internet access via NAT Gateway.  For example, if your configuration looks like the following:

```hcl
database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
elasticache_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
redshift_subnets    = ["10.0.41.0/24", "10.0.42.0/24"]
intra_subnets       = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
```
 

## Public access to RDS instances

Sometimes it is handy to have public access to RDS instances (it is not recommended for production) by specifying these arguments:

```hcl
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true
```

## Network Access Control Lists (ACL or NACL)

This module can manage network ACL and rules. Once VPC is created, AWS creates the default network ACL, which can be controlled using this module (`manage_default_network_acl = true`).

Also, each type of subnet may have its own network ACL with custom rules per subnet. Eg, set `public_dedicated_network_acl = true` to use dedicated network ACL for the public subnets; set values of `public_inbound_acl_rules` and `public_outbound_acl_rules` to specify all the NACL rules you need to have on public subnets (see `variables.tf` for default values and structures).

By default, all subnets are associated with the default network ACL.

## Public access to Redshift cluster

Sometimes it is handy to have public access to Redshift clusters (for example if you need to access it by Kinesis - VPC endpoint for Kinesis is not yet supported by Redshift) by specifying these arguments:

```hcl
  enable_public_redshift = true  # <= By default Redshift subnets will be associated with the private route table
```

## Transit Gateway (TGW) integration

It is possible to integrate this VPC module with [terraform-aws-transit-gateway module](https://github.com/terraform-aws-modules/terraform-aws-transit-gateway) which handles the creation of TGW resources and VPC attachments. See [complete example there](https://github.com/terraform-aws-modules/terraform-aws-transit-gateway/tree/master/examples/complete).

## Examples

* [Simple VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple-vpc)
* [Simple VPC with secondary CIDR blocks](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/secondary-cidr-blocks)
* [Complete VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/complete-vpc)
* [Network ACL](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/network-acls)
* [VPC Flow Logs](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/vpc-flow-logs)
* [Manage Default VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/manage-default-vpc)
* Few tests and edge cases examples: [#46](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-46-no-private-subnets), [#44](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-44-asymmetric-private-subnets), [#108](https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/issue-108-route-already-exists)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.21 |
| aws | >= 2.70 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.70 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_customer_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) |
| [aws_db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) |
| [aws_default_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) |
| [aws_default_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) |
| [aws_default_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) |
| [aws_default_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) |
| [aws_egress_only_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) |
| [aws_elasticache_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) |
| [aws_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) |
| [aws_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) |
| [aws_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) |
| [aws_redshift_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_subnet_group) |
| [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| [aws_vpc_dhcp_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) |
| [aws_vpc_dhcp_options_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) |
| [aws_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) |
| [aws_vpc_endpoint_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) |
| [aws_vpc_endpoint_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) |
| [aws_vpc_ipv4_cidr_block_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) |
| [aws_vpn_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) |
| [aws_vpn_gateway_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) |
| [aws_vpn_gateway_route_propagation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) |

## Inputs

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Default</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>region</td>
        <td>AWS 리전 약어를 입력 합니다.</td>
        <td>string</td>
        <td>an2</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>env</td>
        <td>develop, stage, production 과 같은 런-타임 환경 약어를 입력 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>team</td>
        <td>클라우드 관리 주체인 팀 이름을 입력 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>owner</td>
        <td>프로젝트 Owner를 입력합니다. 이메일, 어카운트 또는 관리 부서가 될 수 있습니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>create_vpc</td>
        <td>프로비저닝을 통해 정의된 VPC를 생성 합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
    <tr>
        <td>name</td>
        <td>VPC 대표 이름을 설정 합니다. 대게 서비스명 또는 프로젝트명이 올 수 있습니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>cidr</td>
        <td>VPC 네트워크의 CIDR 네트워크 대역값을 설정합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>azs</td>
        <td>availability zones 이름 또는 ID를 입력합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>public_subnets</td>
        <td>public subnet을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>public_subnet_names</td>
        <td>public subnet 이름을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>public_subnet_suffix</td>
        <td>public subnet 대표 이름을 정의 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>private_subnets</td>
        <td>private subnet을 정의 합니다. 특히 NAT를 위한 라우팅 테이블은 private subnet 을 기준으로 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>private_subnet_names</td>
        <td>private subnet 이름을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>private_subnet_suffix</td>
        <td>private subnet 대표 이름을 정의 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>enable_nat_gateway</td>
        <td>private subnet 에 대해 NAT GW를 생성하는 경우 true 로 설정 합니다. private_subnet 에 대한 설정이 필요 합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>single_nat_gateway</td>
        <td>하나의 NAT 게이트웨이만 생성 합니다. (한개의 NAT Gateway 로 모든 private subnet의 액세스를 지원 합니다.)</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>one_nat_gateway_per_az</td>
        <td>availability zone 갯수만큼 NAT 게이트웨이를 생성 합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_subnets</td>
        <td>database subnet을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_subnet_names</td>
        <td>database subnet 이름을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_subnet_suffix</td>
        <td>database subnet 대표 이름을 정의 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>create_database_subnet_route_table</td>
        <td>데이터베이스에 대한 별도의 라우팅 테이블을 생성해야하는지 여부를 정의합니다. (DBMS 패치를 인터넷으로부터 직접 패치하는 경우 설정 할 수 있음)</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>create_database_nat_gateway_route</td>
        <td>데이터베이스 서브넷 전용 NAT Gateway를 생성 여부를 정의합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>

</tbody>
</table>
 
