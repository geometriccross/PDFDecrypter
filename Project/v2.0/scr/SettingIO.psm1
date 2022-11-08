using namespace System
using namespace System.IO

class SettingIO{
    static [PSCustomObject]LoadFrom([string]$path) {
        #settingsファイルから読み込む
        $isExists = Test-Path $path
        if ($isExists -eq $false) {
            throw [NullReferenceException]::new("Failed the progress to load a setting file. File is NOT Exist")
        }

        if ([File]::GetExtension($path).Contains(".json") -eq $false) {
            throw [ArgumentException]::("File extension is invailed. Setting file need '.json'")
        }

        if ([SettingIO]::ObjectPropertyCheck() -eq $false) {
            throw [ArgumentNullException]
        }

        $result = Get-Content $path | ConvertFrom-Json
        return $result
    }

    static [bool]Save([PSCustomObject]$obj, [string]$fileName, [string]$dest) {
        [bool]$result = $false
        $path = Join-Path $dest -ChildPath $fileName
        try {
            $obj | ConvertTo-Json | Out-File -FilePath $path
            $result = $true
        }
        catch {
            throw $_.Exception
        }

        return $result
    }

    static [void]ObjectPropertyCheck([PSCustomObject]$obj) {
        $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
            Write-Host $_.TypeNames
        }
    }
}