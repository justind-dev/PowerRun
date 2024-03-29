# DisplayText: "File Summary"
# Description: "Counts lines, words, and characters in a specified file."
# ConfiguredParameters: "-FilePath '.\interesting-file.txt'"

param (
    [string]$FilePath
)

function Get-FileSummary {
    param (
        [string]$Path
    )
    # we use below to set the location or working directory to the directory that the script 
    # resides in. Useful if you have secondary files in that directory which you want to access easily like so:
    # .\interesting-file.txt
    Set-Location -Path $PSScriptRoot 

    if (-not (Test-Path $Path)) {
        Write-Host "File does not exist: $Path" -ForegroundColor Red
        return
    }

    try {
        $content = Get-Content $Path
        $lineCount = $content.Length
        $wordCount = ($content -join " " -split '\s+' | Measure-Object).Count
        $characterCount = ($content -join "").Length

        Write-Host "File: $Path"
        Write-Host "Lines: $lineCount"
        Write-Host "Words: $wordCount"
        Write-Host "Characters: $characterCount"
    } catch {
        Write-Host "An error occurred while reading the file: $_" -ForegroundColor Red
    }
}

# Call the function with the parameter
Get-FileSummary -Path $FilePath
