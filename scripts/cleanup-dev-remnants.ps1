$ErrorActionPreference = 'Stop'

$aws = 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'
$region = 'us-east-1'
$vpcId = 'vpc-0dd514773c0f4aadb'
$dbId = 'react-js-application-dev-mysql'
$dbSubnetGroup = 'react-js-application-dev-db-subnet-group'
$igwId = 'igw-0dacc0ddae61d69ec'

Write-Output 'Deleting RDS instance...'
& $aws rds modify-db-instance --region $region --db-instance-identifier $dbId --no-deletion-protection --apply-immediately --no-cli-pager | Out-Null
& $aws rds wait db-instance-available --region $region --db-instance-identifier $dbId --no-cli-pager
& $aws rds delete-db-instance --region $region --db-instance-identifier $dbId --skip-final-snapshot --delete-automated-backups --no-cli-pager | Out-Null
& $aws rds wait db-instance-deleted --region $region --db-instance-identifier $dbId --no-cli-pager

Write-Output 'Deleting DB subnet group...'
& $aws rds delete-db-subnet-group --region $region --db-subnet-group-name $dbSubnetGroup --no-cli-pager

Write-Output 'Deleting non-default security groups...'
$securityGroups = & $aws ec2 describe-security-groups --region $region --filters Name=vpc-id,Values=$vpcId --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text
foreach ($groupId in ($securityGroups -split '\s+' | Where-Object { $_ })) {
  & $aws ec2 delete-security-group --region $region --group-id $groupId --no-cli-pager 2>$null
}

Write-Output 'Detaching and deleting internet gateway...'
& $aws ec2 detach-internet-gateway --region $region --internet-gateway-id $igwId --vpc-id $vpcId --no-cli-pager 2>$null
& $aws ec2 delete-internet-gateway --region $region --internet-gateway-id $igwId --no-cli-pager 2>$null

Write-Output 'Deleting non-main route tables...'
$routeTables = & $aws ec2 describe-route-tables --region $region --filters Name=vpc-id,Values=$vpcId --query 'RouteTables[?Associations[?Main!=`true`]].RouteTableId' --output text
foreach ($routeTableId in ($routeTables -split '\s+' | Where-Object { $_ })) {
  $assocIds = & $aws ec2 describe-route-tables --region $region --route-table-ids $routeTableId --query 'RouteTables[0].Associations[?Main!=`true`].RouteTableAssociationId' --output text
  foreach ($assocId in ($assocIds -split '\s+' | Where-Object { $_ })) {
    & $aws ec2 disassociate-route-table --region $region --association-id $assocId --no-cli-pager 2>$null
  }
  & $aws ec2 delete-route-table --region $region --route-table-id $routeTableId --no-cli-pager 2>$null
}

Write-Output 'Deleting subnets...'
$subnets = & $aws ec2 describe-subnets --region $region --filters Name=vpc-id,Values=$vpcId --query 'Subnets[].SubnetId' --output text
foreach ($subnetId in ($subnets -split '\s+' | Where-Object { $_ })) {
  & $aws ec2 delete-subnet --region $region --subnet-id $subnetId --no-cli-pager 2>$null
}

Write-Output 'Deleting VPC...'
& $aws ec2 delete-vpc --region $region --vpc-id $vpcId --no-cli-pager

Write-Output 'Dev remnant cleanup complete.'