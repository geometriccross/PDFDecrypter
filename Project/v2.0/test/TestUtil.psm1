using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.IO
using assembly "..\src\lib\BouncyCastle.Crypto.dll"
using assembly "..\src\lib\itextsharp.dll"

class TestUtil {
    static [double]AverageTimeMeasure([scriptblock]$target, $progressTime) {
        if ($progressTime -lt 0) {
            throw [System.IndexOutOfRangeException]::new('The number of progressTime must be greater than or equal to 0')
        }
        else {
            [double]$totalTime = 0
            [double]$doTime = 0
            for ([int]$i = 0; $i -le $progressTime + 1; $i++) {
                try {
                    $doTime = (Measure-Command { $target }).TotalMilliseconds
                }
                catch {
                    Write-Host $_.Exception
                }
                
                #最初�E飛�EぁE
                if($i -ne 0) {
                    $totalTime += $doTime
                    $runTime = $i - 1
                    Write-Host "$runTime : $doTime"
                }
            }
            $result = $totalTime / $progressTime
            Write-Host "Average : $result"
            return $result
        }
    }
    
    static [string]CreateTestFolder([string]$dirPath, [string]$folderName) {
        #作業フォルダを作�E
        $folderPath = Join-Path $dirPath -ChildPath $folderName
        $isExists = Test-Path -Path $folderPath
        if ($isExists -eq $false) {
            New-Item $folderPath -ItemType Directory
        }

        return $folderPath
    }

    static [string[]]CreatePDF([string]$dirPath, [int]$createFileNum) {
        [string[]]$result = @()
        for ([int]$i = 0; $i -lt $createFileNum; $i++) {
            $randomStr = -join ((10..20) | %{(65..90) + (97..122) | Get-Random} | % {[char]$_})
            $filePath = Join-Path $dirPath -ChildPath "$randomStr.pdf"

            $doc = [iTextSharp.text.Document]::new()
            $fs = [FileStream]::new($filePath, [FileMode]::Create, [FileAccess]::Write)      
            [iTextSharp.text.pdf.PdfWriter]$writer = $null      
            try {
                try {
                    $writer = [iTextSharp.text.pdf.PdfWriter]::GetInstance($doc, $fs)
                }
                catch {
                    throw $_.Exception
                }
                finally {
                    $null -eq $writer ? $null : $writer.Close()
                }

                $doc.Open()
                $doc.Add([iTextSharp.text.Paragraph]::new("Hello World"))
            }
            catch {
                throw $_.Exception
            }
            finally {
                $doc.CloseDocument()
                $fs.Dispose()
                $writer.Close
            }

            $result += $filePath
        }

        return $result
    }
    
    static [string[][]]EncryptPDF([string[]]$pathes, [bool]$onlyDirName) {
        [string[][]]$results = @(@())
        foreach ($path in $pathes) {
            $outputPath = $path.Replace(".pdf", ".temp")
            $reader = [iTextSharp.text.pdf.PdfReader]::new($path)
            $fs = [FileStream]::new($outputPath, [FileMode]::Create, [FileAccess]::Write, [FileShare]::None)
            try {
                [string]$pdfPas = [Path]::GetFileNameWithoutExtension($path)
                [iTextSharp.text.pdf.PdfEncryptor]::Encrypt(
                    $reader,
                    $fs,
                    [iTextSharp.text.pdf.PdfWriter]::STANDARD_ENCRYPTION_128,
                    $pdfPas,
                    $pdfPas,
                    $reader.Permissions
                )

                if($onlyDirName) {
                    $dirName = Split-Path $path | Split-Path -Leaf
                }
                else {
                    $dirName = Split-Path $path
                }

                $results += ,@($dirName, $pdfPas)
            }
            catch {
                throw $_.Exception
            }
            finally {
                $reader.Dispose()
                $fs.Dispose()
            }

            Remove-Item $path
            Rename-Item -Path $outputPath -NewName  $outputPath.Replace(".temp", ".pdf")
        }

        return [string[][]]$results
    }

    static [string]CreatePasswordFile([string]$dirPath, [string]$fileName, [string[][]]$values) {
        $filePath = Join-Path $dirPath -ChildPath $fileName
        New-Item $filePath
        $sw = [StreamWriter]::new($filePath)
        try {
            $sw.WriteLine("#SubjectName,Password")
            for ([int]$i = 0; $i -le $values.Count; $i++) {
                $str = $values[$i] -join ","
                $sw.WriteLine($str)
            }
        }
        catch {
            throw $_.Exception
        }
        finally {
            $sw.Dispose()
        }

        return $filePath
    }
}