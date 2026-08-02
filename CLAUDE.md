# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Also see `AGENTS.md` for style/PR conventions (2-space indent in TOML/CSS/templates, Conventional Commits, kebab-case content filenames).

## Commands

```bash
hugo server -D                 # dev server, drafts included
hugo                           # build to public/
hugo --gc --minify             # production-equivalent build (what CI runs)
scripts/check-site.sh          # production build + lightweight regression checks
hugo new content/posts/foo.md  # scaffold from archetypes/default.md
scripts/svg2ico.sh in.svg out.ico   # regenerate static/favicon.ico (needs ImageMagick)
```

There is no full test suite. Verification = a clean `scripts/check-site.sh`, plus manual checks of home, single post, tag pages, search, and both light/dark themes. Two `languageCode`/`.Language.*` deprecation warnings are pre-existing noise, not regressions.

Hugo **extended** is required (min 0.146 per theme). The project and CI version are pinned in `.hugo-version`. `public/` and `.hugo_build.lock` are gitignored build artifacts.

## Layout of the repo

The theme lives in `themes/zacharite/` as a **git submodule** pointing at `github.com/Zsbyqx20/hugo-zacharite`. Almost all templates, CSS, and JS are there, so most visual work means committing in two repos: once inside the submodule, then bumping the submodule pointer here. Only content, `hugo.toml`, `static/`, `layouts/robots.txt`, and the workflow live in this repo.

The theme uses Hugo's post-0.146 layout naming: `layouts/page.html`, `home.html`, `section.html`, `term.html`, `taxonomy.html`, `baseof.html`, and partials under `layouts/_partials/`.

Config is layered: `themes/zacharite/config/_default/hugo.toml` ships theme defaults (search settings, output formats, media types, chroma styles), and the site's root `hugo.toml` overrides them. When adding a theme param, give it a default in the theme config and read it defensively in templates (`default`/`index` on a `| default dict`), since the theme is meant to work standalone.

## Cross-file mechanisms worth knowing

**Search** is fully client-side and spans four files: the custom `SearchIndex` output format (declared in both configs) renders `layouts/home.searchindex.json` to `/search-index.json` with pre-lowercased title/tags/summary fields; `content/search.md` sets `type = "search"` to select `layouts/search/single.html`; the query/filter logic is at the bottom of `assets/js/main.js`, tuned by `params.search` (debounce, min query length, max results).

**Code block themes**: `markup.highlight.noClasses = false` means Chroma emits classes, and the actual colors come from `assets/css/chroma/{light,dark}/<style>.css`. `params.codeBlocks.lightStyle`/`darkStyle` pick which pair `head/css.html` concatenates with `main.css` into a single fingerprinted `site.css`. Adding a style means dropping a Chroma CSS file into both the light and dark directories.

**Theme switching** is a three-part contract: an inline script in `_partials/head.html` runs before paint to set `documentElement.dataset.theme` / `.themeMode` from `localStorage[params.theme.storageKey]`, `main.css` keys all colors off those data attributes, and `main.js` cycles `auto → light → dark`. Changing the storage key or attribute names requires touching all three.

**Robots/indexing**: `layouts/robots.txt` is generated from `params.robots.blockAllBots` / `blockAIBots`, and `head.html` emits `noindex` meta when `blockAllBots` is set or a page sets `robotsNoIndex = true`. The live site currently blocks all bots by design — don't "fix" that.

## Content conventions

Posts are page bundles (`content/posts/<slug>/index.md` with images alongside). TOML front matter (`+++`); beyond `title`/`date`/`draft`/`tags`, `page.html` reads `showtoc`, `isCJKLanguage` (switches the word count label to characters), `license` (rendered as a licensing note), and `robotsNoIndex`.

## Deployment

`.github/workflows/hugo.yaml` builds on push to `master` and deploys to GitHub Pages, checking out submodules recursively and overriding `baseURL` from the Pages config. Nothing is published from a local build.
