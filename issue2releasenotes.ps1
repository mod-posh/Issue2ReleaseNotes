param (
  [Parameter(Mandatory = $true)]
  [string]$MilestoneNumber
)

function Get-GitHubPaged {
  param(
    [Parameter(Mandatory=$true)][string]$Uri,
    [Parameter(Mandatory=$true)][hashtable]$Headers
  )

  $all = New-Object System.Collections.Generic.List[object]
  $next = $Uri

  while ($null -ne $next -and $next.Trim().Length -gt 0) {
    $resp = Invoke-WebRequest -Uri $next -Headers $Headers -Method Get

    $page = $resp.Content | ConvertFrom-Json
    if ($page -is [System.Array]) {
      foreach ($item in $page) { $all.Add($item) }
    }
    elseif ($null -ne $page) {
      $all.Add($page)
    }

    $link = $resp.Headers['Link']
    $next = $null

    if ($link) {
      foreach ($part in ($link -split ',')) {
        if ($part -match '<([^>]+)>;\s*rel="next"') {
          $next = $matches[1]
          break
        }
      }
    }
  }

  return $all.ToArray()
}

try {
  $ErrorActionPreference = 'Stop'
  $Error.Clear()

  $repository = $env:GITHUB_REPOSITORY
  $token      = $env:GITHUB_TOKEN
  $verbose    = $env:VERBOSE

  [System.Text.StringBuilder]$stringbuilder = [System.Text.StringBuilder]::new()

  $headers = @{
    Authorization = "token $token"
    'User-Agent'  = 'PowerShell'
    Accept        = 'application/vnd.github+json'
  }

  $milestoneUri = "https://api.github.com/repos/$repository/milestones/$MilestoneNumber"
  $milestone = Invoke-RestMethod -Uri $milestoneUri -Headers $headers

  if ($verbose -eq 'verbose') {
    Write-Host "Issue2ReleaseNotes DEBUG"
    Write-Host "Repository      : $repository"
    Write-Host "MilestoneNumber : $MilestoneNumber"
    Write-Host "MilestoneUri    : $milestoneUri"
  }

  if (-not $milestone) {
    throw "Milestone '$MilestoneNumber' not found."
  }

  # per_page=100 + pagination via Link header
  $issuesUri = "https://api.github.com/repos/$repository/issues?state=closed&milestone=$($milestone.number)&per_page=100"
  $issuesAll = Get-GitHubPaged -Uri $issuesUri -Headers $headers

  # The Issues API includes PRs; remove them
  $issues = $issuesAll | Where-Object { -not $_.pull_request }

  if ($verbose -eq 'verbose') {
    Write-Host "IssuesUri       : $issuesUri"
    Write-Host "Issues (all)    : $($issuesAll.Count)"
    Write-Host "Issues (no PRs) : $($issues.Count)"
  }

  $groupedIssues = @{}

  foreach ($issue in $issues) {
    $label = if (($issue.labels | Measure-Object).Count -eq 0) {
      'No Label'
    } else {
      ($issue.labels | ForEach-Object { $_.name }) -join ', '
    }

    if (-not $groupedIssues.ContainsKey($label)) {
      $groupedIssues[$label] = @()
    }
    $groupedIssues[$label] += $issue
  }

  $sortedKeys = $groupedIssues.Keys | Sort-Object -Property {
    switch ($_)
    {
      'bug' { 0 }
      { $_ -like 'bug*' } { 1 }
      'No Label' { 99 }
      default { 2 }
    }
  }

  [void]$stringbuilder.AppendLine("# $($milestone.title)")
  [void]$stringbuilder.AppendLine()

  if ($milestone.description) {
    [void]$stringbuilder.AppendLine($milestone.description)
  }

  if ($issues.Count -eq 0) {
    [void]$stringbuilder.AppendLine()
    [void]$stringbuilder.AppendLine("_No closed issues found for this milestone._")
  } else {
    foreach ($key in $sortedKeys) {
      [void]$stringbuilder.AppendLine()
      [void]$stringbuilder.AppendLine("## $($key.ToUpper())")
      [void]$stringbuilder.AppendLine()

      foreach ($issue in $groupedIssues[$key]) {
        [void]$stringbuilder.AppendLine("* issue-$($issue.number): $($issue.title)")
      }
    }
  }

  if ($verbose -eq 'verbose') {
    $stringbuilder.ToString() | Write-Host
  }

  $stringbuilder.ToString() | Out-File RELEASE.md -Encoding utf8 -Force

  $releasePath = "RELEASE.md"
  $stringbuilder.ToString() | Out-File $releasePath -Encoding utf8 -Force

  # Emit outputs for composite action
  if ($env:GITHUB_OUTPUT) {
    "release_file=$releasePath" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
    "milestone_title=$($milestone.title)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
  }

}
catch {
  $_.InvocationInfo | Out-String | Write-Host
  throw $_.Exception.Message
}
