# Third-party resources and redistribution status

This file records provenance; it is not a substitute for the upstream terms.

## QCF V4 Tajweed fonts and Mushaf layout

- Resource pages:
  - <https://qul.tarteel.ai/resources/font/240>
  - <https://qul.tarteel.ai/resources/mushaf-layout/19>
- Provider: Quranic Universal Library (QUL), Tarteel AI.
- Upstream font attribution: King Fahd Glorious Quran Printing Complex
  (KFGQPC/QPC).
- QUL's font resource page instructs application developers to download the
  selected format and serve the files from their own site or CDN.
- The mirrored files must be used without altering Quranic content. Keep this
  provenance notice and re-check upstream terms before every refresh.
- `p328.woff2` is reproducibly converted from QUL's `p328.woff`, because the
  QUL WOFF2 endpoint currently returns HTTP 404 while the WOFF endpoint is
  available. The OpenType tables are preserved; only the web-font container
  changes. Source WOFF SHA-256:
  `7464a25856ad790e3d90166389806c433af49fdb8f00061c5f7598031d6488d4`.

## Quran Foundation content

Quran Foundation API responses are deliberately not published here. Their
Developer Terms restrict raw-data redistribution and require Content Sync for
eligible offline content. Font files obtained from Quran Foundation may be
cached or bundled as an integrated part of an application under their stated
conditions, but may not be offered as a standalone asset package.

References:

- <https://api-docs.quran.com/legal/developer-terms/>
- <https://api-docs.quran.com/docs/tutorials/fonts/font-rendering/>
- <https://api-docs.quran.com/docs/tutorials/content-sync/getting-started/>

## Istidhhar Arabic Zipformer model

- Upstream artifact:
  <https://github.com/Iam-Muslim/Natlu/releases/download/models-latest/zipformer_p_arabic_v3.int8.onnx>
- License: Quran-Lab No-Profit License 1.1 (NPL-1.1), copied to
  `licenses/Quran-Lab-NPL-1.1.txt`.
- Expected SHA-256:
  `6a5ddafa9c5e5c01260d30264031b341785bdc152e9ef1d569b41c8c278508eb`.
- Expected size: `72705392` bytes.

NPL-1.1 applies its no-profit restriction to the application as a whole and
expressly includes indirect financial gain. The application owner has
confirmed that the application is free, has no advertising, paid feature,
subscription, invoice, or team financing from this model. Any future
monetization requires removing the model or obtaining a separately compatible
replacement before release.

## Istidhhar Warsh phoneme reference

- Upstream project: <https://github.com/M97Chahboun/quran-database-verifier>.
- Mirrored asset: `warsh_phonemes.json`, used only as the sequential Warsh
  recognition reference downloaded with Istidhhar resources.
- Expected SHA-256:
  `72c32af05c0baa32f0e991f2e1bc36679f771947f1f31986390258db495aaa58`.
- Expected size: `9410013` bytes.
- The mirrored file is byte-identical to the previously used immutable
  application resource; keep this provenance notice with future versions.

## Warsh Tajweed semantic annotations

- Generator: `quranic-phonemizer==3.0.5`, MIT licensed:
  <https://github.com/QUD-Technologies/quranic-phonemizer>.
- Quran source profile: `king-fahd-warsh-v2`, Warsh through al-Azraq.
- The generated source strings were checked against all 6,214 Warsh ayat in
  the application's Quran database. Every non-trivial spelling difference was
  additionally compared with the official QUL resource 581 preview.
- The included `UthmanicWarshV21East.ttf` remains attributed to the King Fahd
  Glorious Quran Printing Complex.
- The annotations are a technical candidate, not a religious certification.
  They must be visually reviewed against an authorised Warsh Tajweed mushaf
  and approved by a qualified Warsh teacher before being described as
  certified.
