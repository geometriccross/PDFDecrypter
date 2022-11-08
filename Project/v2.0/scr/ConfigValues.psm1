class ConfigValues {
    [string]$private:configName
    [string]ConfigName() { return $this.configName }

    [string]$private:targetDirectoryPath
    [string]TargetDirectoryPath() { return $this.targetDirectoryPath }

    [string]$private:passwordsFilePath
    [string]PasswordsFilePath() { return $this.passwordsFilePath }

    [string]$private:destination
    [string]Dest() { return $this.destination }

    ConfigValues($configName, $targetDirectoryPath, $passwordsFilePath, $dest) {
        $this.configName = $configName
        $this.targetDirectoryPath = $targetDirectoryPath
        $this.passwordsFilePath = $passwordsFilePath
        $this.destination = $dest
    }

    static [ConfigValues]CreateTemplateConfig() {
        $name = "ConfigName:TemplateConfig"
        $dirPath = "DirectoryPath:no data"
        $passPath = "PasswordsPath:no data"
        $dest = "Dest:no data"
        $result = [ConfigValues]::new($name, $dirPath, $passPath, $dest)
        return $result
    }

    [string[]]ToStrings() {
        [string[]]$result = @($this.targetDirectoryPath, $this.passwordsFilePath, $this.settingFilePath)
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