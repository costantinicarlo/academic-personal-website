# Third-Party Notices

The repository's [CC BY 4.0 license](LICENSE) applies to original tutorial materials only. It does not relicense third-party software or override the licenses and copyright notices that apply to it.

Slides Extended 2.5.2 is bundled in `.obsidian/plugins/slides-extended/`. It is MIT-licensed; its complete upstream license text is retained at `.obsidian/plugins/slides-extended/LICENSE`. Reveal.js 5.2.0 is included in the plugin and exported presentations under the MIT License; its complete upstream license text is retained at `.obsidian/plugins/slides-extended/dist/LICENSE`.

The Fieldnote Academic theme is MIT-licensed; its license text is retained at `assets/fieldnote-academic/LICENSE`. Other bundled components also retain license texts, including the Reveal menu plugin (MIT), MathJax (Apache-2.0), and the League Gothic and Source Sans Pro fonts (SIL OFL). This notice is not a complete inventory of every bundled dependency or its terms. Preserve embedded notices and consult the individual license files when redistributing or modifying the bundled software.

After generating each HTML deck, run `python3 scripts/prepare_export_notices.py`. It copies this notice, the project license, the Fieldnote license, and all retained `LICENSE*`, `NOTICE*`, and `COPYING*` files from the vendored Slides Extended directory into that deck's `LICENSES/` directory. Those copies accompany the self-contained exported deck.