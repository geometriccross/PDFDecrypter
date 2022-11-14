class ConfigValues {
    [string]$ConfigName
    [string]$TargetDirectoryPath
    [string]$PasswordsFilePath
    [string]$Destination

    ConfigValues($configName, $targetDirectoryPath, $passwordsFilePath, $dest) {
        $this.ConfigName = $configName
        $this.TargetDirectoryPath = $targetDirectoryPath
        $this.PasswordsFilePath = $passwordsFilePath
        $this.Destination = $dest
    }

    static [ConfigValues]CreateTemplateConfig() {
        $name = "TemplateConfig"
        $dirPath = "ForTest"
        $passPath = "no data"
        $dest = "$PSScriptRoot\$name.json"
        return [ConfigValues]::new($name, $dirPath, $passPath, $dest)
    }

    [string[]]ToStrings() {
        [string[]]$result = @($this.ConfigName, $this.TargetDirectoryPath, $this.PasswordsFilePath, $this.Destination)
        return $result
    }

    [string]ToJson() {
        $result = $this | ConvertTo-Json
        return $result
    }

    [ConfigValues]FromJson($jsonValue) {
        $result = $jsonValue | ConvertFrom-Json
        return $result
    }
}