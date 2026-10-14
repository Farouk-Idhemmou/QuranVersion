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
| Istidhhar Arabic Zipformer model | Pending license/commercial-use review | Quran-Lab / Natlu | Not published until the application satisfies NPL-1.1 |
| QCF page layout | Bundled in the application | QUL / Tarteel | Not downloaded at runtime |
| Quran Foundation API responses | Not mirrored | Quran Foundation | Must follow Content Sync and Developer Terms |
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

