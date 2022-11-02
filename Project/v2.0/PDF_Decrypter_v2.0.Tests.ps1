using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.IO

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$PSScriptRoot\$sut"
. "$here\TestUtil.ps1"

Describe "PDFsのテスト" {
    BeforeAll {
        #作業フォルダを作成
        $dirPath = Join-Path $PSScriptRoot -ChildPath "ForTest"
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $false) {
            New-Item $dirPath -ItemType Directory
        }

        $dataPath = Join-Path $dirPath -ChildPath "TestPasswords.csv"
        $wrongPath = Join-Path $PSScriptRoot -ChildPath "SampleData\CSV\passwords.wrongExt"

        New-Item $dataPath -Force
        $sw = [StreamWriter]::new($dataPath)
        try {
            $sw.WriteLine("#FileName,Password")
            $sw.WriteLine("subjectA,PasswordA")
            $sw.WriteLine("subjectB,PasswordB")
        }
        catch {
            Write-Host $_.Exception
        }
        finally {
            $sw.Close()
        }

        #比較対象として使用
        $passwords = 'admin_A', 'passwordB'
    }

    AfterAll {
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $true) {
            Remove-Item $dirPath -Recurse -Force
        }
    }

    Context "読み込みについて" {
        It "ファイルが読み込めているかどうか" {
            $pdfs = [PDFs]::new($dataPath)
            $pdfs.GetArray().Count | Should Be $passwords.Count
        }

        It "読み込むファイルが存在しない場合" {
            $caught = $false
            try {
                $pdfs = [PDFs]::new($wrongPath)
            }
            catch [InvalidDataException] {
                $caught = $true
            }
            catch [NullReferenceException] {
                $caught = $true
            }
            
            $caught | Should Be $true
        }
    }
}

Describe "QPDFのテスト" {
    BeforeAll {
        $dirPath = Join-Path $PSScriptRoot -ChildPath "ForTest"
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $false) {
            New-Item $dirPath -ItemType Directory
        }
        
        #pdfを生成
        $pathes = [TestUtil]::CreatePDF($dirPath, 4)
        $arr = [TestUtil]::EncryptPDF($pathes)
        $passwordFile = Join-Path $dirPath -ChildPath "TestPasswords.csv"
        [TestUtil]::CreatePasswordFile($passwordFile, $arr)

        $pdfs = [PDFs]::new($testPassword)
    }

    AfterAll {
        $isExists = Test-Path -Path $dirPath
        if ($isExists -eq $true) {
            Remove-Item $dirPath -Recurse -Force
        }
    }

    Context "パスワードの解除について" {
        It "解除できるかどうか" {
            $qpdf = [QPDF]::new()
            $complete = $false
            
            try {
                $qpdf.Decrypt($pdfs.GetArray(), $dirPath, 0)
                $complete = $true
            }
            catch {
                $complete = $false
            }

            $complete | Should Be $true
        }
    }
}