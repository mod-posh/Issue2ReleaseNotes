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
   if ($issue.labels.Count -eq 0)
   {
    # Handle issues with no labels
    $label = 'No Label'
   }
   else
   {
    # Concatenate all label titles for an issue
    $label = ($issue.labels | ForEach-Object { $_.name }) -join ', '
   }

   # Add the issue to the appropriate group in the hashtable
   if (-not $groupedIssues.ContainsKey($label))
   {
    $groupedIssues[$label] = @()
   }
   $groupedIssues[$label] += $issue
  }

  [void]$stringbuilder.AppendLine( "# $($milestone.title)" )
  [void]$stringbuilder.AppendLine( "" )

  if ($milestone.description)
  {
   [void]$stringbuilder.AppendLine( "$($milestone.description)" )
  }

  foreach ($key in $groupedIssues.Keys)
  {
   [void]$stringbuilder.AppendLine( "" )
   [void]$stringbuilder.AppendLine( "## $($key.ToUpper())" )
   [void]$stringbuilder.AppendLine( "" )

   foreach ($issue in $groupedIssues[$key])
   {
    if ($issue.labels.name -contains $label.name)
    {
     [void]$stringbuilder.AppendLine( "* $($issue.title) #$($issue.number)" )
    }
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