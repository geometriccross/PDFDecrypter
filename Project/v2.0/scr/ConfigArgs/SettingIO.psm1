#class ConfigValues
    #[string]$readonly:対象のpdfがあるフォルダーのパス
    #[string]$readonly:pdfのパスワードがまとめられたcsvファイルのパス

    #ConfigValues($dirPath, $passwordFilePath)
        #$resultに引数を追加する
        #return $result

    #[string[]]ToStrings()
        #[string[]]$result = @($dirPath, $passwordFilePath)
        #return $result

    #[PSCustomObject]ToJson()
        #$result = $this | ConvertTo-Json
        #return $result


#class　初期化に関するものたち
    #読み込む($path)
        #settingsファイルから読み込む
        #$setttingClassに代入、独自のデータ型
        #それを返す

    #[void]SettingAppend($ValueClass)
        #渡された引数を設定として追加する

    #[bool]IsAppend($targetClass)
        #targetClassがちゃんと追加されているかどうかを確認する
        #$isContaineEnviroment = $env:Path.Contains($targetClass.フォルダーのパス)
        #$isExistPasswordFile = Test-Path $targetClass.パスワードファイルのパス
        #すべて満たしていればtrueを、そうでないならfalseを返す