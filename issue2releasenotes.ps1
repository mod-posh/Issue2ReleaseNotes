param (
 [int]$MilestoneNumber,
 [bool]$Verbose = $false
)
try
{
 $ErrorActionPreference = 'Stop';
 $Error.Clear();

 $repository = $env:GITHUB_REPOSITORY
 $token = $env:GITHUB_TOKEN
 $headers = @{
  Authorization = "token $token"
 }

 $milestoneUri = "https://api.github.com/repos/$($repository)/milestones/$($MilestoneNumber)"

 if ($Verbose) {
  Write-Verbose "MilestoneUri: $($milestoneUri)"
  $milestone = Invoke-RestMethod -Uri $milestoneUri -Headers $headers -Verbose
 } else {
  $milestone = Invoke-RestMethod -Uri $milestoneUri -Headers $headers
 }

 if ($Milestone)
 {
  # Fetch issues
  $issuesUri = "https://api.github.com/repos/$($repository)/issues?state=closed&milestone=$($milestone.Number)"
  if ($Verbose) {
   Write-Verbose "IssuesUri: $($issuesUri)"
   $issues = Invoke-RestMethod -Uri $issuesUri -Headers $headers
  } else {
   $issues = Invoke-RestMethod -Uri $issuesUri -Headers $headers -Verbose
  }

  $labels = $issues | ForEach-Object { $_.labels } | Sort-Object -Property Name -Unique;

  [System.Text.StringBuilder]$stringbuilder = [System.Text.StringBuilder]::new()
  [void]$stringbuilder.AppendLine( "# $($milestone.title)" )
  [void]$stringbuilder.AppendLine( "" )

  if ($milestone.description)
  {
   [void]$stringbuilder.AppendLine( "$($milestone.description)" )
  }

  foreach ($label in $labels)
  {
   [void]$stringbuilder.AppendLine( "" )
   [void]$stringbuilder.AppendLine( "## $($label.name.ToUpper())" )
   [void]$stringbuilder.AppendLine( "" )

   foreach ($issue in $issues)
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
 throw $_.Exception.Message;
}