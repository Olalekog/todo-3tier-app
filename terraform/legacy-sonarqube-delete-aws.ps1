$ErrorActionPreference = 'Stop'
$statePath = 'C:\Users\Olalekan Ogundare\AppData\Local\Temp\sonarqube-old-state.json'
aws s3 cp 's3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate' $statePath --only-show-errors | Out-Null
$state = Get-Content $statePath -Raw | ConvertFrom-Json

$instanceId = $null
$sgId = $null
$vpcId = $null
$publicSubnets = @()
$privateSubnets = @()
$iamProfile = $null
$iamRole = $null

foreach ($resource in $state.resources) {
  foreach ($instance in $resource.instances) {
    $attrs = $instance.attributes
    switch ("$($resource.type).$($resource.name)") {
      'aws_instance.this' { $instanceId = $attrs.id }
      'aws_security_group.sonarqube' { $sgId = $attrs.id }
      'aws_vpc.main' { $vpcId = $attrs.id }
      'aws_subnet.public' { if ($attrs.id) { $publicSubnets += $attrs.id } }
      'aws_subnet.private_app' { if ($attrs.id) { $privateSubnets += $attrs.id } }
      'aws_iam_instance_profile.this' { $iamProfile = $attrs.name }
      'aws_iam_role.this' { $iamRole = $attrs.name }
    }
  }
}

if ($instanceId) {
  aws ec2 terminate-instances --region us-east-1 --instance-ids $instanceId --output json | Out-Null
  aws ec2 wait instance-terminated --region us-east-1 --instance-ids $instanceId
}

if ($iamProfile -and $iamRole) {
  aws iam remove-role-from-instance-profile --instance-profile-name $iamProfile --role-name $iamRole 2>$null
  aws iam delete-instance-profile --instance-profile-name $iamProfile 2>$null
}

if ($iamRole) {
  aws iam detach-role-policy --role-name $iamRole --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore 2>$null
  aws iam delete-role --role-name $iamRole 2>$null
}

if ($sgId) {
  aws ec2 delete-security-group --region us-east-1 --group-id $sgId 2>$null
}

foreach ($subnetId in ($privateSubnets + $publicSubnets)) {
  aws ec2 delete-subnet --region us-east-1 --subnet-id $subnetId 2>$null
}

if ($vpcId) {
  aws ec2 delete-vpc --region us-east-1 --vpc-id $vpcId 2>$null
}

aws s3 rm 's3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate' --only-show-errors
Write-Output 'Legacy SonarQube standalone AWS resources and state removed.'
