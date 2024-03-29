function Show-Menu {
    param(
        [bool]$ShowDescriptions = $False
    )

    # Below we set the working location to the path this script is in.
    Set-Location -Path $PSScriptRoot

    Clear-Host
    Write-Host "|-----------------------|"
    Write-Host "|                       |"
    Write-Host "|      PowerRunner      |"
    Write-Host "|                       |"
    Write-Host "|-----------------------|"
    Write-Host ""

    $scripts = Get-ChildItem -Path . -Filter *.ps1 -Recurse | ForEach-Object {
        $content = Get-Content $_.FullName -Head 3
        $displayText = $content | Where-Object { $_ -match 'DisplayText: "(.*)"' } | ForEach-Object { $matches[1] }
        if (-not [string]::IsNullOrWhiteSpace($displayText)) {
            @{
                Path = $_.FullName
                DisplayText = $displayText
                Description = ($content | Where-Object { $_ -match 'Description: "(.*)"' } | ForEach-Object { $matches[1] })
                Parameters = ($content | Where-Object { $_ -match 'ConfiguredParameters: "(.*)"' } | ForEach-Object { $matches[1] })
            }
        }
    }

    $index = 1
    $scriptMap = @{}
    foreach ($script in $scripts) {
        if ($null -ne $script) {
            Write-Host "$index.) $($script.DisplayText)"
            if ($ShowDescriptions -and $script.Description) {
                Write-Host "`t$($script.Description)" -ForegroundColor Gray
            }
            $scriptMap.Add($index, $script)
            $index++
        }
    }

    # Adjust numbering for standard entries dynamically, starting from 1 and so on, separte index for descriptions.
    $toggleDescriptionsIndex = $index++
    $refreshScriptsIndex = $index++
    $helpIndex = $index++  # Help option
    $exitIndex = $index

    Write-Host "$toggleDescriptionsIndex.) Toggle Descriptions"
    Write-Host "$refreshScriptsIndex.) Refresh Scripts"
    Write-Host "$helpIndex.) Help"
    Write-Host "$exitIndex.) Exit"
    Write-Host ""
    $choice = Read-Host "Please Enter A Choice"
    $choice = [int]$choice

    switch ($choice) {
        $toggleDescriptionsIndex {
            # the below line !$ShowDescriptions just gets the oppposite of whatever it currently is. So
            # essential a laymans 'toggle'.
            [bool]$descritionsValue = !$ShowDescriptions # a cast here because pwsh was being finicky
            Show-Menu -ShowDescriptions $descritionsValue
        }
        $refreshScriptsIndex {
            Show-Menu -ShowDescriptions $ShowDescriptions
        }
        $helpIndex {
            Clear-Host
            Write-Host "Help Information:" -ForegroundColor Green
            Write-Host "To ensure your PowerShell scripts are displayed correctly in the PowerRunner menu, please configure the first three lines of your script with the following comments:" -ForegroundColor Green
            Write-Host '1. DisplayText: "Name of your script" - This is the name that will appear in the menu.' -ForegroundColor Green
            Write-Host '2. Description: "A brief description of what your script does." - This will be shown when "Toggle Descriptions" is active.' -ForegroundColor Green
            Write-Host '3. ConfiguredParameters: "Any parameters your script needs, formatted as a single string." - These parameters will be passed to your script when it is run.' -ForegroundColor Green
            
            Wait-ForKeyPress
            Show-Menu -ShowDescriptions $ShowDescriptions
        }
        $exitIndex {
            Write-Host "Goodbye!" -ForegroundColor Green
            return
        }
        default {
            if ($scriptMap.ContainsKey($choice)) {
                $script = $scriptMap[$choice]
                try {
                    if ($script.Parameters) {
                        # We use invoke expression below because parameters were not passing properly calling the script as in the else command below.
                        $command = "powershell.exe -File `"$($script.Path)`" $($script.Parameters)"
                        & Invoke-Expression $command
                    } else {
                        & powershell.exe -File $script.Path
                    }
                    Wait-ForKeyPress
                    Show-Menu -ShowDescriptions $ShowDescriptions
                } catch {
                    Write-Host "Error running script: $_" -ForegroundColor Red
                    Wait-ForKeyPress
                    Show-Menu -ShowDescriptions $ShowDescriptions
                }
            } else {
                Write-Host "Invalid choice, please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
                Show-Menu -ShowDescriptions $ShowDescriptions
            }
        }
    }
}

function Wait-ForKeyPress {
    Write-Host "Press Enter to continue..." -ForegroundColor Cyan
    Read-Host -Prompt " "
}

Show-Menu
