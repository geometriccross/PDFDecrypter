using module "..\scr\lib\BouncyCastle.Crypto.dll"
using module "..\scr\lib\itextsharp.dll"
using module "..\scr\PasswordArgs.psm1"
. "$PSScriptRoot\TestUtil.ps1"


Describe "PasswordArgsのテスト" {
    BeforeAll {
        $dirPath = [TestUtil]::CreateTestFolder($PSScriptRoot, "ForTest")
        $passwords = @(@())
        for($i = 0; $i -lt 30; $i++) {
            $passwords += ,@("subject_$i", "password_$i")
        }
        $csvPath = [TestUtil]::CreatePasswordFile($dirPath, "TestPasswords.csv", $passwords)
    }

    AfterAll {
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $true) {
            Remove-Item $dirPath -Recurse -Force
        }
    }

    BeforeEach {
        $passwordArgs = [PasswordArgs]::new($csvPath)
    }

    AfterEach {
        $passwordArgs.Dispose()
    }

    Context "正常系の確認" {
        It "ファイルが読み込めているかどうか" {
            [int]$isEqualeCount = 0
            for ([int]$i = 0; $i -lt $passwordsArg.password.Count; $i++) {
                if ($passwordArgs.password[$i][1] -eq $passwords[$i][1]) {
                    $isEqualeCount++
                }
            }

            $isEqualeCount | Should Be $passwordArgs.password.Count
        }
    }
}