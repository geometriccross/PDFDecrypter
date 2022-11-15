using namespace System
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.IO
using namespace System.Linq

class PasswordArgs : IDisposable {
    [string[]]$passwords = @()

    [string[]]Get() {
        return $this.passwords
    }

    PasswordArgs([string]$path) {
        $this.passwords = $this.LoadFrom($path)
    }

    #ファイルからパスワード一覧を取得
    [string[]]LoadFrom([string]$path) {
        $isExists = Test-Path $path
        if ($isExists -eq $false) {
            throw [NullReferenceException]::new('File is NOT exist.' + $path)
        }

        $extension = [Path]::GetExtension($path)
        if ($extension -ne '.csv') {
            throw [InvalidDataException]::new('The extension is different. The file to be read must be a "csv."')
        }

        $result = @(@())
        $sr = [StreamReader]::new($path, [Text.Encoding]::GetEncoding("Shift-JIS"))
        [int]$line = 0
        try {
            #ファイルを読み込み
            while ($null -ne ($row = $sr.ReadLine())) {
                if ($row.Contains('#')) {
                    continue
                }

                $arr = $row.Split(',')
                #配列の長さが2、つまり科目名とパスワードの2ペアからなる場合のみ
                if(($arr.Length -ne 2) -And [string]::IsNullOrEmpty($arr[0])) {
                    continue
                }

                $result += $arr[1]
                $line += 1
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

    [void]Dispose() {
        $this.passwords = $null
    }
}