# Generate Release Notes GitHub Action

## Overview

The "Generate Release Notes" GitHub Action is designed to automatically generate release notes for a specified milestone in a GitHub repository. It collects all closed issues associated with the given milestone and formats them into a markdown file (`RELEASE.md`), categorized by issue labels.

## Workflow File

The `generate_release_notes.yml` file defines the workflow that is triggered by a `workflow_call` event. This allows other workflows to call this action and provide a milestone number for which the release notes should be generated.

### Workflow Inputs

- `milestone_number`: The number of the milestone for which you want to generate release notes. This input is required.

## PowerShell Script (`generate_release_notes.ps1`)

The PowerShell script, `generate_release_notes.ps1`, uses the GitHub API to fetch closed issues from a specified milestone and generates a markdown-formatted release notes file. It organizes the issues by their labels, creating a section for each label.

## Usage

To use this action in your workflow, include a step that calls this workflow with the required `milestone_number`. Example:

```yaml
jobs:
  call_generate_release_notes:
    uses: mod-posh/Issue2Release@v0.0.2.0
    with:
      milestone_number: 1 # Replace with your milestone number
```

### Note

This action assumes that the repository has the necessary permissions set for GitHub Actions to access repository issues and milestones.

## License

This project is licensed under the [Gnu GPL-3](LICENSE).
