$fromJson = '
{
    "dirPath":"aaa",
    "filePath":"bbb",
    "names":[
        "Yamada",
        "Tarou",
        "Hanako",
    ]
}'

class ToJsonClass {
    $dirPath = [string]::Empty
    $filePath = [string]::Empty
    $companies = @()
    $person

    static [ToJsonClass]CreateNewValue() {
        $result = [ToJsonClass]::new()
        $result.dirPath = "AAA"
        $result.filePath = "BBB"
        $result.companies = @("Apple", "IBM", "Microsoft", "Nintendo")
        $result.person = @(
                @("template name", @("Yamada", "Tarou")), 
                @("sport man", @("Otani", "Shohei")), 
                @("CEO", @("Steave", "Jobs"))
            )

        return $result
    }

    [void]GetVariable() {
        Get-Content -OutVariable | ForEach-Object {
            Write-Host $_.name
        }
    }
}

$json = [ToJsonClass]::CreateNewValue() | ConvertTo-Json 
Write-Host $json
Write-Host $json.GetType()
Write-Host

$json = $json | ConvertFrom-Json
Write-Host $json
Write-Host $json.GetType()
