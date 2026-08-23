# Academic Personal Website

Source repository for my academic personal website.

The site presents my scientific interests, research themes, academic profile, publications, and related professional activities. It is built as a static website using [Quarto](https://quarto.org/) and is intended for deployment through GitHub Pages using a custom domain.

The guiding theme of the site is:

> **Nature ⇄ Mosquitoes ⇄ Data ⇄ Models ⇄ Science**

## Scientific scope

My research centres on the evolutionary ecology of mosquitoes, particularly African malaria vectors, and more generally on how organisms interact with, adapt to, and evolve in heterogeneous and changing environments.

The website deliberately distinguishes between two complementary dimensions:

* **biological questions**, including adaptation, ecological divergence, speciation, behaviour, biological rhythms, population ecology, and the evolution of vectorial traits;
* **approaches to scientific inference**, including field observations and experiments, genomics and other omics, biostatistics, computational biology, and environmental data science.

Methods and technologies are treated as instruments for addressing biological questions rather than as research objectives in themselves.

## Website structure

The principal sections are:

* **Home** — concise scientific introduction and site navigation;
* **About** — scientific profile, perspective, and intellectual trajectory;
* **Research** — detailed presentation of biological questions and methodological approaches;
* **Publications** — scientific publications organised by research theme.

Additional sections, including a detailed curriculum, projects, teaching, software, data resources, and longer-form notes, may be added progressively.

The **Research** and **Publications** sections are intentionally cross-linked in both directions. Research themes provide the conceptual structure, while the corresponding publication sections provide the associated scientific record.

## Technology

The website is authored primarily in Quarto Markdown (`.qmd`) and rendered to static HTML using the Quarto CLI.

The production model is:

```text
Quarto source
    │
    ├── prose
    ├── bibliography
    ├── generated publication fragments
    ├── figures and other assets
    └── optional executable analyses
            │
            ▼
         Quarto
            │
            ▼
      static HTML site
```

The site is deliberately static-first: no server-side application is required for normal operation.

## Local preview and rendering

From the repository root:

```bash
quarto preview
```

This starts a local preview server, watches the source files, and re-renders changed pages.

To render the complete site without starting the preview server:

```bash
quarto render
```

Generated website files are written to:

```text
_site/
```

The `_site/` directory is build output and is not part of the authoritative website source.

## Publications data pipeline

The Publications page is generated from curated bibliographic metadata rather than maintained manually.

The underlying workflow is:

```text
BibDesk
   │
   │  curated bibliography
   ▼
bibliography/publications.bib
   │
   │  citekey
   │  webtheme
   │  webtags
   ▼
scripts/build-publications.R
   │
   ├── validation
   ├── thematic routing
   └── Pandoc/citeproc formatting
           │
           ▼
publications/fragments/*.qmd
           │
           ▼
publications/index.qmd
           │
           ▼
         Quarto
```

### Authoritative publication metadata

The authoritative source for publication metadata is:

```text
bibliography/publications.bib
```

This file is curated through **BibDesk**.

Publication metadata should therefore be corrected at the bibliographic-source level rather than manually in the generated website fragments.

Google Scholar, ORCID, Crossref, PubMed, and other external bibliographic services may be used for discovery or verification, but they are not the authoritative source for website publication metadata.

### Website-specific publication metadata

Each publication contains a manually curated `webtheme` field identifying its primary thematic location on the website.

The controlled vocabulary is:

```text
adaptation
speciation
behaviour
rhythms
population
control
methods
natural-history
```

These correspond to:

```text
adaptation      → publications/fragments/adaptation.qmd
speciation      → publications/fragments/speciation.qmd
behaviour       → publications/fragments/behaviour.qmd
rhythms         → publications/fragments/rhythms.qmd
population      → publications/fragments/population.qmd
control         → publications/fragments/control.qmd
methods         → publications/fragments/methods.qmd
natural-history → publications/fragments/natural-history.qmd
```

Each publication belongs to **one primary `webtheme`**.

This is an intentional editorial classification rather than an automated inference from titles or keywords. The same publication may address several scientific questions, but assigning one primary theme prevents unnecessary duplication and keeps the Publications page navigable.

An optional `webtags` field provides a finer-grained controlled or semi-controlled description of topics associated with each publication, for example:

```bibtex
webtheme = {adaptation},
webtags  = {salinity, osmoregulation, local-adaptation, larval-physiology}
```

At present, `webtags` are retained as structured metadata for future use and are not required for the visual organisation of the Publications page.

Possible future uses include filtering, searching, related-publication discovery, or generation of more specialised publication views.

### Publication fragment generation

The thematic fragments are generated with:

```bash
Rscript scripts/build-publications.R
```

The generator:

1. reads publication identifiers and website metadata from `publications.bib`;
2. validates the controlled `webtheme` vocabulary;
3. reports missing or invalid metadata;
4. partitions publications by research theme;
5. passes the original bibliography to Pandoc/citeproc for bibliographic formatting;
6. generates one `.qmd` fragment for each theme;
7. preserves reverse chronological ordering within themes;
8. highlights my name in the rendered bibliography.

Bibliographic formatting remains the responsibility of **Pandoc/citeproc and CSL**. The R script does not maintain an independent representation of the publication records.

The current CSL resource is stored under:

```text
bibliography/csl/
```

### Generated publication files

Files under:

```text
publications/fragments/
```

are **generated artefacts**.

They should not be edited manually.

Their authoritative inputs are:

```text
bibliography/publications.bib
scripts/build-publications.R
bibliography/csl/
```

When publication metadata or thematic assignments change, regenerate the fragments instead:

```bash
Rscript scripts/build-publications.R
```

and then inspect the result with:

```bash
quarto preview
```

The generated fragments are nevertheless retained in version control. This allows the website to be rendered directly from a repository checkout without requiring R merely to reconstruct the Publications page.

## Publications maintenance workflow

The normal maintenance cycle for the publication record is therefore:

```text
1. Add or edit a publication in BibDesk
2. Assign or review webtheme
3. Assign or review webtags
4. Export/update bibliography/publications.bib
5. Run scripts/build-publications.R
6. Inspect the Publications page with quarto preview
7. Commit both source metadata and regenerated fragments
```

Generated fragments and their source bibliography should normally be committed together.

## Research–Publications cross-linking

The Research and Publications pages use explicit stable anchors.

Conceptually:

```text
Research theme
     │
     │  Publications on this theme →
     ▼
Publication fragment
     │
     │  Research theme →
     ▼
Research theme
```

This allows the publication record to function as an extension of the scientific narrative rather than as an isolated chronological bibliography.

Explicit identifiers are preferred over automatically generated heading anchors so that links remain stable if section titles are subsequently reworded.

## Bibliographic architecture

Two conceptually distinct bibliographic resources may be maintained:

```text
bibliography/references.bib
bibliography/publications.bib
```

Their purposes differ:

* `references.bib` contains literature cited in the scientific prose of the website;
* `publications.bib` contains works authored or co-authored by me and drives the Publications page.

This separation avoids conflating the literature used to support scientific arguments with the publication record itself.

Both remain ordinary BibTeX resources consumable directly by Quarto/Pandoc.

## Generated and reproducible content

The repository distinguishes between:

**Authoritative source**

```text
*.qmd
*.bib
*.scss
_quarto.yml
scripts/
images/
other manually curated resources
```

and **derived content**, such as:

```text
publications/fragments/*.qmd
_freeze/
_site/
```

Derived files have different versioning policies:

* `_site/` is disposable rendered website output and is not version controlled;
* `publications/fragments/` is generated but intentionally version controlled;
* `_freeze/`, when present, is intentionally version controlled to preserve computational results used by Quarto documents.

This distinction allows the repository to remain both reproducible and easy to deploy.

## Computational documents

Most pages are prose-first Quarto documents and require no executable scientific environment.

Individual pages may nevertheless contain R, Python, or other executable analyses where appropriate.

The site uses Quarto's freezing mechanism so that expensive or historically environment-dependent analyses do not necessarily need to be recomputed every time the website is rendered.

The global execution strategy is therefore based on:

```yaml
execute:
  freeze: auto
```

when computational content is present.

## Development environment

The project is primarily developed using:

```text
VS Code
Quarto CLI
Git
BibDesk
R, when required
```

The repository includes a `.code-workspace` file as part of the portable project configuration.

Workspace paths and settings should remain **relative and machine-independent** wherever possible so that the repository can be used from different computers and storage locations without modification.

The website is currently developed from a portable workspace rather than being tied to a particular computer.

Quarto itself is treated as the publishing environment. R, Python, GIS tools, or other computational environments may contribute to individual pages, but none owns the website architecture.

## Styling

The visual design intentionally remains close to standard Quarto/Bootstrap conventions: minimalist, responsive, and content-focused.

Custom styling is used sparingly, principally where it supports:

* the two-column homepage composition;
* profile and identity elements;
* research/publication cross-links;
* small site-specific typographic or navigational refinements.

The goal is to preserve Quarto's responsive behaviour rather than replace it with a heavily customised visual framework.

## Institutional context

The website is a personal academic site rather than an institutional publication platform.

Current institutional information and responsibilities are linked to the relevant institutional pages rather than duplicated extensively in the website.

This keeps institutional information authoritative at its source while allowing the personal website to concentrate on scientific identity, research, publications, and intellectual trajectory.

## Deployment

The intended production architecture is:

```text
Git repository
      │
      ▼
GitHub
      │
      ▼
GitHub Pages
      │
      ▼
custom domain
```

Deployment infrastructure should remain separable from the scientific content. A future change of hosting provider should therefore not require substantial modification of the underlying Quarto source.

## Repository philosophy

The website is designed to remain:

* **scientific-question-first** — biological questions define the structure; technologies remain tools;
* **static** — no server-side application is required for ordinary use;
* **portable** — the source is independent of a particular computer or storage location;
* **reproducible** — configuration, relevant generated artefacts, and computational provenance are version controlled;
* **single-source** — bibliographic and other structured information should have clearly identified authoritative sources;
* **generated where appropriate** — repetitive derived content should be built programmatically rather than copied manually;
* **content-first** — scientific writing remains separate from presentation and deployment machinery;
* **durable** — implementation and hosting technologies should be replaceable without requiring the scientific content to be rewritten;
* **minimalist** — additional infrastructure should be introduced only when it provides a clear scientific, editorial, or maintenance benefit.

## Copyright and licensing

Unless otherwise stated, website text and original graphical content are copyright Carlo Costantini.

Third-party publications, institutional material, logos, trademarks, bibliographic metadata, and externally sourced resources remain subject to their respective rights and licences.

For the public-facing summary, see [Copyright and reuse](rights.qmd).

For the complete repository licensing terms, see [LICENSE.md](LICENSE.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
