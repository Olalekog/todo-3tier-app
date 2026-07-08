$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$tf = 'C:\Users\Olalekan Ogundare\AppData\Local\Microsoft\WinGet\Links\terraform.exe'
& $tf init -input=false -reconfigure `
  -backend-config=bucket=react-js-application-terraform-state-866934333672 `
  -backend-config=key=react-js-application/sonarqube/terraform.tfstate `
  -backend-config=region=us-east-1 `
  -backend-config=encrypt=true
& $tf destroy -auto-approve -input=false -no-color `
  -var-file environments/dev.tfvars `
  -var-file security-tools/deploy/sonarqube.tfvars `
  -var db_password=placeholder
