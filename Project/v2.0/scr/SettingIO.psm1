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

        if ([File]::GetExtension($path).Contains(".json") -eq $false) {
            throw [ArgumentException]::("File extension is invailed. Setting file need '.json'")
        }

        $result = Get-Content $path | ConvertFrom-Json
        return $result
    }

    static [bool]Save([ConfigValues]$obj) {
        [bool]$result = $false
        $path = Join-Path $obj.Destination() -ChildPath $obj.ConfigName()
        $fs = [FileStream]::new($path, [FileMode]::Create)
        try {
            $fs.Write($obj.ToJson())
            $result = $true
        }
        catch {
            throw $_.Exception
        }
        finally {
            $fs.Dispose()
        }

        return $result
    }
}