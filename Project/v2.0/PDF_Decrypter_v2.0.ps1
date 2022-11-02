using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.IO

Add-type -Path "$currentPath\lib\BouncyCastle.Crypto.dll"
Add-type -Path "$currentPath\lib\itextsharp.dll"

[Main]::DoProgress()

class Main {
    static [void]DoProgress() {
        $csvFilePath = Join-Path $PSScriptRoot -ChildPath 'password.csv'

        $pdfs = [PDFs]::new($csvFilePath)
        $qpdf = [QPDF]::new()

        try {
            #パスワードを解除
            $qpdf.Decrypt($pdfs.GetArray(), $PSScriptRoot, 0)
        }
        catch {
            Write-Error $_.Exception
        }
    }
}

class PDFs {
    [string[]]$private:passwords

    [string[]]GetArray() {
        return $this.passwords
    }

    PDFs([string]$path) {
        $this.passwords = $this.LoadFrom($path)
    }

    #ファイルからパスワード一覧を取得
    [string[]]LoadFrom([string]$path) {  
        $isExists = Test-Path -Path $path      
        if ($isExists -eq $false) {
            throw [NullReferenceException]::new('File is NOT exist.')
        }

        $extension = [Path]::GetExtension($path)
        if ($extension -ne '.csv') {
            throw [InvalidDataException]::new('The extension is different. \The file to be read must be a "csv."')
        }

        [string[]]$result = @()
        $sr = [StreamReader]::new($path, [Text.Encoding]::GetEncoding("Shift-JIS"))
        [int]$line = 0
        try {
            #ファイルを読み込み
            while ($null -ne ($row = $sr.ReadLine())) {
                if ($row.Contains('#')) {
                    continue
                }

                [string[]]$arr = $row.Split(',')
                #配列の長さが2、つまり科目名とパスワードの2ペアからなる場合のみ
                if(($arr.Length -ne 2) -And [string]::IsNullOrEmpty($arr[0])) {
                    continue
                }

                $result += $arr[1]
                $line += 1
            }

            #最初の行を飛ばす
            for ($i = 1; $i -eq $result.Count; $i++) {
                $result[$i - 1] = $result[$i]
            }

            return $result
        }
        catch {
            throw [IOException]::new('Failed to load ' + $line + ' line.')
        }
        finally {
            $sr.close()
        }
    }
}

class QPDF {
    [boolean]IsPasswordMatch([string]$file, [string]$pas) {
        $pdfReader = $null
        $result = $false
        try {
            $pdfReader = [Pdf.IO.PdfReader]::Open("$file")
        }
        catch [Management.Automation.MethodInvocationException] {
            if($_.Exception.Message.Contains("The PDF document is protected with an encryption not supported by PDFsharp.")) {
                $result = $true
            }
            else {
                throw $_.Exception
            }
        }
        catch [IOException] {
            throw $_.Exception
        }
        finally {
            $pdfReader.Close()
        }

        return $result
    }

    [PdfDocument]CopyAllPage([PdfDocument]$inputDoc) {
        $result = [PdfDocument]::new()
        foreach ($page in $inputDoc.Pages) {
            $result.AddPage($page)
        }

        return $result
    }

    [void]Decrypt([string[]]$pasArr, [string]$path, [int]$depth) {
        $files = Get-ChildItem $path -Recurse -Filter *.pdf -Depth $depth | ForEach-Object {
            try {
                $outputDoc = [PdfDocument]::new()
                if($this.IsProtected($_.FullName) {
                    #線形探索
                    foreach ($pas in $pasArr) {
                        try { 
                            $inputDoc = [PdfReader]::Open($file.FullName)
                            $outputDoc = $this.CopyAllPage($inputDoc)
                        }
                        catch {
                            {1:<#Do this if a terminating exception happens#>}
                        }
                    }
                }
            }
            catch {
                throw $_.Exception
            }
        }
        foreach ($file in $files) {
            try {
                if($this.IsProtected($file)
                #失敗したら == パスワードが掛かっていたら
                if($isComplete -eq $false) {
                    foreach ($value in $arr) {
                        qpdf --decrypt $file.FullName --password=$value --replace-input
                    }
                }
            }
            catch {
                throw $?.Exception
            }
        }
    }
}

class SaveConfig {

}