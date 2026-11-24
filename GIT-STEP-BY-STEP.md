# Git step by step: publishing the lab by hand

`PUBLISH-TO-GITHUB.cmd` runs all of this for you. This file walks through the same steps one command at a time, with what each one does, so you can do it yourself and explain it in an interview.

Run the commands in **PowerShell** (Start → type `PowerShell`). Type each one, press Enter, and read the output before you go to the next.

---

## Part A: One-time setup on your PC

**A1. Install Git and the GitHub CLI.** Skip this if the one-click file already installed them.
```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
```
*Git* tracks versions of your files on your PC. The *GitHub CLI* (`gh`) talks to your GitHub account from the terminal. **Close PowerShell and open it again** afterwards so it picks up the new programs.

**A2. Check they work.**
```powershell
git --version
gh --version
```
Each one should print a version number.

**A3. Sign in to GitHub.**
```powershell
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
```
A browser opens. Enter the code shown in PowerShell and approve. `setup-git` lets `git push` use that sign-in, so you never type a password.

**A4. Tell Git who you are.** This name goes on every commit.
```powershell
gh api user --jq .id                                  # prints your GitHub ID number, e.g. 12345678
git config --global user.name "Jamie Rowe"
git config --global user.email "12345678+jamierowe15@users.noreply.github.com"   # use YOUR number
git config --global --list
```
The `noreply` address keeps your Gmail off public commits, and still links each commit to your GitHub profile.

---

## Part B: Publishing a repo by hand (practice run)

If you've already published with the one-click file, practise on a **copy**, so you don't touch the real repo.

**B1. Make a practice copy and go into it.**
```powershell
cd $HOME\Downloads            # wherever you unzipped the kit
Copy-Item -Recurse maple-host-release-lab maple-lab-practice
cd maple-lab-practice
Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue
```
Deleting `.git` removes the copy's history, so you start completely fresh.

**B2. Turn the folder into a Git repository.**
```powershell
git init -b main
```
This creates a hidden `.git` folder, which is the database of every version. `-b main` names the main branch `main`.

**B3. See what Git sees.**
```powershell
git status
```
Everything is listed in red as **untracked**: Git sees the files but isn't tracking them yet.

**B4. Stage the files.** Staging is the list of what goes into the next commit.
```powershell
git add .
git update-index --chmod=+x scripts/local-build.sh
git status
```
The files turn green (staged). The second line marks the build script as runnable, which GitHub's Linux build needs.

**B5. Commit: save a version.**
```powershell
git commit -m "Initial lab kit"
git log --oneline
```
A commit is a saved snapshot with a message. `git log` lists your history.

**B6. Create the empty repo on GitHub.**
```powershell
gh repo create maple-lab-practice --public --description "Practice repo"
```
You can also do this on github.com: **+ → New repository**, with no README.

**B7. Connect your folder to GitHub and push.**
```powershell
git remote add origin https://github.com/jamierowe15/maple-lab-practice.git
git remote -v
git push -u origin main
```
`origin` is the nickname for the GitHub copy. `push` uploads your commits. `-u` remembers the link, so from now on plain `git push` works.

**B8. Check it.** Open `https://github.com/jamierowe15/maple-lab-practice`. Your files are there, and the **Actions** tab shows the build check running.

**B9. Clean up the practice repo when you're done.**
```powershell
gh auth refresh -h github.com -s delete_repo
gh repo delete jamierowe15/maple-lab-practice --yes
```
The first line gives `gh` permission to delete repos, which it doesn't have by default.

---

## Part C: Daily lab workflow (on the real repo)

```powershell
cd $HOME\Downloads\maple-host-release-lab
```

**At the end of each lab day:**
```powershell
git status                                  # what changed today?
git add evidence controls change scheduling
git commit -m "Day 2: PAT pass in QA, Db2 reconciliation evidence"
git push
```
Write messages that say *what* happened. A recruiter reading your history should be able to follow the lab day by day.

**Tag the releases.** This is the Git version of a release label in Endevor.
```powershell
# Day 4, after CHG0001 is closed
git tag -a v1.0 -m "Release v1.0 - CHG0001 normal change"
git push origin v1.0

# Day 5, after CHG0002 is closed
git tag -a v1.1 -m "Release v1.1 - CHG0002 emergency fix for INC0001 (S0C7)"
git push origin v1.1
git tag            # list tags
```

**Optional: the fix as a branch and pull request.** This mirrors an approval before promotion.
```powershell
git switch -c fix/chg0002-numeric-edits
# ...edit files...
git add .
git commit -m "CHG0002: add numeric edits to MPINTCLC"
git push -u origin fix/chg0002-numeric-edits
gh pr create --title "CHG0002: numeric edits (INC0001)" --body "Emergency fix for the S0C7 in STEP030. PAT vs V11PROD: RC 0."
gh pr merge --merge --delete-branch
git switch main
git pull
```
The pull request shows the build check passing *before* the merge, the same idea as PAT sign-off before PROD.

---

## Part D: When something goes wrong

| Message | What it means | Fix |
|---|---|---|
| `'git' is not recognized` | Git isn't installed, or PowerShell was opened before it was installed | Do A1, then close and reopen PowerShell |
| `Author identity unknown` | Step A4 was skipped | Run A4 |
| `remote origin already exists` | The folder is already linked | `git remote set-url origin <url>` |
| `rejected ... fetch first` | GitHub has commits your PC doesn't | `git pull --rebase`, then `git push` |
| `Permission denied` in the GitHub build | The build script lost its "runnable" flag | Run the `update-index` line from B4, then commit and push |
| `nothing to commit, working tree clean` | Nothing changed since the last commit | That's fine |

**Commands to remember:** `git status` · `git add` · `git commit -m` · `git push` · `git pull` · `git log --oneline` · `git tag`
