$ErrorActionPreference = 'Stop'
$statePath = 'C:\Users\Olalekan Ogundare\AppData\Local\Temp\sonarqube-old-state.json'
aws s3 cp 's3://react-js-application-terraform-state-866934333672/react-js-application/sonarqube/terraform.tfstate' $statePath --only-show-errors | Out-Null
$state = Get-Content $statePath -Raw | ConvertFrom-Json
foreach ($resource in $state.resources) {
  $module = if ($resource.module) { $resource.module } else { 'root' }
  foreach ($instance in $resource.instances) {
    $attrs = $instance.attributes
    $id = if ($attrs.PSObject.Properties.Name -contains 'id') { $attrs.id } else { '' }
    $name = if ($attrs.PSObject.Properties.Name -contains 'name') { $attrs.name } else { '' }
    Write-Output ([string]::Format('{0} :: {1}.{2} :: id={3} :: name={4}',$module,$resource.type,$resource.name,$id,$name))
  }
}
