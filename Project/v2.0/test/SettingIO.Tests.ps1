using namespace System
using namespace System.IO
using assembly "..\scr\lib\BouncyCastle.Crypto.dll"
using assembly "..\scr\lib\itextsharp.dll"
using module "..\scr\ConfigValues.psm1"
using module "..\scr\SettingIO.psm1"
using module ".\TestUtil.psm1"

Describe "SettingIOのテスト" {
    BeforeAll {
        $dirPath = [TestUtil]::CreateTestFolder($PSScriptRoot, "ForTest")

        $config = [ConfigValues]::CreateTemplateConfig()
        [string]$jsonFilePath = Join-Path -Path "$dirPath\" -ChildPath $config.ConfigName
        $config.Destination = "$jsonFilePath.json"
    }

    AfterAll {
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $true) {
            Remove-Item $dirPath -Force -Recurse
        }
    }

    Context "正常系の確誁" {
        It "セーブできるか" {
            [SettingIO]::Save($config)

            try {
                $value = Get-Content -Path $config.Destination
                $target = [ConfigValues]::FromJson($value)

                $target.ToStrings() | Should Be $config.ToStrings()
            }
            catch {
                Write-Error $_.Exception
            }
        }

        It "jsonファイルを読み込めるか" {
            $result = [SettingIO]::LoadFrom($config.Destination)
            $result.ToStrings() | Should Be $config.ToStrings()
        }
    }
}