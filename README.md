# QuranVersion resources

This repository is the versioned resource registry used by the Quran mobile
application. Large runtime files are published as immutable GitHub Release
assets; they are not committed to Git history.

## Rules

- Application code must reference an explicit release tag, never `latest`.
- Every asset must be listed in a release manifest with its byte length and
  SHA-256 digest.
- Third-party license and provenance notices must remain beside the manifest.
- A release is never edited after an application version has shipped. Publish
  a new tag and update the application manifest instead.

## Resource families

| Family | Status | Upstream | Distribution |
|---|---|---|---|
| QCF V4 Tajweed page fonts | Mirrored for application use | QUL / Tarteel | GitHub Release assets `p1.woff2` … `p604.woff2` |
| Istidhhar Arabic Zipformer model | Mirrored under NPL-1.1 | Quran-Lab / Natlu | GitHub Release asset, for the free non-profit application only |
| QCF page layout | Bundled in the application | QUL / Tarteel | Not downloaded at runtime |
| Quran Foundation API responses | Not mirrored or used at runtime by Istidhhar | Quran Foundation | Standalone redistribution is prohibited by the Developer Terms |
| Recitation audio and tafsir files | Not mirrored | Their respective providers | Rights must be verified per collection |

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) before adding or updating
any resource.

## Verification

On Windows PowerShell:

```powershell
./scripts/Test-ResourceManifest.ps1 \
  -Manifest ./manifests/qcf-v4-tajweed-v3.2.json \
  -AssetDirectory ./downloaded-assets
```

