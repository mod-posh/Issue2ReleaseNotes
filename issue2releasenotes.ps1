param (
  [string]$MilestoneNumber
)

try
{
  $ErrorActionPreference = 'Stop';
  $Error.Clear();

  $repository = $env:GITHUB_REPOSITORY
  $token = $env:GITHUB_TOKEN
  $verbose = $env:VERBOSE
  [System.Text.StringBuilder]$stringbuilder = [System.Text.StringBuilder]::new()

  $headers = @{
    Authorization = "token $token"
    'User-Agent'  = 'PowerShell'
  }

  $milestoneUri = "https://api.github.com/repos/$repository/milestones/$MilestoneNumber"
  $milestone = Invoke-RestMethod -Uri $milestoneUri -Headers $headers

  if ($verbose -eq 'verbose')
  {
    Write-Host "Issue2ReleaseNotes DEBUG"
    Write-Host "Repository      : $repository"
    Write-Host "MilestoneNumber : $MilestoneNumber"
    Write-Host "MilestoneUri    : $milestoneUri"
  }

  if ($milestone)
  {
    $issuesUri = "https://api.github.com/repos/$repository/issues?state=closed&milestone=$($milestone.number)"
    $issues = Invoke-RestMethod -Uri $issuesUri -Headers $headers

    if ($verbose -eq 'verbose')
    {
      Write-Host "IssuesUri       : $issuesUri"
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
        ($issue.labels | ForEach-Object { $_.name }) -join ', '
      }

      if (-not $groupedIssues.ContainsKey($label))
      {
        $groupedIssues[$label] = @()
      }
      $groupedIssues[$label] += $issue
    }

    $sortedKeys = $groupedIssues.Keys | Sort-Object -Property {
      switch ($_)
      {
        'bug' { return 0 }
        { $_ -like 'bug*' } { return 1 }
        'No Label' { return 99 }
        default { return 2 }
      }
    }

    [void]$stringbuilder.AppendLine("# $($milestone.title)")
    [void]$stringbuilder.AppendLine()

    if ($milestone.description)
    {
      [void]$stringbuilder.AppendLine($milestone.description)
    }

    foreach ($key in $sortedKeys)
    {
      [void]$stringbuilder.AppendLine()
      [void]$stringbuilder.AppendLine("## $($key.ToUpper())")
      [void]$stringbuilder.AppendLine()

      foreach ($issue in $groupedIssues[$key])
      {
        [void]$stringbuilder.AppendLine("* issue-$($issue.number): $($issue.title)")
      }
    }

    if ($verbose -eq 'verbose')
    {
      $stringbuilder.ToString() | Write-Host
    }

    $stringbuilder.ToString() | Out-File RELEASE.md -Encoding utf8 -Force
  }
}
catch
{
  $_.InvocationInfo | Out-String
  throw $_.Exception.Message
}
