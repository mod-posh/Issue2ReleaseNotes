# Generate Release Notes GitHub Action

## Overview

The "Issue2ReleaseNotes" GitHub Action is designed to automatically generate release notes for a specified milestone in a GitHub repository. It collects all closed issues associated with the given milestone and formats them into a markdown file (`RELEASE.md`), categorized by issue labels.

## Workflow File

You can trigger the `action.yml` by `workflow_call` to generate the `RELEASE.md` file automatically. The workflow contains several steps to act:

1. Checkout the repository
2. Call the `issue2releasenotes.ps1` script
3. Defining the git user for GitHub Actions
4. Commit the Release Notes

### Workflow Inputs

- `milestone_number`: The milestone number for which you want to generate release notes. This input is required.
- `verbose`: A value of verbose will output additional information. This input is not required.
- `github_token`: This is the built-in Github Token; this is passed as an environment variable. This input is required.

## PowerShell Script (`issue2releasenotes.ps1`)

The PowerShell script uses the GitHub API to retrieve the milestone to work with. It then collects all closed issues associated with the milestone and groups them by label. If no label is associated with an issue, it is placed in the `No Label` group. Finally, the `RELEASE`.md` file is generated using information collected from the milestone and issues.

## Usage

There are a few different ways to use this action; here are a few examples to get you started.

> [!Caution]
> This action will replace any `RELEASE.md` file found

```yaml
jobs:
  call_generate_release_notes:
    uses: mod-posh/Issue2Release@v0.0.2.31
    with:
      milestone_number: 1 # Replace with your milestone number
      verbose: 'verbose'
      github_token: ${{ secrets.GITHUB_TOKEN }}
```

> [!Note]
> This example is used directly as part of a larger workflow
> The verbose option will output a little more detail in the logs

```yaml
on:
  milestone:
    types: [closed]

jobs:
  create-release-notes:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Create Release Notes
        uses: mod-posh/Issue2ReleaseNotes@v0.0.2.30
        with:
          milestone_number: ${{ github.event.milestone.number }}
          verbose: 'none'
          github_token: ${{ secrets.GITHUB_TOKEN }}

```

> [!Note]
> This example runs when a milestone is closed
> Verbose set to none outputs minimal information to the log

## License

This project is licensed under the [Gnu GPL-3](LICENSE).
