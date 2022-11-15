$config = [ConfigValues]::CreateTemplateConfig()
$config.Destination = Join-Path -Path "$PSScriptRoot\ForTest" -ChildPath $config.ConfigName + ".json"
Write-Host $config.Destination