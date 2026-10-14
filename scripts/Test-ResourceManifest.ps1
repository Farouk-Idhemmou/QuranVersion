param(
    [Parameter(Mandatory = $true)]
    [string] $Manifest,

    [Parameter(Mandatory = $true)]
    [string] $AssetDirectory
)

$ErrorActionPreference = 'Stop'
$manifestData = Get-Content -Raw -LiteralPath $Manifest | ConvertFrom-Json
$assetRoot = (Resolve-Path -LiteralPath $AssetDirectory).Path

foreach ($asset in $manifestData.assets) {
    $path = Join-Path $assetRoot $asset.name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing asset: $($asset.name)"
    }
    $file = Get-Item -LiteralPath $path
    if ($file.Length -ne [long] $asset.size_bytes) {
        throw "Size mismatch for $($asset.name): $($file.Length) != $($asset.size_bytes)"
    }
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
    if ($actualHash -ne $asset.sha256) {
        throw "SHA-256 mismatch for $($asset.name)"
    }
}

Write-Output "Verified $($manifestData.asset_count) assets ($($manifestData.resource_id) $($manifestData.version))."

