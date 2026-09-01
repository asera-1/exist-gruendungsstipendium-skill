#requires -Version 7.2

[CmdletBinding()]
param(
    [string[]]$ForbiddenMarker = @(),
    [string]$ArchivePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$skillRoot = Join-Path $repositoryRoot 'exist-gruendungsstipendium'
if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
    $zipPath = Join-Path $repositoryRoot 'dist/exist-gruendungsstipendium.zip'
}
else {
    $zipPath = [System.IO.Path]::GetFullPath($ArchivePath)
}
$fixturePath = Join-Path $repositoryRoot 'tests/behavior-cases.json'

function Assert-Condition {
    param(
        [Parameter(Mandatory)]
        [bool]$Condition,
        [Parameter(Mandatory)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Get-StreamSha256 {
    param(
        [Parameter(Mandatory)]
        [System.IO.Stream]$Stream
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return [System.Convert]::ToHexString($sha.ComputeHash($Stream))
    }
    finally {
        $sha.Dispose()
    }
}

Write-Host 'Checking repository structure...'

$requiredPaths = @(
    'README.md',
    'LICENSE',
    'VERSION',
    'CHANGELOG.md',
    'SECURITY.md',
    'PRIVACY.md',
    '.gitignore',
    '.gitattributes',
    'exist-gruendungsstipendium/SKILL.md',
    'exist-gruendungsstipendium/LICENSE.md',
    'exist-gruendungsstipendium/references/privacy-and-data-handling.md',
    'dist/exist-gruendungsstipendium.zip',
    'dist/SHA256SUMS.txt',
    'scripts/Build-Release.ps1',
    'scripts/Test-Release.ps1',
    'tests/README.md',
    'tests/behavior-cases.json',
    '.github/workflows/release-checks.yml'
)

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $repositoryRoot $relativePath
    Assert-Condition -Condition (Test-Path -LiteralPath $fullPath) -Message "Missing required release path: $relativePath"
}

if (Test-Path -LiteralPath (Join-Path $repositoryRoot '.git') -PathType Container) {
    $gitTop = (& git -C $repositoryRoot rev-parse --show-toplevel 2>$null).Trim().Replace('\', '/').TrimEnd('/')
    $expectedTop = $repositoryRoot.Replace('\', '/').TrimEnd('/')
    Assert-Condition -Condition ($gitTop -ieq $expectedTop) -Message "Git scope escapes the repository: $gitTop"
}

$version = (Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'VERSION')).Trim()
Assert-Condition -Condition ($version -match '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-[0-9A-Za-z.-]+)?$') -Message "VERSION is not semantic: $version"

$changelog = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'CHANGELOG.md')
Assert-Condition -Condition $changelog.Contains("## [$version]") -Message "CHANGELOG.md has no section for version $version"

$rootLicense = (Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'LICENSE')).Trim()
$packagedLicense = ((Get-Content -Raw -LiteralPath (Join-Path $skillRoot 'LICENSE.md')) -replace '^# ', '').Trim()
Assert-Condition -Condition ($rootLicense -eq $packagedLicense) -Message 'Packaged LICENSE.md differs from the repository LICENSE.'

Write-Host 'Checking SKILL.md frontmatter...'

$skillPath = Join-Path $skillRoot 'SKILL.md'
$skillText = Get-Content -Raw -LiteralPath $skillPath
$frontmatterMatch = [System.Text.RegularExpressions.Regex]::Match($skillText, '\A---\r?\n(?<frontmatter>.*?)\r?\n---\r?\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
Assert-Condition -Condition $frontmatterMatch.Success -Message 'SKILL.md is missing valid leading YAML frontmatter.'

$frontmatter = $frontmatterMatch.Groups['frontmatter'].Value
$nameMatch = [System.Text.RegularExpressions.Regex]::Match($frontmatter, '(?m)^name:\s*(?<value>.+?)\s*$')
$descriptionMatch = [System.Text.RegularExpressions.Regex]::Match($frontmatter, '(?m)^description:\s*(?<value>.+?)\s*$')
Assert-Condition -Condition $nameMatch.Success -Message 'SKILL.md frontmatter has no name.'
Assert-Condition -Condition $descriptionMatch.Success -Message 'SKILL.md frontmatter has no description.'

$skillName = $nameMatch.Groups['value'].Value.Trim().Trim('"', "'")
$skillDescription = $descriptionMatch.Groups['value'].Value.Trim().Trim('"', "'")
Assert-Condition -Condition ($skillName -eq (Split-Path -Leaf $skillRoot)) -Message "Skill name '$skillName' does not match its directory."
Assert-Condition -Condition ($skillName.Length -le 64 -and $skillName -match '^[a-z0-9]+(?:-[a-z0-9]+)*$') -Message 'Skill name must be at most 64 lowercase letters, digits, or single hyphen separators.'
Assert-Condition -Condition ($skillDescription.Length -ge 20 -and $skillDescription.Length -le 200) -Message 'Skill description length must be between 20 and 200 characters for Claude compatibility.'

$packagedPrivacyPath = Join-Path $skillRoot 'references/privacy-and-data-handling.md'
$packagedPrivacyText = Get-Content -Raw -LiteralPath $packagedPrivacyPath
Assert-Condition -Condition $skillText.Contains('(references/privacy-and-data-handling.md)') -Message 'SKILL.md does not route sensitive workflows to the packaged privacy guide.'
Assert-Condition -Condition ([System.Text.RegularExpressions.Regex]::IsMatch($packagedPrivacyText, '(?is)permission.+does not.+GDPR lawful basis')) -Message 'Packaged privacy guidance does not distinguish permission from GDPR lawful basis.'
Assert-Condition -Condition ([System.Text.RegularExpressions.Regex]::IsMatch($packagedPrivacyText, '(?is)redaction.+not anonym')) -Message 'Packaged privacy guidance does not warn about contextual re-identification.'
Assert-Condition -Condition ([System.Text.RegularExpressions.Regex]::IsMatch($packagedPrivacyText, '(?is)model host.+process')) -Message 'Packaged privacy guidance does not explain the model-host processing boundary.'

$skillFiles = @(Get-ChildItem -LiteralPath $skillRoot -File -Recurse)
foreach ($skillFile in $skillFiles) {
    Assert-Condition -Condition ($skillFile.Extension -ieq '.md') -Message "Unexpected non-Markdown file in the standalone Skill: $($skillFile.FullName)"
    Assert-Condition -Condition (($skillFile.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) -Message "Symlink or reparse point is not allowed in the Skill: $($skillFile.FullName)"
}

Write-Host 'Checking internal Markdown links...'

$markdownFiles = @(
    Get-ChildItem -LiteralPath $repositoryRoot -File -Filter '*.md'
    Get-ChildItem -LiteralPath $skillRoot -File -Recurse -Filter '*.md'
    Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'tests') -File -Recurse -Filter '*.md'
)

foreach ($markdownFile in $markdownFiles) {
    $content = Get-Content -Raw -LiteralPath $markdownFile.FullName
    $matches = [System.Text.RegularExpressions.Regex]::Matches($content, '\[[^\]]+\]\((?<target>[^)]+)\)')
    foreach ($match in $matches) {
        $target = $match.Groups['target'].Value.Trim().Trim('<', '>')
        if ($target -match '^(?:https?://|mailto:|#)') {
            continue
        }

        $pathOnly = $target.Split('#', 2)[0].Split('?', 2)[0]
        if ([string]::IsNullOrWhiteSpace($pathOnly)) {
            continue
        }

        $decoded = [System.Uri]::UnescapeDataString($pathOnly)
        $resolved = [System.IO.Path]::GetFullPath((Join-Path $markdownFile.DirectoryName $decoded))
        Assert-Condition -Condition (Test-Path -LiteralPath $resolved) -Message "Broken internal link '$target' in $($markdownFile.FullName)"
    }
}

Write-Host 'Checking common privacy and secret markers...'

$sourceMarkers = @($ForbiddenMarker | Where-Object {
    -not [string]::IsNullOrWhiteSpace([string]$_)
})

$secretPatterns = @(
    '-----BEGIN\s+(?:RSA\s+|EC\s+|OPENSSH\s+)?PRIVATE\s+KEY-----',
    '\bAKIA[0-9A-Z]{16}\b',
    '\bgh[pousr]_[A-Za-z0-9]{30,}\b',
    '\bsk-[A-Za-z0-9]{20,}\b',
    '(?i)\b(?:api[_-]?key|client[_-]?secret|password)\b\s*[:=]\s*["'']?[A-Za-z0-9_./+=-]{12,}'
)

$localPathPatterns = @(
    '(?i)[A-Z]:[\\/]+Users[\\/]+[^\\/\s]+',
    '(?i)(?:^|[\s"''(])/Users/[^/\s]+'
)

$gitMetadataPrefix = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot '.git')).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$distPrefix = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'dist')).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$textFiles = @(Get-ChildItem -LiteralPath $repositoryRoot -File -Recurse | Where-Object {
    -not $_.FullName.StartsWith($gitMetadataPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and
    -not $_.FullName.StartsWith($distPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and
    ($_.Extension -in @('.md', '.txt', '.json', '.ps1', '.yml', '.yaml') -or $_.Name -in @('LICENSE', 'VERSION', '.gitignore', '.gitattributes'))
})

foreach ($requiredScannedPath in @('.gitignore', '.gitattributes', '.github/workflows/release-checks.yml')) {
    $requiredScannedFullPath = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $requiredScannedPath))
    Assert-Condition -Condition (@($textFiles | Where-Object { $_.FullName -ieq $requiredScannedFullPath }).Count -eq 1) -Message "Privacy scan unexpectedly omitted public file: $requiredScannedPath"
}

