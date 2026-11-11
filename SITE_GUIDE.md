# Site guide

This site runs on **[al-folio](https://github.com/alshedivat/al-folio) v1**. The theme's layouts, styles and features
ship as Ruby gems (`al_folio_core`, `al_math`, `al_comments`, …), so **this repo holds only content, settings and a
handful of our own files**. If a file isn't mentioned here, it comes from a gem and you don't need to touch it.

Contents:
[Quick reference](#quick-reference) ·
[Run locally](#run-locally) ·
[Pages, one by one](#pages-one-by-one) ·
[Change the look](#change-the-look) ·
[Turn sections on/off](#turn-sections-onoff) ·
[Folder map](#folder-map) ·
[Deploying](#deploying) ·
[Upgrading the theme](#upgrading-the-theme) ·
[Troubleshooting](#troubleshooting) ·
[Future: publication sync](#future-automatic-publication-sync)

---

## Quick reference

| I want to…                                     | Edit                                                                                              |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Change my intro, photo, research interests     | `_pages/about.md` → front matter (`hero:`, `interests:`) and the text below it                    |
| Add a publication                              | `_bibliography/papers.bib`                                                                        |
| Add a news item                                | new file in `_news/` → [News](#news)                                                              |
| Add a semester / course / course materials     | `_data/teaching.yml`                                                                              |
| Add an award                                   | `_data/awards.yml`                                                                                |
| Add a certificate                              | drop the file into `assets/certificates/<category>/`                                              |
| Update the CV                                  | `_data/cv.yml` (+ your PDF at `assets/pdf/Md_Nazmus_Shakib_CV.pdf`)                               |
| Add a project                                  | new file in `_projects/`                                                                          |
| Write a blog post / poem / essay               | `_posts/` · `_poems/` · `_essays/`                                                                |
| Add photos                                     | drop images into `assets/photography/`                                                            |
| Add a vlog video                               | `_data/videos.yml`                                                                                |
| Social icons (email, Scholar, GitHub…)         | `_data/socials.yml`                                                                               |
| **Theme color / font**                         | top of `_sass/_custom.scss` → [Change the look](#change-the-look)                                 |
| Hide a whole section (blog, photos…)           | `_config.yml` → `sections:`                                                                       |
| Menu order                                     | `nav_order:` in each `_pages/*.md`; the **More ▾** menu is `_pages/more.md`                       |

---

## Run locally

```bash
cd /Volumes/NSR/Websites/ns-riad.github.io
bundle install                              # first time, or after the Gemfile changes
bundle exec jekyll serve --livereload       # → http://localhost:4000, refreshes on save
```

- Always use **`bundle exec jekyll …`**, never plain `jekyll`. The Mac also has an old system Ruby (2.6) and a
  global `jekyll` that can't load this site's theme gems.
- Stop the server with **Ctrl + C**. (Ctrl + Z only *pauses* it, and the paused server keeps port 4000 busy; see
  [Troubleshooting](#troubleshooting).)
- Requires Ruby ≥ 3.2, plus ImageMagick and Ghostscript for images and certificate previews:
  `brew install imagemagick ghostscript`.
- Changes to `_config.yml` need a server restart; everything else reloads by itself.

---

## Pages, one by one

### Home (`_pages/about.md` + `_layouts/home.liquid`)

All of the intro is front matter at the top of `_pages/about.md`:

```yaml
hero:
  eyebrow: Ph.D. Student · Computer Engineering      # small colored line above the name
  tagline: One sentence about your work               # optional, delete/comment to hide
  affiliation: <a href="https://www.uah.edu/">UAH</a> · Graduate Teaching Assistant
  image: profile.jpg                                   # in assets/img/
  buttons:                                             # optional row of buttons; first one is filled
    - { label: CV, url: /cv/, icon: fa-solid fa-file-lines }

interests:                                             # one dot-separated line under the affiliation
  - Multimodal Data Fusion
  - Machine Intelligence

announcements: { enabled: true, limit: 5 }            # News block
selected_papers: true                                  # papers with selected={true} in papers.bib
latest_posts: { enabled: true, limit: 3 }              # only shown when the blog has posts
```

- Your **name** comes from `first_name` / `last_name` in `_config.yml` (the last name is shown bold).
- The **social icons** under the interests come from `_data/socials.yml`.
- The text **below** the front matter is the bio (Markdown).
- Any line can be removed or commented out (`#`) and the layout closes the gap.

### Social icons (`_data/socials.yml`)

One line per profile; the order in the file is the order on the page. Comment a line out (`#`) to hide that icon.
`rss_icon: true` adds an RSS feed icon (currently off). Keys follow [jekyll-socials](https://github.com/george-gca/jekyll-socials),
e.g. `youtube_id`, `x_username`, `orcid_id`.

### Research (`_pages/research.md` + `_bibliography/papers.bib`)

Every publication is one BibTeX entry. Useful extra fields:

| Field                  | Effect                                                                                          |
| ---------------------- | ----------------------------------------------------------------------------------------------- |
| `selected = {true}`    | also listed under "Selected publications" on the home page                                      |
| `abbr = {IV}`          | colored venue badge; colors/links per venue in `_data/venues.yml` (text is always white)        |
| `preview = {img.png}`  | thumbnail, file in `assets/img/publication_preview/`                                            |
| `abstract`, `html`, `pdf`, `code`, `bibtex_show = {true}` | buttons under the entry                                    |
| `note = {Submitted}`   | small note after the venue                                                                      |
| `award = {…}`, `award_name = {Best Paper}` | award badge                                                                  |

- **Venue badge** (the colored box left of each paper):
  - *Text*: the paper's `abbr = {IV}` in `papers.bib`. Keep it short (≈ 10 characters); longer names wrap onto two lines.
  - *Color and link*: `_data/venues.yml`. The key must match the `abbr` text exactly:
    ```yaml
    "SoutheastCon":
      url: https://ieeesoutheastcon.org/   # optional: badge becomes a link
      color: "#00629B"                     # any CSS color
    ```
    An `abbr` with no entry in `venues.yml` uses the site's theme color.
  - *Size*: `$badge-font-size` and `$badge-padding` in the *RESEARCH* block of `_sass/_custom.scss`.
- Order: **newest year first** on both the Research page and the home page (`sort_by: year,month` in `_config.yml`).
  Within the same year, add `month = {jun}` to entries to control the order; otherwise the order in `papers.bib` is used.
- Your name is highlighted automatically (`scholar:` → `last_name` / `first_name` in `_config.yml`).
- Co-authors with a homepage get a link via `_data/coauthors.yml` (key = last name in lower case).
- BibTeX doesn't allow `%` comments **inside** an entry; put notes above or below it.

### Teaching (`_pages/teaching.md` + `_data/teaching.yml`)

Each **role** (GTA, Lecturer, …) is a card on a vertical timeline, newest first:

```yaml
roles:
  - title: Lecturer
    org: Green University of Bangladesh
    org_url: https://green.edu.bd/
    dept: Department of Computer Science & Engineering
    period: Jun 2022 – 2024
    location: Dhaka, Bangladesh
    summary: One-line description.
    highlights: [ "Bullet one", "Bullet two" ]   # Markdown allowed
    courses: [ … ]     # (A) a simple list of courses, shown as boxes. Used for the UAH role
    terms:   [ … ]     # (B) courses per semester, shown as the semester timeline
```

**(B) The semester timeline.** List `terms` **newest first**: that is the order shown left → right.

```yaml
    terms:
      - term: Spring 2024
        courses:
          - { name: Algorithms, parts: [Theory, Lab] }
          - { name: Database Systems, parts: [Theory, Lab] }
      - term: Fall 2023
        courses:
          - { name: Data Mining, parts: [Theory], note: Course coordinator }
```

How it behaves on the page:

- **All courses** (open by default) lists every distinct course **once**, with its Theory/Lab tags and the
  semesters you taught it. A semester where the course has a `note` is shaded darker, and the note is
  shown under the course ("Course coordinator (Fall 2023)").
- Clicking a **semester** on the timeline shows only that semester's courses.
- Clicking the **open tab again**, or **Collapse ▴**, folds the list away.
- Each semester has its own link to share, e.g. `/teaching/#green-university-of-bangladesh-fall-2023`
  (pattern: `#<org-name>-<term>`, lower case with dashes).
- Courses are matched across semesters **by name**, so spell a course the same way every time.

**Course fields** (for both `courses:` and `terms:`):

| Field   | Example                                   | Shown as                                         |
| ------- | ----------------------------------------- | ------------------------------------------------ |
| `name`  | `Digital Logic Design Lab`                | course title (required)                          |
| `code`  | `EE 203`                                  | colored code before the title                    |
| `parts` | `[Theory, Lab]`                           | small tags (in "All courses": Theory before Lab) |
| `note`  | `Lab instructor` / `Course coordinator`   | colored line under the course; delete to hide    |
| `links` | see below                                 | links under the course (slides, syllabus, …)     |

```yaml
          - name: Object-Oriented Programming
            parts: [Theory, Lab]
            links:
              - { label: Slides, url: /assets/pdf/teaching/oop-slides.pdf, icon: fa-solid fa-file-powerpoint }
              - { label: Course site, url: https://… }
```

Put course files in `assets/pdf/teaching/` (or anywhere under `assets/`). The `icon` is optional
([Font Awesome](https://fontawesome.com/search?ic=free) class, default is a link icon).

**Supervision.** Fill `supervision:` at the bottom of `teaching.yml` (name, level, year, topic, optional outcome/url)
and a "Student supervision" section appears; leave it `[]` to hide it.

Files: `_includes/site/teaching.liquid` (roles, timeline, tab script) and `_includes/site/course.liquid` (one course row).
Styles: the *TEACHING* block in `_sass/_custom.scss`.

### Projects (`_pages/projects.md` + `_projects/*.md`)

One Markdown file per project:

```yaml
---
layout: page
title: Project title
description: One-line summary shown on the card.
img: assets/img/projects/thumb.jpg     # optional card image (16:10 crop, top-aligned)
importance: 1                          # order within its category (1 = first)
category: research                     # must be listed in display_categories in _pages/projects.md
github: https://github.com/…           # optional "Code" button on the card
links:                                 # optional extra buttons on the card, e.g. a paper or demo
  - { label: Paper, url: https://…, icon: fa-solid fa-file-pdf }
related_publications: true             # lists papers you {% cite key %} in the text
---
```

The whole card opens the project page; the buttons open their own links. Card design: `_includes/site/project_card.liquid`.
The body supports Markdown, `$$math$$`, images and `{% cite shakib2026iv %}`. Current categories: `research`, `coursework`.

### Awards & certificates (`_pages/awards.md`)

**Honors list:** `_data/awards.yml`

```yaml
honors:
  - title: Best Paper Award — 1st Prize
    issuer: ICEEICT 2021, MIST
    year: Jan 2022
    description: …
    certificate: iceeict_best_paper        # optional: file name (no extension) of a certificate → "View certificate"
    extra: [ { label: 2018–19, certificate: Deans_Award_3rd_year } ]   # optional extra certificates
```

**Certificate gallery: automatic.**

1. Drop a PDF or image into `assets/certificates/<category>/`, e.g. `assets/certificates/ml-ai/deep-learning.pdf`.
2. It appears on `/awards/`, and the **folder name is the filter tab** (`ml-ai`, `research`, `teaching`, `programming`, `honors`…).
   A preview is made from the PDF's first page at build time.
3. Optional details in `_data/certificates.yml`, keyed by the file name without extension:

```yaml
categories:            # tab labels and order
  ml-ai: ML & AI
items:
  deep-learning:
    title: Deep Learning Specialization
    issuer: Coursera · DeepLearning.AI
    date: 2020-05        # "2020", "2020-05" or "2020-05-14"
    verify: https://coursera.org/verify/…
```

An entry in `items:` **without** a matching file is listed under "Also completed" until you add the file.
Without an entry, the title is made from the file name.

### CV (`_pages/cv.md` + `_data/cv.yml`)

- The web CV mirrors the PDF layout and is generated from `_data/cv.yml` (RenderCV format; the comments at the top
  explain each entry type). Section names and order are exactly as written in the file.
- **PDF button:** put your PDF at `assets/pdf/Md_Nazmus_Shakib_CV.pdf` and it appears automatically.
- Publications in the CV are listed in `cv.yml` (so the RenderCV PDF can use them). Your name in `**bold**` is highlighted.
- Renderer: `_includes/site/cv.liquid`; styles: the *CV* block in `_sass/_custom.scss`.

### News (`_news/` folder)

`_pages/news.md` only displays the list, so you never edit it. **Each news item is its own small file in `_news/`.**
To add one, create a file named `YYYY-MM-DD-short-name.md`, e.g. `_news/2026-12-01-iccps-accepted.md`:

```markdown
---
layout: post
title: "Paper accepted at ICCPS 2027"
date: 2026-12-01
inline: true
---

Our paper "Degradation-Aware Lightweight Multimodal Fusion…" was accepted at [ICCPS 2027](https://iccps.acm.org/).
```

- `inline: true` shows the text directly in the list (best for one or two sentences).
  Without it, the list shows the **title** as a link to a full page, written in Markdown under the `---`.
- The **date** decides the order (newest first). Emoji such as `:tada:` work.
- The **home page** shows the newest 5. Change `announcements: limit:` in `_pages/about.md`.
  The full list is at `/news/` (More ▾ → News).
- To remove an item, delete its file. To hide all news, set `sections: news: false` in `_config.yml`.
- The list design comes from the theme (`news.liquid` inside the `al_folio_core` gem); our styles only adjust spacing.

### Photography (`_pages/photography.md`)

1. Drop photos into **`assets/photography/`** (landscape and portrait both fine).
2. Big camera files? Run **`scripts/optimize_photos.sh`** first: it shrinks anything over 3000 px / 6 MB,
   strips metadata, and moves the original to `assets/photography/_originals/` (git-ignored, kept on your disk).
3. Every photo appears on the "desk" (scattered prints that straighten on hover) and gets its own page
   at `/photography/<file-name>/` with camera details, previous/next and ← → keys.
4. Optional details in `_data/photos.yml`, keyed by file name without extension: `title`, `place`, `date`, `caption`,
   `album` (adds filter chips), `story` (link to a blog post, shows "Read the story"), `order`, `hidden: true`.

Only resized copies are published; the originals and their GPS data never leave your repo.

### Blog, poems, essays, vlog, news

| Section  | Where                                   | Notes                                                                             |
| -------- | --------------------------------------- | --------------------------------------------------------------------------------- |
| Blog     | `_posts/YYYY-MM-DD-title.md`            | code, `$$math$$`, Jupyter (`{% jupyter_notebook %}`), Mermaid, charts, `toc:`, `giscus_comments: true`. Categories: research, phd-journey, tutorials, thoughts |
| Poems    | `_poems/title.md`                       | `title`, `date`, optional `lang: bn`; line breaks are kept                        |
| Essays   | `_essays/title.md`                      | `title`, `date`, `lang: bn` for Bangla (Noto Serif Bengali is applied automatically) |
| Vlog     | `_data/videos.yml`                      | YouTube id per video; thumbnails load first, the player only on click             |

---

## Change the look

Everything visual is controlled from the **top of `_sass/_custom.scss`**. Save, and `jekyll serve --livereload`
refreshes the page.

### Color (the whole site)

```scss
$accent-light: rgb(156, 0, 39);     // light mode: links, buttons, active menu item, your name, dots, tags …
$accent-dark:  rgb(196, 0, 49);     // dark mode: use a lighter shade of the same hue so it stays readable
```

These two values feed the theme's `--global-theme-color`, so **every** component follows them. Any CSS color works
(`rgb(…)`, `#hex`, `hsl(…)`). Ready-made pairs are listed in the file:

| Name          | Light              | Dark                |
| ------------- | ------------------ | ------------------- |
| Forest green  | `rgb(45, 134, 82)` | `rgb(110, 201, 148)`|
| Burgundy      | `rgb(128, 0, 32)`  | `rgb(222, 120, 145)`|
| Original      | `#b509ac` (purple) | `#2698ba` (cyan)    |

Colors that are deliberately **not** tied to the theme:

| What                                    | Where                                                                    |
| --------------------------------------- | ------------------------------------------------------------------------ |
| Venue badges on Research (IEEE, IV…)    | `_data/venues.yml` → `color:` per venue                                  |
| Page background / text grays            | add `--global-bg-color` / `--global-text-color` to the same `:root { }` (light) and `html[data-theme="dark"] { }` (dark) blocks |
| Photo prints (paper color)              | `.desk { --paper: … }` in `_sass/_custom.scss`                           |

### Font

```scss
$font-choice: "lora";   // "lora" | "latin-modern" | "new-computer-modern" | "roboto"
```

- **lora**: serif, the font of the previous site (Google Fonts).
- **latin-modern** / **new-computer-modern**: the LaTeX look, matches MathJax equations; served from `assets/fonts/`.
- **roboto**: al-folio's default sans-serif.

Each option has a `scale` in the `$fonts` map (Computer Modern runs small, so it is bumped ~10%). To add another
Google font: append it to `google_fonts` → `fonts:` in `_config.yml`, then add an entry to `$fonts`.
Bangla text always uses Noto Serif Bengali; code always uses a monospace font.

### Light / dark mode button

The moon/sun button cycles **System → Dark → Light**. *System* (half sun/moon icon) is the default and follows the
visitor's device setting; the browser remembers their choice. `enable_darkmode: false` in `_config.yml` removes it.

---

## Turn sections on/off

```yaml
# _config.yml
sections:
  blog: true
  writing: false        # poems + essays
  photography: true
  vlog: false
  news: true
```

`false` removes that section's pages **and** its entry in the **More ▾** menu (and News from the home page).
Nothing is deleted; set it back to `true` to bring it back. Restart `jekyll serve` after changing `_config.yml`.
If you hide a section, also check the bio in `_pages/about.md` doesn't mention it.

---

## Folder map

```
_config.yml              site settings, section toggles, fonts URL, plugins (read the comments)
_pages/                  one file per page (about, research, teaching, projects, awards, cv, more, …)
_posts/ _poems/ _essays/ _news/ _projects/     content collections
_bibliography/papers.bib all publications
_data/                   structured content: teaching, awards, certificates, cv, photos, videos,
                         socials, coauthors, venues
_layouts/                OUR layouts: home (landing page), poem, photo (one photo)
_includes/site/          OUR components: teaching, course, awards, cv, gallery (photo desk), videos, lightbox
_includes/header.liquid  OVERRIDE of the theme navbar (section toggles + magnifying-glass-only search)
_sass/_custom.scss       OUR styles (color, font, every component), loaded last
assets/css/main.scss     OVERRIDE of the theme entry: identical + one line that loads _custom.scss
_plugins/section_toggles.rb  drops pages/posts of disabled sections at build time
_plugins/media_library.rb    finds certificates + photos, makes web-sized copies (ImageMagick/Ghostscript)
assets/certificates/<category>/  certificate PDFs/images (folder = filter tab)
assets/photography/      photos (only resized copies are published; _originals/ is git-ignored)
assets/fonts/            self-hosted Latin Modern + New Computer Modern (licenses inside)
assets/img/              profile photo, project thumbnails, publication previews
assets/pdf/              CV PDF and other documents
scripts/optimize_photos.sh   shrink new photos before committing
bin/                     helper scripts from upstream (Scholar citation updater)
.github/workflows/       deploy.yml (build + publish), render-cv.yml, update-citations.yml (manual)
.al-folio-overrides.yml  records which theme files we override (for upgrade checks)
```

---

## Deploying

1. Commit and push to **`master`**.
2. GitHub Actions (`deploy.yml`) builds the site and publishes it to the **`gh-pages`** branch (~3–5 min; watch the
   *Actions* tab).
3. One-time setting: repo **Settings → Pages → Source: Deploy from a branch → `gh-pages`**.

---

## Upgrading the theme

1. Bump the `al_*` gem versions in `Gemfile` (see al-folio's releases), then `bundle update`.
2. `bundle exec al-folio upgrade overrides audit`. If it flags one of our two overrides (`header.liquid`,
   `main.scss`) as changed upstream, compare with `bundle exec al-folio upgrade overrides diff <path>`, re-apply our
   small change, then `bundle exec al-folio upgrade overrides accept <path>`.
3. After editing `_includes/header.liquid` yourself, run `… overrides accept _includes/header.liquid` too.

---

## Troubleshooting

| Problem                                                    | Fix                                                                                    |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `jekyll serve` fails / "Address already in use" / page never loads | An old server is still running or paused (Ctrl + Z). In that terminal: `fg` then Ctrl + C. Or from anywhere: `lsof -nP -iTCP:4000 -sTCP:LISTEN` → `kill -9 <PID>` |
| `Could not find gem …` / wrong Ruby                        | Use `bundle exec`; run `bundle install`; `ruby -v` should be 3.x                        |
| A `_config.yml` change has no effect                       | Restart the server (config isn't live-reloaded)                                        |
| New certificate/photo has no preview                       | `brew install imagemagick ghostscript`, then rebuild                                   |
| Page looks unstyled/old after deploying                    | Hard refresh (Cmd + Shift + R); browsers cache CSS                                     |
| Build error mentioning `papers.bib`                        | A `%` comment or a missing `,`/`}` inside a BibTeX entry                                |

---

## Future: automatic publication sync

Not built yet, by design. Publications are rare enough to add by hand. When you want it, add
`scripts/sync_publications.py` and a weekly workflow that queries **OpenAlex / Semantic Scholar** by ORCID
(`0000-0002-5209-9597`), finds DOIs missing from `papers.bib`, and **opens a PR** with the new BibTeX entries for you
to review. Citation counts already have a manual workflow: *Actions → Update Google Scholar Citations*.
