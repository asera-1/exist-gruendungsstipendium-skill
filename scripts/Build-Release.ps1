#requires -Version 7.2

[CmdletBinding()]
param(
    [string]$SourceDirectory,
    [string]$OutputPath,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$defaultReleasePath = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'dist/exist-gruendungsstipendium.zip'))

if ([string]::IsNullOrWhiteSpace($SourceDirectory)) {
    $SourceDirectory = Join-Path $repositoryRoot 'exist-gruendungsstipendium'
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = $defaultReleasePath
}

$sourceRoot = [System.IO.Path]::GetFullPath($SourceDirectory)
$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)

function Assert-PathInsideRepository {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Purpose
    )

    $relative = [System.IO.Path]::GetRelativePath($repositoryRoot, $Path)
    if ([System.IO.Path]::IsPathRooted($relative) -or $relative -eq '..' -or $relative.StartsWith("..$([System.IO.Path]::DirectorySeparatorChar)")) {
        throw "$Purpose must remain inside the repository: $Path"
    }
}

Assert-PathInsideRepository -Path $sourceRoot -Purpose 'Source directory'
Assert-PathInsideRepository -Path $outputFullPath -Purpose 'Output path'

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Source directory does not exist: $sourceRoot"
}

$sourceName = Split-Path -Leaf $sourceRoot
if ($sourceName -ne 'exist-gruendungsstipendium') {
    throw "Unexpected skill directory name: $sourceName"
}

$files = @(Get-ChildItem -LiteralPath $sourceRoot -File -Recurse | Sort-Object FullName)
if ($files.Count -eq 0) {
    throw 'The skill source directory is empty.'
}

if ((Test-Path -LiteralPath $outputFullPath -PathType Leaf) -and -not $Force) {
    throw "Output already exists. Pass -Force to replace it: $outputFullPath"
}

$outputDirectory = Split-Path -Parent $outputFullPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$temporaryPath = Join-Path $outputDirectory ('.' + [System.IO.Path]::GetFileName($outputFullPath) + '.' + [System.Guid]::NewGuid().ToString('N') + '.tmp')
$fixedTimestamp = [System.DateTimeOffset]::new(2000, 1, 1, 0, 0, 0, [System.TimeSpan]::Zero)
$archiveStream = $null
$archive = $null
$completed = $false

try {
    $archiveStream = [System.IO.File]::Open($temporaryPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $archive = [System.IO.Compression.ZipArchive]::new($archiveStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)

    foreach ($file in $files) {
        $relativePath = [System.IO.Path]::GetRelativePath($sourceRoot, $file.FullName).Replace('\', '/')
        $entryName = "$sourceName/$relativePath"
        $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $entry.LastWriteTime = $fixedTimestamp
        $entry.ExternalAttributes = 0

        $input = $null
        $output = $null
        try {
            $input = [System.IO.File]::OpenRead($file.FullName)
            $output = $entry.Open()
            $input.CopyTo($output)
        }
        finally {
            if ($null -ne $output) { $output.Dispose() }
            if ($null -ne $input) { $input.Dispose() }
        }
    }

    if ($null -ne $archive) { $archive.Dispose() }
    $archive = $null
    if ($null -ne $archiveStream) { $archiveStream.Dispose() }
    $archiveStream = $null

    Move-Item -LiteralPath $temporaryPath -Destination $outputFullPath -Force:$Force
    $completed = $true
}
finally {
    if ($null -ne $archive) { $archive.Dispose() }
    if ($null -ne $archiveStream) { $archiveStream.Dispose() }
    if (-not $completed -and (Test-Path -LiteralPath $temporaryPath -PathType Leaf)) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }
}

$hash = (Get-FileHash -LiteralPath $outputFullPath -Algorithm SHA256).Hash

if ($outputFullPath -ieq $defaultReleasePath) {
    $checksumPath = Join-Path $repositoryRoot 'dist/SHA256SUMS.txt'
    $checksumLine = "$hash  exist-gruendungsstipendium.zip`n"
    [System.IO.File]::WriteAllText($checksumPath, $checksumLine, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Wrote $checksumPath"
}

Write-Host "Built $outputFullPath"
Write-Host "SHA256 $hash"