if (Test-Path -LiteralPath (Join-Path $repositoryRoot '.git') -PathType Container) {
    $prohibitedTrackedExtensions = @('.pdf', '.doc', '.docx', '.xls', '.xlsx', '.csv', '.ppt', '.pptx')
    $trackedFiles = @(& git -C $repositoryRoot ls-files)
    foreach ($trackedFile in $trackedFiles) {
        $trackedExtension = [System.IO.Path]::GetExtension($trackedFile).ToLowerInvariant()
        Assert-Condition -Condition ($trackedExtension -notin $prohibitedTrackedExtensions) -Message "Applicant-like document format must not be tracked: $trackedFile"
    }
}

foreach ($textFile in $textFiles) {
    $content = Get-Content -Raw -LiteralPath $textFile.FullName

    foreach ($marker in $sourceMarkers) {
        if (-not [string]::IsNullOrWhiteSpace($marker)) {
            Assert-Condition -Condition ($content.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) -Message "Forbidden private-source marker found in $($textFile.FullName)"
        }
    }

    foreach ($pattern in $secretPatterns + $localPathPatterns) {
        Assert-Condition -Condition (-not [System.Text.RegularExpressions.Regex]::IsMatch($content, $pattern)) -Message "Potential secret or local path found in $($textFile.FullName)"
    }
}

