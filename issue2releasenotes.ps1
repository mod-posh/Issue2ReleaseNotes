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
 $milestone = Invoke-RestMethod -Uri $milestoneUri -Headers $headers

 if ($env:Verbose.ToLower() -eq 'verbose')
 {
  Write-Host "Issue2ReleaseNotes DEBUG"
  Write-Host "Repository      : $($repository)"
  Write-Host "MilestoneNumber : $($MilestoneNumber)"
  Write-Host "MilestoneUri    : $($milestoneUri)"
 }

 if ($Milestone)
 {
  $issuesUri = "https://api.github.com/repos/$($repository)/issues?state=closed&milestone=$($milestone.Number)"
  $issues = Invoke-RestMethod -Uri $issuesUri -Headers $headers

  if ($env:Verbose.ToLower() -eq 'verbose')
  {
   Write-Host "IssuesUri       : $($issuesUri)"
   Write-Host "Issues          : $($issues.Count)"
  }

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
 if ($env:Verbose.ToLower() -eq 'verbose')
 {
  $stringbuilder.ToString();
 }
 $stringbuilder.ToString() |Out-File RELEASE.md -Encoding ascii -Force
}
catch
{
 $_.InvocationInfo | Out-String;
 throw $_.Exception.Message;
}