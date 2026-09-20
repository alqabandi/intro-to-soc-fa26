# Introduction to Sociology · Fall 2026

Quarto source for the SOC 101 course website:

<https://alqabandi.co/intro-to-soc-fa26/>

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

## Render Chapter 01 materials

The Chapter 01 sources are split by audience:

- `slides/source/chapter-01/` and `assets/chapter_01_assets/` contain the student-facing deck source.
- `instructor/chapter-01/` contains the private notes and quiz sources. The entire `instructor/` folder is gitignored and must never be committed.

Render the student deck, private notes, and private quiz from the repository root:

```sh
./scripts/render-chapter-01-materials.sh
```

The script uses Quarto to create the HTML files and Chrome's RevealJS print mode to create the deck PDF. It produces:

- `slides/ch01-understanding-sociology.html`
- `slides/ch01-understanding-sociology.pdf`
- `instructor/chapter-01/rendered/ch01_understanding_sociology_notes.html`
- `instructor/chapter-01/rendered/ch01_understanding_sociology_notes.pdf`
- `instructor/chapter-01/rendered/ch01-understanding-sociology-quiz.pdf`

Visually inspect the student HTML and PDF before publishing them. Set `CHROME_BIN` if Chrome or Chromium is not in a standard location.

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

## Release a graded quiz

Quiz sources and current quiz PDFs stay under the gitignored `instructor/` folder while the quiz is active. Only after the quiz has been graded and returned:

1. Copy the final PDF into `resources/` using a lowercase filename without spaces.
2. Add that exact file path to `project.resources` in `_quarto.yml`.
3. Add a link in the relevant `schedule.qmd` Materials cell.
4. Render the website and verify that only the released PDF—not its source or the instructor notes—appears in `_site/`.

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
