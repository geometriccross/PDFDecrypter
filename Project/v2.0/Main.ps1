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