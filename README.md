# Academic Personal Website

Source repository for my academic personal website.

The site presents my scientific interests, research themes, academic profile, publications, and related professional activities. It is built as a static website using [Quarto](https://quarto.org/) and is intended for deployment through GitHub Pages.

## Scientific scope

My research centres on the evolutionary ecology of mosquitoes, particularly African malaria vectors, and on the interactions between organisms and heterogeneous or changing environments.

The website distinguishes between:

* **biological questions**, including adaptation, ecological divergence, speciation, behaviour, population ecology, and the evolution of vectorial traits; and
* **approaches to scientific inference**, including field experiments, genomics and other omics, biostatistics, computational biology, and environmental data science.

The guiding theme of the site is:

**Nature ⇄ Mosquitoes ⇄ Data ⇄ Models ⇄ Science**

## Website structure

The initial site is organised around four principal pages:

* **Home** — concise scientific introduction and navigation;
* **About** — scientific profile, perspective, and intellectual trajectory;
* **Research** — a more detailed account of biological questions and methodological approaches.
* **Publications** - a bibliography of research outcomes.

Additional sections, including publications and curriculum, will be developed progressively.

## Technology

The website is authored in Quarto Markdown (`.qmd`) and rendered to static HTML using the Quarto CLI.

The source repository contains the human-authored website material and configuration. Generated HTML in `_site/` and Quarto's local working state in `.quarto/` are excluded from version control.

Frozen computational results under `_freeze/`, when present, are retained in version control so that pages containing executable analyses can subsequently be rendered without necessarily recreating their original computational environments.

## Local preview

From the repository root:

```bash
quarto preview
```

The preview server watches the source files and automatically re-renders changed pages.

To render the complete site without starting the preview server:

```bash
quarto render
```

The generated website is written to:

```text
_site/
```

## Development environment

The repository includes a VS Code `.code-workspace` file as part of the project configuration.

Workspace paths and settings should remain **relative and portable** wherever possible so that the repository can be used from different computers and storage locations without modification.

Quarto itself is treated as the publishing environment. R, Python, or other computational environments may be used by individual documents when required, but are not prerequisites for the prose-only portions of the website.

## Bibliography

Bibliographic material will be maintained separately from the prose and consumed by Quarto as BibTeX/CSL data.

The intention is to maintain a single authoritative bibliographic source rather than manually reproducing publication metadata across individual website pages.

## Repository philosophy

The website is designed to remain:

* **static** — no server-side application is required;
* **portable** — source material is independent of a particular computer;
* **reproducible** — configuration and relevant computational provenance are version controlled;
* **content-first** — scientific questions and writing remain separate from presentation and deployment machinery;
* **durable** — hosting and implementation details should be replaceable without requiring the scientific content to be rewritten.
