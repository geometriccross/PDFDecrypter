class ConfigValues {
    [string]$private:targetDirectoryPath
    [string]TargetDirectoryPath() { return $this.targetDirectoryPath }

    [string]$private:passwordsFilePath
    [string]PasswordsFilePath() { return $this.passwordsFilePath }

    [string]$private:settingFilePath
    [string]SettingFilePath() { return $this.settingFilePath }

    ConfigValues($targetDirectoryPath, $passwordsFilePath, $settingFilePath) {
        $this.targetDirectoryPath = $targetDirectoryPath
        $this.passwordsFilePath = $passwordsFilePath
        $this.settingFilePath = $settingFilePath
    }

    [string[]]ToStrings() {
        [string[]]$result = @($this.targetDirectoryPath, $this.passwordsFilePath, $this.settingFilePath)
        return $result
    }

    [string]ToJson() {
        $result = $this | ConvertTo-Json
        return $result
    }

    [PSCustomObject]FromJson($jsonValue) {
        $result = $jsonValue | ConvertFrom-Json
        return $result
    }
}