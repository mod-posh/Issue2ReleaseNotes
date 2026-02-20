# Generate Release Notes GitHub Action

## Overview

The **Issue2ReleaseNotes** GitHub Action automatically generates release notes for a specified milestone in a GitHub repository.

It:

* Retrieves the milestone from the GitHub API
* Collects **all closed issues** associated with that milestone
* Supports **API pagination** (no 30-issue limit)
* Groups issues by label
* Generates a markdown file (`RELEASE.md`)

The output file can either:

* Be committed directly to the repository (default behavior)
* Be generated only (for artifact upload or use as release body)

---

## Features

* ✅ Groups issues by label
* ✅ Issues without labels grouped under `No Label`
* ✅ Pagination support (`per_page=100` + Link header traversal)
* ✅ Optional verbose logging
* ✅ Optional artifact-only mode
* ✅ Outputs available for downstream workflow steps

---

## Inputs

| Name               | Required | Default  | Description                                          |
| ------------------ | -------- | -------- | ---------------------------------------------------- |
| `milestone_number` | ✅ Yes    | —        | The milestone number to generate release notes for   |
| `github_token`     | ✅ Yes    | —        | GitHub token (usually `${{ secrets.GITHUB_TOKEN }}`) |
| `verbose`          | ❌ No     | `None`   | Set to `verbose` to enable debug output              |
| `write_mode`       | ❌ No     | `direct` | `direct` = commit & push; `none` = generate only     |

---

## Outputs

| Name              | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| `release_file`    | Path to generated release notes file (default: `RELEASE.md`) |
| `milestone_title` | Title of the milestone                                       |

These outputs allow you to upload artifacts or create releases without hardcoding filenames.

---

# Behavior Modes

## `write_mode: direct` (Default)

* Generates `RELEASE.md`
* Commits the file
* Pushes to the current branch

> ⚠️ Will fail if branch protection requires pull requests.

---

## `write_mode: none`

* Generates `RELEASE.md`
* Does **not** commit
* Does **not** push
* Intended for artifact uploads or release body usage

---

# Usage Examples

---

## Basic Usage (Default: Commit to Repo)

```yaml
jobs:
  generate-release-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: mod-posh/Issue2ReleaseNotes@v0.0.3.4
        with:
          milestone_number: 1
          verbose: 'verbose'
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

---

## Artifact-Only Mode (Recommended for Protected Branches)

```yaml
jobs:
  generate-release-notes:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Generate Release Notes
        id: notes
        uses: mod-posh/Issue2ReleaseNotes@v0.0.3.4
        with:
          milestone_number: ${{ github.event.milestone.number }}
          write_mode: none
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Upload Release Notes Artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-notes-${{ steps.notes.outputs.milestone_title }}
          path: ${{ steps.notes.outputs.release_file }}
```

---

## Use as GitHub Release Body

```yaml
- name: Generate Release Notes
  id: notes
  uses: mod-posh/Issue2ReleaseNotes@v0.0.3.4
  with:
    milestone_number: ${{ github.event.milestone.number }}
    write_mode: none
    github_token: ${{ secrets.GITHUB_TOKEN }}

- name: Create GitHub Release
  run: |
    gh release create v${{ github.event.milestone.title }} \
      --notes-file "${{ steps.notes.outputs.release_file }}"
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

# Automatic Milestone Trigger Example

```yaml
on:
  milestone:
    types: [closed]

jobs:
  create-release-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: mod-posh/Issue2ReleaseNotes@v0.0.3.4
        with:
          milestone_number: ${{ github.event.milestone.number }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

---

# Important Notes

> [!Caution]
> This action will overwrite any existing `RELEASE.md` file.

> [!Note]
> GitHub’s Issues API includes Pull Requests. This action automatically filters PRs out.

> [!Note]
> Pagination is supported, so milestones with more than 30 issues are handled correctly.

---

# License

This project is licensed under the [GNU GPL-3](LICENSE).
