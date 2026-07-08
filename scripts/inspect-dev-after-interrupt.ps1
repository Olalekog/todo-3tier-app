$ErrorActionPreference = 'Stop'
$aws = 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'
Write-Output 'VPC'
& $aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Name,Values=react-js-application-dev-vpc --query 'Vpcs[].{VpcId:VpcId,State:State}' --output table
Write-Output 'IGW'
& $aws ec2 describe-internet-gateways --region us-east-1 --filters Name=attachment.vpc-id,Values=vpc-0dd514773c0f4aadb --query 'InternetGateways[].InternetGatewayId' --output text
Write-Output 'Instances'
& $aws ec2 describe-instances --region us-east-1 --filters Name=tag:Project,Values=react-js-application Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,State:State.Name,VpcId:VpcId}' --output table
Write-Output 'RDS'
& $aws rds describe-db-instances --region us-east-1 --query 'DBInstances[?contains(DBInstanceIdentifier, `react-js-application`) == `true`].[DBInstanceIdentifier,DBInstanceStatus]' --output table
