$ErrorActionPreference = 'Stop'
$gh = 'gh'
$tf = 'C:\Users\Olalekan Ogundare\AppData\Local\Microsoft\WinGet\Links\terraform.exe'
$bucket = 'react-js-application-terraform-state-866934333672'
$devStateKey = 'react-js-application/dev/terraform.tfstate'
$statePath = 'C:\Users\Olalekan Ogundare\AppData\Local\Temp\dev-state.json'

Write-Output 'Dispatching base infrastructure recreate workflow...'
& $gh workflow run deploy.yml --repo Olalekog/todo-3tier-app -f environment=dev -f action=apply -f workload=infra
$infraRun = & $gh run list --repo Olalekog/todo-3tier-app --workflow deploy.yml --limit 1 --json databaseId --jq '.[0].databaseId'
if (-not $infraRun) { throw 'Could not resolve deploy workflow run id.' }
& $gh run watch $infraRun --repo Olalekog/todo-3tier-app --exit-status

Write-Output 'Dispatching app image rebuild and deploy workflow...'
& $gh workflow run docker-build-push.yml --repo Olalekog/todo-3tier-app -f environment=dev -f workload=app
$appRun = & $gh run list --repo Olalekog/todo-3tier-app --workflow docker-build-push.yml --limit 1 --json databaseId --jq '.[0].databaseId'
if (-not $appRun) { throw 'Could not resolve docker workflow run id.' }
& $gh run watch $appRun --repo Olalekog/todo-3tier-app --exit-status

Write-Output 'Restoring DB password from state backup...'
$dbPassword = $null
if (Test-Path $statePath) {
  $state = Get-Content $statePath -Raw | ConvertFrom-Json
  $dbResource = $state.resources | Where-Object { $_.module -eq 'module.database' -and $_.type -eq 'aws_db_instance' -and $_.name -eq 'this' }
  if ($dbResource) { $dbPassword = $dbResource.instances[0].attributes.password }
}
if ([string]::IsNullOrWhiteSpace($dbPassword)) { throw 'Database password backup not available to apply SonarQube.' }

Set-Location 'C:\Users\Olalekan Ogundare\Learning\Project\AWS\todo-3tier-app\terraform'
& $tf init -input=false -reconfigure -backend-config="bucket=$bucket" -backend-config="key=$devStateKey" -backend-config="region=us-east-1" -backend-config="encrypt=true"
& $tf apply -auto-approve -input=false -no-color -var-file environments/dev.tfvars -var-file security-tools/deploy/sonarqube.tfvars -var "db_password=$dbPassword" -target=module.security_integration

$frontendUrl = & $tf output -raw frontend_url
$sonarqubeUrl = & $tf output -raw sonarqube_url
Write-Output ("frontend_url={0}" -f $frontendUrl)
Write-Output ("sonarqube_url={0}" -f $sonarqubeUrl)
