using module "..\scr\ConfigValues.psm1"
using module "..\scr\SettingIO.psm1"
using module ".\TestUtil.psm1"

Describe "SettingIOのテスト" {
    BeforeAll {
        $dirPath = [TestUtil]::CreateTestFolder($PSScriptRoot, "ForTest")
    }



    Context "正常系の確誁" {
        It "セーブできるか" {
            $config = [ConfigValues]::CreateTemplateConfig()
            [SettingIO]::Save($config)
            Write-Host $config.Destination
        }
    }
}