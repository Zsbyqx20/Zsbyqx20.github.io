# Repository Guidelines

## Project Structure & Module Organization
This repository is a Hugo site with a local theme.
- `content/`: site content (`about.md`, `posts/*.md`).
- `themes/zacharite/`: theme source (templates, CSS, JS, theme sample content). The git repo exists at this folder.
- `layouts/`, `assets/`, `static/`: optional site-level overrides for theme behavior.
- `archetypes/default.md`: front matter template for new content.
- `public/`: generated output from Hugo build (treat as build artifact unless deployment workflow requires it).
- `hugo.toml`: primary site configuration (menus, params, taxonomy, theme).

## Build, Test, and Development Commands
- `hugo server -D`: run local dev server and include drafts.
- `hugo`: production build to `public/`.
- `hugo --gc --minify`: optimized build with cleanup + minification.
- `scripts/check-site.sh`: production build plus lightweight output and draft-preview regression checks.
- `hugo new content/posts/my-post.md`: scaffold a new post from archetype.

## Coding Style & Naming Conventions
- Use 2-space indentation in TOML, CSS, and Hugo templates to match existing files.
- Prefer kebab-case filenames for content (for example, `my-second-post.md`).
- Keep front matter in TOML (`+++` blocks) with fields like `title`, `date`, `draft`, and `tags`.
- Keep theme changes in `themes/zacharite/` unless intentionally overriding at project root.

## Testing Guidelines
There is no full automated test suite yet. Use the regression script and manual validation as the baseline:
- Run `scripts/check-site.sh` before opening a PR; fix all build, output, and draft-preview errors.
- Run `hugo server -D` and manually verify navigation, post pages, and tag pages.
- For UI changes, verify both home and single-post layouts.

## Commit & Pull Request Guidelines
The repo currently has no commit history, so no established convention exists yet. Use this standard going forward:
- Commit format: Conventional Commits (for example, `feat(theme): add tag pills`).
- Keep commits focused and small; separate content edits from theme refactors.
- PRs should include: purpose, key changes, manual verification steps, and screenshots for visual/template updates.

## Configuration & Content Tips
- Update `baseURL`, author, and social links in `hugo.toml` before deployment.
- Avoid committing secrets; this is a static site, so prefer environment-based deployment config.
