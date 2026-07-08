$ErrorActionPreference = 'Continue'
Write-Output 'Instance state:'
aws ec2 describe-instances --region us-east-1 --instance-ids i-05f35d9022b60cd23 --no-cli-pager --query 'Reservations[].Instances[].State.Name' --output text 2>$null
Write-Output 'VPC:'
aws ec2 describe-vpcs --region us-east-1 --vpc-ids vpc-0bd7d3c654f1358a2 --no-cli-pager --query 'Vpcs[].VpcId' --output text 2>$null
Write-Output 'IGW attachments:'
aws ec2 describe-internet-gateways --region us-east-1 --internet-gateway-ids igw-0e396466791a4d58b --no-cli-pager --query 'InternetGateways[].Attachments[].VpcId' --output text 2>$null
Write-Output 'State object:'
aws s3api head-object --bucket react-js-application-terraform-state-866934333672 --key react-js-application/sonarqube/terraform.tfstate --no-cli-pager 2>$null
