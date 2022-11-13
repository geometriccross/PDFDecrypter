using namespace System
using assembly "..\scr\lib\BouncyCastle.Crypto.dll"
using assembly "..\scr\lib\itextsharp.dll"
using module ".\TestUtil.psm1"
using module "..\scr\PasswordArgs.psm1"
using module "..\scr\PDFControl.psm1"
$env:Path += "..\scr\lib\qpdf-10.6.3\bin"

Describe "PDFControlのテスト" {
    BeforeAll {
        $passwords = @(@())
        
        $depth = 5
        $folderName = "ForTest"
        $dirPath = $PSScriptRoot
        for ([int]$i = 0; $i -lt $depth; $i++) {
            try {
                $dirPath = [TestUtil]::CreateTestFolder($dirPath, $folderName + "_" + $i)
                $filePathes = [TestUtil]::CreatePDF($dirPath, 3)
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
            Remove-Item $dirPath -Recurse -Force
        }
    }

    BeforeEach {
        $passwordArgs = [PasswordArgs]::new($csvPath)
        $pdfControl = [PDFControl]::new($passwordArgs)
    }

    AfterEach {
        $passwordArgs.Dispose()
        $pdfControl.Dispose()
    }

    Context "正常系の確認" {
        It "パスワードが掛かっているかの確認ができるか" {
            $pathes = @()
            for ([int]$i = 0; $i -lt 2; $i++) {
                $pathes += [TestUtil]::CreatePDF($dirPath, 1)
            }

            [TestUtil]::EncryptPDF($pathes[0], $false)

            $hasPassword = [PDFControl]::IsEncrypt($pathes[0])
            $noPassword = [PDFControl]::IsEncrypt($pathes[1])

            foreach ($path in $pathes) {
                Remove-Item -Path $path
            }

            $hasPassword -ne $noPassword | Should Be $true
        }

        It "パスワードの解除ができるか" {
            $pdfControl.Decrypt($dirPath, $depth)

            [int]$isEncryotCount = 0
            Get-ChildItem -Path $dirPath -Filter "*.pdf" | ForEach-Object {
                $isEncryotCount += $pdfControl.IsEncrypt($_.FullName) ? 1 : 0
            }

            $isEncryotCount | Should Be $passwordArgs.Get().Count
        }

        It "一時的なテスト" {
            $pdfPath = Get-ChildItem -Path $dirPath -Filter "*.pdf"
            [string]$pdfPath = $pdfPath[0]
            $isExists = Test-Path $pdfPath
            if ($isExists -eq $false) {
                break
            }

            $resultPath = $pdfPath.Replace(".pdf", "_decrypt.pdf")
            $pdfPassword = [IO.Path]::GetFileNameWithoutExtension($pdfPath)

            $fs = [IO.FileStream]::new($resultPath, [IO.FileMode]::Create)
            $reader = [iTextSharp.text.pdf.PdfReader]::new($pdfPath, [Text.Encoding]::UTF8.GetBytes($pdfPassword))
            $writer = [iTextSharp.text.pdf.PdfWriter]::new($resultPath)
            
            try {
                $document = [iTextSharp.text.pdf.PdfDocument]::new(
                    $reader,
                    $writer)   
            }
            catch {
                Write-Error $_.Exception
            }
            finally {
                $document.Close()
                $reader.Dispose()
                $writer.Dispose()
                $fs.Dispose()
            }

            $pdfControl.IsEncrypt($resultPath) | Should Be $false            
        }
    }
}