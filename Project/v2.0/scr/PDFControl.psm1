using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.IO
using assembly ".\lib\BouncyCastle.Crypto.dll"
using assembly ".\lib\itextsharp.dll"
using module ".\PasswordArgs.psm1"

class PDFControl : IDisposable {
    $passwordArgs = $null
    PDFControl([PasswordArgs]$passwordArgs) {
        $this.passwordArgs = $passwordArgs
    }

    static [bool]IsEncrypt([string]$filePath) {
        $result = $false
        $reader = $null
        try {
            $reader = [iTextSharp.text.pdf.PdfReader]::new($filePath)
        }
        catch [iTextSharp.text.exceptions.BadPasswordException] {
            $result = $true
        }
        finally {
            $null -eq $reader ? $null : $reader.Dispose()
        }

        return $result
    }

    [void]Decrypt([string]$filePath, [string]$password) {
        $isEncrypt = [PDFControl]::IsEncrypt($filePath)
        if ($isEncrypt -eq $false) { return }
        else {
            qpdf --decrypt $filePath --password=$password --replace-input
        }
    }

    [void]DecryptAll([string]$dirPath, [int]$depth) {
        foreach ($filePath in [Directory]::GetFiles($dirPath, "*.pdf", [SearchOption]::AllDirectories)) {
            Write-Host "Target:$filePath"
            if ([PDFControl]::IsEncrypt($filePath) -eq $false) {
                Write-Host $filePath "is NOT encrypted"
                continue
            }

            [int]$tryCount = 0
            foreach ($password in $this.passwordArgs.Get()) {
                if ([PDFControl]::IsEncrypt($filePath) -eq $false) {
                    Write-Host "Decryption succeeded:$filePath"
                    break
                }
                
                $tryCount++
                Write-Host "Try Password:$password, Time:$tryCount"
                qpdf --decrypt $filePath --password=$password --replace-input
            }
        }
    }

    [void]Dispose() {
        $this.passwordArgs.Dispose()
    }
}