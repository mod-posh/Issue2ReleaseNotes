# Changelog

All changes to this project should be reflected in this document.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
