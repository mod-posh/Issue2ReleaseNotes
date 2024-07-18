# Changelog

All changes to this project should be reflected in this document.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [[0.0.3.3]](https://github.com/mod-posh/issue2releasenotes/releases/tag/v0.0.3.3) - 2024-07-18

Github Env Files I think are [limited](https://docs.github.com/en/actions/learn-github-actions/variables#limits-for-configuration-variables) along with the rest of the variables, which means a simple Release Notes document could exceed the maxium 256KB allowed for all variables in a workflow very quickly. This change removes outputting that to the environment.

## [[0.0.3.2]](https://github.com/mod-posh/issue2releasenotes/releases/tag/v0.0.3.2) - 2024-07-18

Output BODY to the env files like we do in the GetProjectVersion task. This change will allow you to pull the body from the env in your pipelines

```yaml
name: Milestone Closure Trigger

on:
  milestone:
    types: [closed]

jobs:
  create-release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Get Project Version
        id: get_version
        uses: mod-posh/GetProjectVersion@v0.0.2.2
        with:
          Filename: 'SpnLibrary\SpnLibrary.psd1'
          verbose: "verbose"

      - name: Create Release Notes
        uses: mod-posh/Issue2ReleaseNotes@v0.0.3.1
        with:
          milestone_number: ${{ github.event.milestone.number }}
          verbose: 'verbose'
          github_token: ${{ secrets.PAT }}

      - name: Create Release
        uses: mod-posh/NewTaggedRelease@v0.0.2.15
        with:
          name: 'Release v${{ env.VERSION }}'
          body: ${{ env.BODY }}
          version: ${{ env.VERSION }}
          verbose: 'verbose'
          github_token: ${{ secrets.PAT }}
```

## [[0.0.3.1]](https://github.com/mod-posh/issue2releasenotes/releases/tag/v0.0.3.1) - 2024-07-17

Minor change in this release, removed the checkout task.

## [[0.0.3.0]](https://github.com/mod-posh/issue2releasenotes/releases/tag/v0.0.3.0) - 2024-07-17

This release ensures compliance with GitHub API requirements by adding a User-Agent header, simplify the verbose mode check for better readability, and improve the sorting logic with a switch statement. Most importantly, changing the file output encoding to UTF-8 ensures that Cyrillic symbols and other non-ASCII characters are correctly handled and displayed in the release notes.

What's Changed:

- Added the `User-Agent` header in the API requests to comply with GitHub's requirements.
- Simplified the verbose mode check for consistency.
- Improved readability of the sorting logic using a `switch` statement.
- Changed the file output encoding to `UTF-8` to properly handle Cyrillic symbols and other non-ASCII characters.

These changes ensure that the script handles Cyrillic symbols correctly and follows best practices for making API requests to GitHub.

## [[0.0.2.31]](https://github.com/mod-posh/issue2releasenotes/releases/tag/v0.0.2.31) - 2024-01-16

This release should be considered the first working version of this Action. Several issues have been resolved that revolved around my misunderstanding of Github Actions in general.

What's Changed:

1. Changed the Action to PowerShell
2. Pass Github_Token so it's accessibly via the environment variables
3. Pass Verbose, this allows for more detailed logging, 'verbose' is the only option supported
4. More detailed verbose output is now available
5. The action now works in `windows-latest` or `ubuntu-latest`
6. Changed env variables to be all UPPERCASE in the action
7. Issues are now grouped by label, when no label is present they are grouped under `No Label`

---
