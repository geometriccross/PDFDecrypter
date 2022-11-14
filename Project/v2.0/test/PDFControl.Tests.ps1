using namespace System
using assembly "..\scr\lib\BouncyCastle.Crypto.dll"
using assembly "..\scr\lib\itextsharp.dll"
using module ".\TestUtil.psm1"
using module "..\scr\PasswordArgs.psm1"
using module "..\scr\PDFControl.psm1"
$qpdfPath = Split-Path $PSScriptRoot
$env:Path += "$qpdfPath\scr\lib\qpdf-10.6.3\bin;"

Describe "PDFControlのテスト" {
    BeforeAll {
        $passwords = @(@())
        $depth = 2
        $createPdfNum = 3

        $folderName = "ForTest"
        $dirPath = $PSScriptRoot
        for ([int]$i = 0; $i -lt $depth; $i++) {
            try {
                $dirPath = [TestUtil]::CreateTestFolder($dirPath, $folderName + "_" + $i)
                $filePathes = [TestUtil]::CreatePDF($dirPath, $createPdfNum)
                $passwords += [TestUtil]::EncryptPDF($filePathes, $true)   
            }
            catch {
                Write-Error $_.Exception
            }

        }

        $folderName += "_0"
        $dirPath = Join-Path $PSScriptRoot -ChildPath $folderName
        $csvPath = [TestUtil]::CreatePasswordFile($dirPath, "TestPasswords.csv", $passwords)
    }

    AfterAll {
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $true) {
            Remove-Item $dirPath -Force -Recurse
        }
    }

    BeforeEach {
        $passwordArgs = [PasswordArgs]::new($csvPath)
        $pdfControl = [PDFControl]::new($passwordArgs)
    }

    AfterEach {
        $pdfControl.Dispose()
    }

    Context "正常系の確認" {
        It "パスワードが掛かっているかの確認ができるか" {
            $pathes = @()
            for ([int]$i = 0; $i -lt 2; $i++) {
                try {
                    $pathes += [TestUtil]::CreatePDF($dirPath, 1)
                }
                catch {
                    Write-Error $_.Exception
                }
            }

            [TestUtil]::EncryptPDF($pathes[0], $false)

            $hasPassword = [PDFControl]::IsEncrypt($pathes[0])
            $noPassword = [PDFControl]::IsEncrypt($pathes[1])

            foreach ($path in $pathes) {
                Remove-Item -Path $path
            }

            $hasPassword -ne $noPassword | Should Be $true
        }

        It "単一のPDFの復号化ができるか" {
            $filePathes = Get-ChildItem -Path $dirPath -Filter "*.pdf" | ForEach-Object { $_.FullName }
            [string]$filePath = $filePathes[1]

            try {
                $pdfControl.Decrypt($filePath, [IO.Path]::GetFileNameWithoutExtension($filePath))
            }
            catch {
                Write-Error $_.Exception
            }

            [PDFControl]::IsEncrypt($filePath) | Should Be $false
        }

        It "複数のPDFの復号化ができるか" {
            try {
                $pdfControl.DecryptAll($dirPath, $depth)
            }
            catch {
                Write-Error $_.Exception
            }

            [bool]$result = $false
            Get-ChildItem -Path $dirPath -Filter "*.pdf" -Recurse | ForEach-Object {
                $isEncrypt = [PDFControl]::IsEncrypt($_.FullName)
                if ($isEncrypt -eq $true) {
                    $result = $isEncrypt
                }
            }

            $result | Should Be $false
        }
    }
}