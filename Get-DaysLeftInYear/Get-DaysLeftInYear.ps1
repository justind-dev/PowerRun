# DisplayText: "Get Days Left In Year"
# Description: "Displays the current date and the number of days left in the current year."
# ConfiguredParameters: ""

# Calculate the current date and days left in the year
$currentDate = Get-Date
$endOfYear = Get-Date -Month 12 -Day 31 -Year $currentDate.Year -Hour 23 -Minute 59 -Second 59
$daysLeft = ($endOfYear - $currentDate).Days

# Print the current date
Write-Host "Current Date: $($currentDate.ToString('MM/dd/yyyy'))"

# Print the number of days left in the year
Write-Host "Days Left in the Year: $daysLeft"
