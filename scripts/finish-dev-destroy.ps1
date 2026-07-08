$ErrorActionPreference = 'Stop'
$aws = 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'
$tf = 'C:\Users\Olalekan Ogundare\AppData\Local\Microsoft\WinGet\Links\terraform.exe'
$bucket = 'react-js-application-terraform-state-866934333672'
$devStateKey = 'react-js-application/dev/terraform.tfstate'
$statePath = 'C:\Users\Olalekan Ogundare\AppData\Local\Temp\dev-state.json'

& $aws s3 cp "s3://$bucket/$devStateKey" $statePath --only-show-errors | Out-Null
$state = Get-Content $statePath -Raw | ConvertFrom-Json
$dbResource = $state.resources | Where-Object { $_.module -eq 'module.database' -and $_.type -eq 'aws_db_instance' -and $_.name -eq 'this' }
if (-not $dbResource) { throw 'Could not find database resource in dev state.' }
$dbPassword = $dbResource.instances[0].attributes.password
if ([string]::IsNullOrWhiteSpace($dbPassword)) { throw 'Database password missing from state.' }

Set-Location 'C:\Users\Olalekan Ogundare\Learning\Project\AWS\todo-3tier-app\terraform'
& $tf init -input=false -reconfigure -backend-config="bucket=$bucket" -backend-config="key=$devStateKey" -backend-config="region=us-east-1" -backend-config="encrypt=true"
& $tf destroy -auto-approve -input=false -no-color -var-file environments/dev.tfvars -var "db_password=$dbPassword"
