# Native tutorial bundles

This directory contains publication-ready HTML bundles that are copied into the
website output after Quarto renders. The `_` prefix keeps their Markdown support
files out of Quarto's render targets. Do not add these bundles to
`project.resources`: Quarto's resource processing can rewrite their CSS URLs.

## Colliders in medical entomology

Source: <https://github.com/costantinicarlo/colliders-entomology-tutorial>

Imported from `main` at commit `dd271b0`, with both decks exported locally using
Obsidian Slides Extended. The hub, banner and complete English and French export
directories are retained unchanged. macOS filesystem metadata is omitted.
The tutorial's CC BY 4.0 notice is in `colliders-entomology-tutorial/LICENSE`;
the Fieldnote Academic theme's MIT notice is in
`colliders-entomology-tutorial/assets/fieldnote-academic/LICENSE`. Bundled support
libraries and institutional marks retain their own rights and notices.

`scripts/publish-colliders-tutorial.py` copies the bundle to
`resources/colliders-entomology-tutorial/` inside Quarto's configured output
directory. GitHub Pages receives it through the existing Pages artifact upload;
no access to the tutorial repository or Obsidian vault is needed during deployment.

To refresh the bundle, export **both languages** in the tutorial workspace, then
run from the website root:

```bash
tutorial_source=/path/to/colliders-entomology-tutorial
tutorial_bundle=_tutorials/colliders-entomology-tutorial
python3 "$tutorial_source/tests/check_exports.py" "$tutorial_source/export"
mkdir -p "$tutorial_bundle/assets/storyline" "$tutorial_bundle/assets/fieldnote-academic"
cp "$tutorial_source/index.html" "$tutorial_bundle/index.html"
cp "$tutorial_source/assets/storyline/splashscreen.png" "$tutorial_bundle/assets/storyline/"
cp "$tutorial_source/LICENSE" "$tutorial_bundle/LICENSE"
cp "$tutorial_source/assets/fieldnote-academic/LICENSE" "$tutorial_bundle/assets/fieldnote-academic/"
rsync -a --delete --exclude='.DS_Store' --exclude='._*' "$tutorial_source/export/" "$tutorial_bundle/export/"
quarto render
python3 "$tutorial_source/tests/check_exports.py" _site/resources/colliders-entomology-tutorial/export
```

Update the imported commit above, review both presentations, and commit the
refreshed bundle. Use the configured output directory for the final check if it
differs from `_site/`.
