import os
from github import Github

def issue2releasenotes(repo_name, milestone_number):
    g = Github(os.getenv('GITHUB_TOKEN'))
    repo = g.get_repo(repo_name)

    try:
        milestone = repo.get_milestone(milestone_number)
    except Exception as e:
        print(f"Error fetching milestone: {e}")
        return

    issues = repo.get_issues(state='closed', milestone=milestone)
    labels = sorted(set(label.name for issue in issues for label in issue.labels))

    release_notes = []
    for label in labels:
        release_notes.append(f"\n## {label.upper()}\n")
        for issue in issues:
            if label in [lbl.name for lbl in issue.labels]:
                release_notes.append(f"* {issue.title} #{issue.number}\n")

    return ''.join(release_notes)

if __name__ == "__main__":
    repo_name = os.getenv('INPUT_REPOSITORY')
    milestone_number = int(os.getenv('INPUT_MILESTONE_NUMBER'))
    release_notes = issue2releasenotes(repo_name, milestone_number)

    if release_notes:
        with open("RELEASE.md", "w", encoding="ascii") as file:
            file.write(release_notes)
        print("Release notes written to RELEASE.md")
    else:
        print("No release notes generated.")
