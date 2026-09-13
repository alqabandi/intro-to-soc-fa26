# Introduction to Sociology · Fall 2026

Quarto source for the SOC 101 course website:

<https://alqabandi.github.io/intro-to-soc-fa26/>

## Site structure

- `index.qmd` — course homepage
- `schedule.qmd` — weekly topics, assessments, and links to materials
- `syllabus.qmd` — HTML syllabus source
- `rubric.qmd` — archived project-rubric source, excluded from the Fall 2026 site
- `assets/brite.scss` — local theme adapted from Bootswatch Brite 5.3.8
- `assets/syllabus-print.css` — print-specific Brite syllabus styling
- `downloads/` — downloadable syllabus PDF
- `scripts/render-syllabus-pdf.sh` — local HTML-to-PDF renderer
- `slides/` — lecture slides added during the semester
- `resources/` — readings, activities, study guides, and other course files

## Preview locally

From this repository, run:

```sh
quarto preview
```

Quarto will open a local preview and refresh it when a source file changes.

## Add slides to the schedule

1. Export the finished slides as a PDF.
2. Give the PDF a lowercase, descriptive filename without spaces, such as:

   ```text
   ch01-understanding-sociology.pdf
   ```

3. Copy the PDF into the repository's `slides/` folder.
4. Open `schedule.qmd` and find the row for the relevant week.
5. In that row's **Materials** column, replace:

   ```markdown
   [Slides coming soon]{.status-coming-soon}
   ```

   with a link to the file:

   ```markdown
   [Slides](slides/ch01-understanding-sociology.pdf)
   ```

6. Save `schedule.qmd` and run `quarto preview`.
7. Open the schedule page and click the new link to confirm that the correct PDF opens.
8. Commit and push both the PDF and `schedule.qmd`. GitHub Actions will publish the updated website.

The path and filename in the Markdown link must exactly match the file in `slides/`, including capitalization.

### Add more than one item to a week

Place readings, activities, study guides, and similar files in `resources/`. Multiple links can share one Materials cell:

```markdown
[Slides](slides/ch01-understanding-sociology.pdf) · [Activity](resources/week-01-activity.pdf)
```

Links can also point to public webpages:

```markdown
[Slides](slides/ch01-understanding-sociology.pdf) · [Reading](https://example.com/reading)
```

## Refresh the downloadable syllabus PDF

The syllabus page links to:

- `downloads/introduction-to-sociology-syllabus-fall-2026.pdf`

After changing `syllabus.qmd` or its styles, regenerate the PDF locally:

```sh
./scripts/render-syllabus-pdf.sh
```

The syllabus's “Updated on” date comes from the modification time of `syllabus.qmd`. The script renders the latest page and prints the styled HTML to PDF using Chrome or Chromium, so the website and PDF show the same update date. Set `CHROME_BIN` if the browser executable is not in a standard location.

## Publish with GitHub Pages

The workflow in `.github/workflows/publish.yml` renders and deploys the site whenever changes are pushed to `main`.

In the GitHub repository, open **Settings → Pages** and set **Source** to **GitHub Actions**. No generated `_site` files need to be committed.
