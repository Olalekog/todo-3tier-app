$ErrorActionPreference = 'Stop'

Write-Output 'Terminating legacy SonarQube instance...'
aws ec2 terminate-instances --region us-east-1 --instance-ids i-05f35d9022b60cd23 --no-cli-pager --output json | Out-Null
aws ec2 wait instance-terminated --region us-east-1 --instance-ids i-05f35d9022b60cd23 --no-cli-pager

Write-Output 'Removing IAM profile and role...'
aws iam remove-role-from-instance-profile --instance-profile-name react-js-application-dev-sonarqube-instance-profile --role-name react-js-application-dev-sonarqube-ec2-role --no-cli-pager 2>$null
aws iam delete-instance-profile --instance-profile-name react-js-application-dev-sonarqube-instance-profile --no-cli-pager 2>$null
aws iam detach-role-policy --role-name react-js-application-dev-sonarqube-ec2-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore --no-cli-pager 2>$null
aws iam delete-role --role-name react-js-application-dev-sonarqube-ec2-role --no-cli-pager 2>$null

Write-Output 'Deleting security group...'
aws ec2 delete-security-group --region us-east-1 --group-id sg-076e8a8541425558b --no-cli-pager 2>$null

Write-Output 'Removing public route table and associations...'
aws ec2 disassociate-route-table --region us-east-1 --association-id rtbassoc-035932b4ca6eae335 --no-cli-pager 2>$null
aws ec2 disassociate-route-table --region us-east-1 --association-id rtbassoc-04e0c03a9a4e8ba9f --no-cli-pager 2>$null
aws ec2 delete-route-table --region us-east-1 --route-table-id rtb-0c930c6a95a0f65f1 --no-cli-pager 2>$null

Write-Output 'Detaching and deleting internet gateway...'
aws ec2 detach-internet-gateway --region us-east-1 --internet-gateway-id igw-0e396466791a4d58b --vpc-id vpc-0bd7d3c654f1358a2 --no-cli-pager 2>$null
aws ec2 delete-internet-gateway --region us-east-1 --internet-gateway-id igw-0e396466791a4d58b --no-cli-pager 2>$null

Write-Output 'Deleting subnets...'
aws ec2 delete-subnet --region us-east-1 --subnet-id subnet-010bdbe01f8408640 --no-cli-pager 2>$null
aws ec2 delete-subnet --region us-east-1 --subnet-id subnet-0293b7dff1b47c456 --no-cli-pager 2>$null
aws ec2 delete-subnet --region us-east-1 --subnet-id subnet-0e2b9cbd69713d14b --no-cli-pager 2>$null
aws ec2 delete-subnet --region us-east-1 --subnet-id subnet-081b119b2a685ee1c --no-cli-pager 2>$null

Write-Output 'Deleting legacy VPC...'
aws ec2 delete-vpc --region us-east-1 --vpc-id vpc-0bd7d3c654f1358a2 --no-cli-pager 2>$null

Write-Output 'Removing legacy remote state object...'
aws s3 rm s3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate --only-show-errors

Write-Output 'Legacy SonarQube cleanup complete.'