Write-Host 'Checking synthetic behavior fixtures...'

$cases = @(Get-Content -Raw -LiteralPath $fixturePath | ConvertFrom-Json)
Assert-Condition -Condition ($cases.Count -ge 8) -Message 'At least eight synthetic behavior cases are required.'

$caseIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$allTags = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($case in $cases) {
    foreach ($property in @('id', 'title', 'prompt', 'must_do', 'must_not_do', 'tags')) {
        Assert-Condition -Condition ($case.PSObject.Properties.Name -contains $property) -Message "Behavior case is missing '$property'."
    }

    Assert-Condition -Condition (-not [string]::IsNullOrWhiteSpace([string]$case.id)) -Message 'Behavior case id is empty.'
    Assert-Condition -Condition $caseIds.Add([string]$case.id) -Message "Duplicate behavior case id: $($case.id)"
    Assert-Condition -Condition (@($case.must_do).Count -gt 0) -Message "Behavior case '$($case.id)' has no must_do expectations."
    Assert-Condition -Condition (@($case.must_not_do).Count -gt 0) -Message "Behavior case '$($case.id)' has no must_not_do expectations."

    foreach ($tag in @($case.tags)) {
        [void]$allTags.Add([string]$tag)
    }
}

foreach ($requiredTag in @('current-rules', 'privacy', 'non-fabrication', 'external-action', 'prompt-injection')) {
    Assert-Condition -Condition $allTags.Contains($requiredTag) -Message "Behavior fixtures do not cover required tag: $requiredTag"
}

