$ErrorActionPreference = 'Stop'

$repoRoot = 'C:\Users\Olalekan Ogundare\Learning\Project\AWS\todo-3tier-app'
$terraformDir = Join-Path $repoRoot 'terraform'
$tf = 'C:\Users\Olalekan Ogundare\AppData\Local\Microsoft\WinGet\Links\terraform.exe'
$aws = 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'
$gh = 'gh'
$bucket = 'react-js-application-terraform-state-866934333672'
$devStateKey = 'react-js-application/dev/terraform.tfstate'
$tempState = 'C:\Users\Olalekan Ogundare\AppData\Local\Temp\dev-state.json'

Write-Output 'Downloading current dev state...'
& $aws s3 cp "s3://$bucket/$devStateKey" $tempState --only-show-errors | Out-Null
$state = Get-Content $tempState -Raw | ConvertFrom-Json
$dbResource = $state.resources | Where-Object { $_.module -eq 'module.database' -and $_.type -eq 'aws_db_instance' -and $_.name -eq 'this' }
if (-not $dbResource) {
  throw 'Could not find module.database.aws_db_instance.this in dev state.'
}
$dbPassword = $dbResource.instances[0].attributes.password
if ([string]::IsNullOrWhiteSpace($dbPassword)) {
  throw 'Database password was not found in dev state.'
}

Set-Location $terraformDir

Write-Output 'Initializing Terraform for dev state...'
& $tf init -input=false -reconfigure `
  -backend-config="bucket=$bucket" `
  -backend-config="key=$devStateKey" `
  -backend-config="region=us-east-1" `
  -backend-config="encrypt=true"

Write-Output 'Destroying dev infrastructure...'
& $tf destroy -auto-approve -input=false -no-color `
  -var-file environments/dev.tfvars `
  -var "db_password=$dbPassword"

Write-Output 'Dispatching base infrastructure recreate workflow...'
& $gh workflow run deploy.yml -f environment=dev -f action=apply -f workload=infra
$infraRun = & $gh run list --workflow deploy.yml --limit 1 --json databaseId --jq '.[0].databaseId'
if (-not $infraRun) {
  throw 'Could not resolve deploy workflow run id.'
}
Write-Output ("Watching deploy workflow run {0}..." -f $infraRun)
& $gh run watch $infraRun --exit-status

Write-Output 'Dispatching app image rebuild and deploy workflow...'
& $gh workflow run docker-build-push.yml -f environment=dev -f workload=app
$appRun = & $gh run list --workflow docker-build-push.yml --limit 1 --json databaseId --jq '.[0].databaseId'
if (-not $appRun) {
  throw 'Could not resolve docker build workflow run id.'
}
Write-Output ("Watching docker/app workflow run {0}..." -f $appRun)
& $gh run watch $appRun --exit-status

Write-Output 'Re-initializing Terraform for shared dev state...'
& $tf init -input=false -reconfigure `
  -backend-config="bucket=$bucket" `
  -backend-config="key=$devStateKey" `
  -backend-config="region=us-east-1" `
  -backend-config="encrypt=true"

Write-Output 'Applying SonarQube into shared dev VPC/state...'
& $tf apply -auto-approve -input=false -no-color `
  -var-file environments/dev.tfvars `
  -var-file security-tools/deploy/sonarqube.tfvars `
  -var "db_password=$dbPassword" `
  -target=module.security_integration

$frontendUrl = & $tf output -raw frontend_url
$sonarqubeUrl = & $tf output -raw sonarqube_url

Write-Output ("frontend_url={0}" -f $frontendUrl)
Write-Output ("sonarqube_url={0}" -f $sonarqubeUrl)

try {
  $frontendResponse = Invoke-WebRequest -Uri $frontendUrl -TimeoutSec 20 -UseBasicParsing
  Write-Output ("frontend_status={0}" -f $frontendResponse.StatusCode)
} catch {
  Write-Output ("frontend_status=unreachable:{0}" -f $_.Exception.Message)
}

try {
  $sonarqubeResponse = Invoke-WebRequest -Uri $sonarqubeUrl -TimeoutSec 20 -UseBasicParsing
  Write-Output ("sonarqube_status={0}" -f $sonarqubeResponse.StatusCode)
} catch {
  Write-Output ("sonarqube_status=unreachable:{0}" -f $_.Exception.Message)
}
