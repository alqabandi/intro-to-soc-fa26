# Introduction to Sociology · Fall 2026

Quarto source for the SOC 101 course website:

<https://alqabandi.github.io/intro-to-soc-fa26/>

## Site structure

- `index.qmd` — course homepage
- `schedule.qmd` — weekly topics, milestones, and links to materials
- `syllabus.qmd` — HTML syllabus source
- `rubric.qmd` — HTML project-rubric source
- `assets/brite.scss` — local theme adapted from Bootswatch Brite 5.3.8
- `downloads/` — downloadable syllabus and rubric PDFs
- `slides/` — lecture slides added during the semester
- `resources/` — readings, activities, study guides, and other course files

## Preview locally

From this repository, run:

```sh
quarto preview
```

Quarto will open a local preview and refresh it when a source file changes.

## Add a slide or resource

1. Put the file in `slides/` or `resources/`.
2. Open `schedule.qmd`.
3. Replace the relevant “coming soon” text with a link, for example:

```markdown
[Slides](slides/ch01-understanding-sociology.pdf)
```

Use lowercase, descriptive filenames without spaces.

## Add downloadable PDFs

When the syllabus and rubric are final, render or copy their PDFs into:

- `downloads/introduction-to-sociology-syllabus-fall-2026.pdf`
- `downloads/public-sociology-project-rubric.pdf`

Then replace each disabled “PDF coming soon” button in the corresponding `.qmd` file with a working link:

```html
<a class="btn btn-primary" href="downloads/example.pdf" download>Download PDF</a>
```

The HTML pages remain readable in a browser while the PDFs provide printable copies.

## Publish with GitHub Pages

The workflow in `.github/workflows/publish.yml` renders and deploys the site whenever changes are pushed to `main`.

In the GitHub repository, open **Settings → Pages** and set **Source** to **GitHub Actions**. No generated `_site` files need to be committed.
