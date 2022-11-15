using namespace System
using namespace System.IO
using assembly ".\scr\lib\BouncyCastle.Crypto.dll"
using assembly ".\scr\lib\itextsharp.dll"
using module ".\scr\PasswordArgs.psm1"
using module ".\scr\PDFControl.psm1"
using module ".\scr\ConfigValues.psm1"
using module ".\scr\SettingIO.psm1"
$qpdfPath = Split-Path $PSScriptRoot
$env:Path += "$qpdfPath\scr\lib\qpdf-10.6.3\bin;"

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

