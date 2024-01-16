param (
 [string]$MilestoneNumber
)
try
{
 $ErrorActionPreference = 'Stop';
 $Error.Clear();

 $repository = $env:GITHUB_REPOSITORY
 $token = $env:GITHUB_TOKEN
 [System.Text.StringBuilder]$stringbuilder = [System.Text.StringBuilder]::new()

 $headers = @{
  Authorization = "token $($token)"
 }

 $milestoneUri = "https://api.github.com/repos/$($repository)/milestones/$($MilestoneNumber)"

 Write-Host "MilestoneUri: $($milestoneUri)"
 $milestone = Invoke-RestMethod -Uri $milestoneUri -Headers $headers

 if ($Milestone)
 {
  $issuesUri = "https://api.github.com/repos/$($repository)/issues?state=closed&milestone=$($milestone.Number)"

  Write-Host "IssuesUri: $($issuesUri)"
  $issues = Invoke-RestMethod -Uri $issuesUri -Headers $headers
  Write-Host "Issues: $($issues.Count)"

  $groupedIssues = @{}

  foreach ($issue in $issues)
  {
   $label = if ($issue.labels.Count -eq 0)
   {
    'No Label'
   }
   else
   {
    # Concatenate all label titles for an issue into a single string
    ($issue.labels | ForEach-Object { $_.name }) -join ', '
   }

   # Add the issue to the appropriate group in the hashtable
   if (-not $groupedIssues.ContainsKey($label))
   {
    $groupedIssues[$label] = @()
   }
   $groupedIssues[$label] += $issue
  }

  $sortedKeys = $groupedIssues.Keys | Sort-Object -Property {
   if ($_ -eq 'bug') { return 0 }
   if ($_ -like 'bug*') { return 1 }
   elseif ($_ -eq 'No Label') { return 99 }
   else { return 2 }
  }
  [void]$stringbuilder.AppendLine( "# $($milestone.title)" )
  [void]$stringbuilder.AppendLine( "" )

  if ($milestone.description)
  {
   [void]$stringbuilder.AppendLine( "$($milestone.description)" )
  }

  foreach ($key in $sortedKeys)
  {
   [void]$stringbuilder.AppendLine( "" )
   [void]$stringbuilder.AppendLine( "## $($key.ToUpper())" )
   [void]$stringbuilder.AppendLine( "" )

   foreach ($issue in $groupedIssues[$key])
   {
    [void]$stringbuilder.AppendLine( "* issue-$($issue.number): $($issue.title)" )
   }
  }

 }
 return $stringbuilder.ToString();
}
catch
{
 $_.Exception.Message;
 throw $_.InvocationInfo | Out-String;
}