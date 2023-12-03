using namespace System
using namespace System.IO
using module '.\ConfigValues.psm1'

class SettingIO{
    static [ConfigValues]LoadFrom([string]$path) {
        #settingsファイルから読み込む
        $isExists = Test-Path $path
        if ($isExists -eq $false) {
            throw [NullReferenceException]::new("Failed the progress to load a setting file. File is NOT Exist")
        }

        if ([Path]::GetExtension($path).Contains(".json") -eq $false) {
            throw [ArgumentException]::("File extension is invailed. Setting file need '.json'")
        }

        $result = Get-Content $path
        $result = [ConfigValues]::FromJson($result)
        return $result
    }

    static [bool]Save([ConfigValues]$obj) {
        [bool]$result = $false
        New-Item $obj.Destination
        [StreamWriter]$sw = $null
        try {
            $sw = [StreamWriter]::new($obj.Destination)
            $sw.Write($obj.ToJson())
            $result = $true
        }
        catch {
            throw $_.Exception
        }
        finally {
            $null -eq $sw ? $null : $sw.Dispose()
        }

        return $result
    }
}