using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.IO
using module ".\lib\BouncyCastle.Crypto.dll"
using module ".\lib\itextsharp.dll"
using module ".\PasswordArgs.psm1"

class PDFControl : IDisposable {
    $passwordArgs = $null
    PDFControl([PasswordArgs]$passwordArgs) {
        if ($null -eq $this.passwordArgs) {
            $this.passwordArgs = $passwordArgs
        }
    }

    static [boolean]IsEncrypt([string]$filePath) {
        $result = $false
        $reader = $null
        try {
            $reader = [iTextSharp.text.pdf.PdfReader]::new($filePath)
        }
        catch [iTextSharp.text.exceptions.BadPasswordException] {
            $result = $true
        }
        catch {
            Write-Host $_.Exception
        }
        finally {
            if($null -ne $reader) {
                $reader.Dispose()
            }
        }

        return $result
    }

    [void]Decrypt([string]$dirPath, [int]$depth) {
        Get-ChildItem $dirPath -Recurse -Filter "*.pdf" -Depth $depth | ForEach-Object { 
            if([PDFControl]::IsEncrypt($_.FullName) -eq $false) {
                return
            }

            foreach ($password in $this.passwordArgs.Get()) {
                try {
                    $outputPath = [Path]::ChangeExtension($_.FullName, ".temp")
                    $pdfReader = [iTextSharp.text.pdf.PdfReader]::new($_.FullName, $password.ToByte())
                    $pdfWriter = [iTextSharp.text.pdf.PdfWriter]::new($outputPath)
                    $pdfDocumnt = [iTextSharp.text.pdf.PdfDocument]::new($pdfReader, $pdfWriter)

                    Write-Host "Password Correct : $password"
                }
                catch [iTextSharp.text.exceptions.BadPasswordException] {
                    Write-Host "Password Missmatch : $password"
                }
                catch {
                    throw $_.Exception
                }
                finally {
                    $pdfDocumnt.Close()
                    $pdfReader.Dispose()
                    $pdfWriter.Dispose()
                }
            }

        }
    }

    [void]Dispose() {
        $this.passwordArgs.Dispose()
    }
}