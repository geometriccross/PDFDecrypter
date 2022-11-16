using namespace System
using namespace System.IO
using assembly ".\src\lib\BouncyCastle.Crypto.dll"
using assembly ".\src\lib\itextsharp.dll"
using module ".\src\PasswordArgs.psm1"
using module ".\src\PDFControl.psm1"
using module ".\src\ConfigValues.psm1"
using module ".\src\SettingIO.psm1"
$qpdfPath = Split-Path $PSScriptRoot
$env:Path += "$qpdfPath\src\lib;"

Write-Host "PDFDecrypter"

try {
    Push-Location $PSScriptRoot
    [ConfigValues]$config = [SettingIO]::LoadFrom("$PSScriptRoot\settings.json")

    [PasswordArgs]$passwordArgs
    [PDFControl]$pdfControl
    try {
        $passwordArgs = [PasswordArgs]::new($config.PasswordsFilePath)
        $pdfControl = [PDFControl]::new($passwordArgs)

        $pdfControl.DecryptAll($config.TargetDirectoryPath)
    }
    catch {
        Write-Error $_.Exception
    }
    finally {
        $null -eq $pdfControl ? $null : $pdfControl.Dispose()
    }
}
catch {
    Write-Error $_.Exception
}

finally {
    Pop-Location
}