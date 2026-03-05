# Contributing to nucleus-shell

Thank you for your interest in contributing! Following these guidelines ensures high-quality contributions and smooth collaboration.

## How to Contribute

* **Bug Reports:** Include clear reproduction steps, logs, and environment details.
* **Feature Requests:** Open an issue with a concise description and suggested use case.
* **Pull Requests:** Focus on a single topic and reference related issues.

### Workflow Overview

1. Fork the repository and branch from `main`.
2. Follow project coding style.
3. Update or add documentation.
4. Include tests when applicable.
5. Submit your PR with a clear summary.

---

## Code Style

* Use descriptive names for variables and functions.
* Keep configuration files modular and readable.
* Comment non-obvious code.
* Use `Metrics.function(value)` for spacing, margin, radius, and duration (except timers). [See Metrics docs](../shell/config/Metrics.md).
* Prefer module loaders for modules with enable/disable config values to prevent crashes and reduce RAM usage.

---
## Commit Message Guidelines

We follow the **Conventional Commits** specification.

Format:

```
type(scope): short description
```

Example:

```
feat(launcher): add fuzzy search
fix(settings): resolve crash when opening panel
refactor(renderer): simplify pipeline logic
```

### Allowed Types

| Type     | Description                           |
| -------- | ------------------------------------- |
| feat     | New feature                           |
| fix      | Bug fix                               |
| refactor | Code change without altering behavior |
| docs     | Documentation changes                 |
| style    | Formatting / linting changes          |
| perf     | Performance improvements              |
| test     | Adding or updating tests              |
| build    | Build system or dependency changes    |
| ci       | CI configuration changes              |
| chore    | Maintenance tasks                     |

### Rules

* Use **present tense** ("add feature", not "added feature").
* Keep the **summary under ~72 characters**.
* Add a **scope** when applicable (e.g., `launcher`, `settings`, `renderer`).

---

# Collaboration Workflow

> [!CAUTION]
> Direct pushes to `main` are prohibited. All work must be done in feature branches.

## 1. Branch Naming

Format:

```
collaborator/<username>/<type>/<short-description>
```

| Segment               | Description                 | Example                       |
| --------------------- | --------------------------- | ----------------------------- |
| `collaborator`        | Always present              | collaborator                  |
| `<username>`          | GitHub username             | alice                         |
| `<type>`              | Type of work                | feat, chore, improvement, fix |
| `<short-description>` | 1–2 word summary of changes | settings-ui, typo-fix         |

**Examples:**

```
collaborator/alice/feat/settings-ui
collaborator/bob/fix/sidebar-color
collaborator/john/improvement/color-gen
```

---

## 2. Local Setup (First Time)

```bash
git clone git@github.com:xZepyx/nucleus-shell.git
cd nucleus-shell
git checkout main
git pull origin main
```

---

## 3. Creating a New Branch

```bash
git checkout -b collaborator/<username>/<type>/<short-description>
```

**Example:**

```bash
git checkout -b collaborator/alice/feat/settings-ui
```

---

## 4. Work and Commit

```bash
git add .
git commit -m "feat: add UI for settings panel"
```

---

## 5. Push Your Branch

```bash
git push origin collaborator/<username>/<type>/<short-description>
```

**Example:**

```bash
git push origin collaborator/alice/feat/settings-ui
```

---

## 6. Open a Pull Request

1. Go to GitHub and click **Compare & pull request**.
2. Ensure the base branch is `main`.
3. Submit for review.

> ❌ Do not merge your own PR.

---

## 7. Branch Cleanup

After your PR is merged:

```bash
git checkout main
git pull origin main
git branch -d collaborator/<username>/<type>/<short-description>
git fetch --prune
```

GitHub may auto-delete the remote branch if enabled.

---

## 8. Keeping Your Branch Updated (Optional)

```bash
git checkout collaborator/<username>/<type>/<short-description>
git fetch origin
git merge origin/main
```

> Resolve conflicts and push updates before modifying the PR.

---

## Summary Checklist

* Branch from `main`.
* Follow naming convention.
* Work locally, commit, and push.
* Open PR to `main`.
* Delete branch after merge.
* Keep `main` clean and protected.

---

## Community Standards

* Be professional and respectful.
* See the [Code of Conduct](CODE_OF_CONDUCT.md).

Thank you for contributing!