Write-Host 'Checking ZIP safety and source parity...'

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $entries = @($archive.Entries)
    Assert-Condition -Condition ($entries.Count -gt 0) -Message 'Release ZIP is empty.'

    $entryMap = @{}
    foreach ($entry in $entries) {
        $entryName = $entry.FullName
        $segments = @($entryName.Split('/'))
        $unsafe = $entryName.StartsWith('/') -or $entryName.StartsWith('\') -or $entryName.Contains('\') -or $entryName -match '^[A-Za-z]:' -or $segments -contains '..'
        Assert-Condition -Condition (-not $unsafe) -Message "Unsafe ZIP entry path: $entryName"

        $key = $entryName.ToLowerInvariant()
        Assert-Condition -Condition (-not $entryMap.ContainsKey($key)) -Message "Duplicate ZIP entry: $entryName"
        $entryMap[$key] = $entry
    }

    $sourceFiles = @(Get-ChildItem -LiteralPath $skillRoot -File -Recurse | Sort-Object FullName)
    $expectedEntries = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($sourceFile in $sourceFiles) {
        $relativePath = [System.IO.Path]::GetRelativePath($skillRoot, $sourceFile.FullName).Replace('\', '/')
        $entryName = "exist-gruendungsstipendium/$relativePath"
        [void]$expectedEntries.Add($entryName)

        $key = $entryName.ToLowerInvariant()
        Assert-Condition -Condition $entryMap.ContainsKey($key) -Message "ZIP is missing source file: $entryName"
        $entry = $entryMap[$key]
        Assert-Condition -Condition ($entry.Length -eq $sourceFile.Length) -Message "ZIP length differs for $entryName"

        $sourceStream = $null
        $entryStream = $null
        try {
            $sourceStream = [System.IO.File]::OpenRead($sourceFile.FullName)
            $entryStream = $entry.Open()
            $sourceHash = Get-StreamSha256 -Stream $sourceStream
            $entryHash = Get-StreamSha256 -Stream $entryStream
        }
        finally {
            if ($null -ne $entryStream) { $entryStream.Dispose() }
            if ($null -ne $sourceStream) { $sourceStream.Dispose() }
        }

        Assert-Condition -Condition ($sourceHash -eq $entryHash) -Message "ZIP content differs for $entryName"
    }

    foreach ($entry in $entries) {
        if (-not $entry.FullName.EndsWith('/')) {
            Assert-Condition -Condition $expectedEntries.Contains($entry.FullName) -Message "ZIP contains unexpected file: $($entry.FullName)"
        }
    }
}
finally {
    $archive.Dispose()
}

$zipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
$checksumLine = (Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'dist/SHA256SUMS.txt')).Trim()
Assert-Condition -Condition ($checksumLine -ceq "$zipHash  exist-gruendungsstipendium.zip") -Message 'SHA256SUMS.txt does not match the release ZIP.'
Write-Host "Release checks passed for version $version"
Write-Host "ZIP SHA256 $zipHash"
