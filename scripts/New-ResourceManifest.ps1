param(
    [Parameter(Mandatory = $true)]
    [string] $AssetDirectory,

    [Parameter(Mandatory = $true)]
    [string] $OutputPath,

    [Parameter(Mandatory = $true)]
    [string] $Repository,

    [Parameter(Mandatory = $true)]
    [string] $Tag,

    [Parameter(Mandatory = $true)]
    [string] $ResourceId,

    [Parameter(Mandatory = $true)]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
$assetRoot = (Resolve-Path -LiteralPath $AssetDirectory).Path
$files = Get-ChildItem -LiteralPath $assetRoot -File | Sort-Object Name
if ($files.Count -eq 0) {
    throw "No assets found in $assetRoot"
}

$assets = foreach ($file in $files) {
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName
    [ordered]@{
        name = $file.Name
        size_bytes = $file.Length
        sha256 = $hash.Hash.ToLowerInvariant()
        url = "https://github.com/$Repository/releases/download/$Tag/$($file.Name)"
    }
}
$totalSizeBytes = ($files | Measure-Object -Property Length -Sum).Sum

$manifest = [ordered]@{
    schema_version = 1
    resource_id = $ResourceId
    version = $Version
    repository = $Repository
    release_tag = $Tag
    generated_at_utc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    asset_count = $assets.Count
    total_size_bytes = $totalSizeBytes
    assets = @($assets)
}

$parent = Split-Path -Parent $OutputPath
if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 -LiteralPath $OutputPath

