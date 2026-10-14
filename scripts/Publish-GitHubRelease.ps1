param(
    [Parameter(Mandatory = $true)]
    [string] $Repository,

    [Parameter(Mandatory = $true)]
    [string] $Tag,

    [Parameter(Mandatory = $true)]
    [string] $Title,

    [Parameter(Mandatory = $true)]
    [string] $AssetDirectory,

    [Parameter(Mandatory = $true)]
    [string] $Manifest,

    [string] $TargetCommitish = 'main'
)

$ErrorActionPreference = 'Stop'

function Get-GitHubCredential {
    $lines = @("protocol=https", "host=github.com", "") | git credential fill
    if ($LASTEXITCODE -ne 0) {
        throw 'Git Credential Manager did not return GitHub credentials.'
    }
    $values = @{}
    foreach ($line in $lines) {
        $separator = $line.IndexOf('=')
        if ($separator -gt 0) {
            $values[$line.Substring(0, $separator)] = $line.Substring($separator + 1)
        }
    }
    if (-not $values.password) {
        throw 'GitHub credential has no access token.'
    }
    return $values
}

function Invoke-GitHubJson {
    param(
        [Parameter(Mandatory = $true)] [string] $Method,
        [Parameter(Mandatory = $true)] [string] $Uri,
        [object] $Body
    )
    $parameters = @{
        Method = $Method
        Uri = $Uri
        Headers = $script:headers
    }
    if ($null -ne $Body) {
        $parameters.ContentType = 'application/json'
        $parameters.Body = $Body | ConvertTo-Json -Depth 8
    }
    return Invoke-RestMethod @parameters
}

$credential = Get-GitHubCredential
$script:headers = @{
    Accept = 'application/vnd.github+json'
    Authorization = "Bearer $($credential.password)"
    'X-GitHub-Api-Version' = '2022-11-28'
    'User-Agent' = 'QuranVersion-release-publisher'
}

$apiBase = "https://api.github.com/repos/$Repository"
$release = $null
$releases = Invoke-GitHubJson -Method Get -Uri "$apiBase/releases?per_page=100"
$release = $releases | Where-Object { $_.tag_name -eq $Tag } | Select-Object -First 1
if ($null -eq $release) {
    $release = Invoke-GitHubJson -Method Post -Uri "$apiBase/releases" -Body ([ordered]@{
        tag_name = $Tag
        target_commitish = $TargetCommitish
        name = $Title
        body = "Versioned application resource bundle. See the committed manifest and THIRD_PARTY_NOTICES.md before use."
        draft = $true
        prerelease = $false
        make_latest = 'false'
    })
    Write-Output "Created draft release $Tag (id=$($release.id))."
} elseif (-not $release.draft) {
    throw "Release $Tag is already published and is treated as immutable."
} else {
    Write-Output "Resuming draft release $Tag (id=$($release.id))."
}

$remoteAssets = @{}
$page = 1
do {
    $batchResponse = Invoke-GitHubJson -Method Get -Uri "$apiBase/releases/$($release.id)/assets?per_page=100&page=$page"
    $batch = @($batchResponse | Where-Object { $null -ne $_ })
    foreach ($asset in $batch) {
        $remoteAssets[$asset.name] = $asset
    }
    $page++
} while ($batch.Count -eq 100)

$assetRoot = (Resolve-Path -LiteralPath $AssetDirectory).Path
$files = @(Get-ChildItem -LiteralPath $assetRoot -File | Sort-Object Name)
$manifestData = Get-Content -Raw -LiteralPath $Manifest | ConvertFrom-Json
if ($files.Count -ne $manifestData.asset_count) {
    throw "Local asset count $($files.Count) does not match manifest $($manifestData.asset_count)."
}

$uploadBase = $release.upload_url -replace '\{\?name,label\}$', ''
$completed = 0
foreach ($file in $files) {
    $existing = $remoteAssets[$file.Name]
    if ($null -ne $existing -and [long] $existing.size -eq $file.Length) {
        $completed++
        continue
    }
    if ($null -ne $existing) {
        Invoke-GitHubJson -Method Delete -Uri "$apiBase/releases/assets/$($existing.id)" | Out-Null
    }

    $encodedName = [Uri]::EscapeDataString($file.Name)
    $uploaded = $false
    for ($attempt = 1; $attempt -le 4 -and -not $uploaded; $attempt++) {
        try {
            $contentType = if ($file.Extension -eq '.woff2') {
                'font/woff2'
            } else {
                'application/octet-stream'
            }
            Invoke-RestMethod -Method Post -Uri "$uploadBase`?name=$encodedName" `
                -Headers $script:headers -ContentType $contentType -InFile $file.FullName | Out-Null
            $uploaded = $true
        } catch {
            if ($attempt -eq 4) { throw }
            Start-Sleep -Seconds (2 * $attempt)
        }
    }
    $completed++
    if ($completed -eq 1 -or $completed % 25 -eq 0 -or $completed -eq $files.Count) {
        Write-Output "Uploaded $completed/$($files.Count) assets."
    }
}

$publishedAssets = @()
$page = 1
do {
    $batchResponse = Invoke-GitHubJson -Method Get -Uri "$apiBase/releases/$($release.id)/assets?per_page=100&page=$page"
    $batch = @($batchResponse | Where-Object { $null -ne $_ })
    $publishedAssets += $batch
    $page++
} while ($batch.Count -eq 100)

if ($publishedAssets.Count -ne $manifestData.asset_count) {
    throw "GitHub has $($publishedAssets.Count) assets; expected $($manifestData.asset_count)."
}
$expected = @{}
foreach ($asset in $manifestData.assets) { $expected[$asset.name] = [long] $asset.size_bytes }
foreach ($asset in $publishedAssets) {
    if (-not $expected.ContainsKey($asset.name) -or $expected[$asset.name] -ne [long] $asset.size) {
        throw "Unexpected release asset or size: $($asset.name)"
    }
}

$release = Invoke-GitHubJson -Method Patch -Uri "$apiBase/releases/$($release.id)" -Body ([ordered]@{
    draft = $false
    prerelease = $false
    make_latest = 'false'
})
Write-Output "Published $($release.html_url) with $($publishedAssets.Count) verified assets."
