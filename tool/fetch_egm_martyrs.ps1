# EGM sehitlerimiz -> assets/json/martyrs.json
# NOT: PowerShell $S ve $s ayni degisken — $Scedilla gibi farkli isim kullan
$ErrorActionPreference = 'Stop'
$base = "https://www.egm.gov.tr"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0"

$Scedilla = [char]0x015E
$reStrip = [regex]::new('^(' + [regex]::Escape($Scedilla) + 'ehit|' + [regex]::Escape($Scedilla) + 'ehidimiz|Sehit|Sehidimiz)\s+', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
$reMulti = [regex]::new('(?<=\S)\s+' + [regex]::Escape($Scedilla) + 'ehit\s+|(?<=\S)\s+Sehit\s+', [Text.RegularExpressions.RegexOptions]::IgnoreCase)

$null = Invoke-WebRequest -Uri "$base/sehitlerimiz" -SessionVariable egmSess -UseBasicParsing -UserAgent $ua

function Get-CardPairs([string]$html) {
  $pattern = 'cardDate">(\d{2}\.\d{2}\.\d{4})</span>[\s\S]*?<h5 class="card-title">([^<]+)</h5>'
  [regex]::Matches($html, $pattern) | ForEach-Object {
    [PSCustomObject]@{
      d = $_.Groups[1].Value
      t = ($_.Groups[2].Value.Trim() -replace '\s+', ' ')
    }
  }
}

function To-Iso([string]$ddmmyyyy) {
  $p = $ddmmyyyy -split '\.'
  if ($p.Count -ne 3) { return $null }
  $y, $m, $d = $p[2], $p[1].PadLeft(2, '0'), $p[0].PadLeft(2, '0')
  return "$y-$m-$d"
}

function Strip-Prefix([string]$x) {
  $y = $x.Trim() -replace '\s+', ' '
  while ($true) {
    $m = $reStrip.Match($y)
    if (-not $m.Success) { break }
    $y = $y.Substring($m.Length).Trim()
  }
  return $y
}

function Explode-All([string]$raw) {
  $q = [System.Collections.Generic.Queue[string]]::new()
  if (-not [string]::IsNullOrEmpty($raw)) { $q.Enqueue( ($raw.Trim() -replace '\s+', ' ') ) }
  $done = [System.Collections.Generic.List[string]]::new()
  while ($q.Count -gt 0) {
    $cur = $q.Dequeue()
    if ([string]::IsNullOrEmpty($cur)) { continue }
    $subs = $reMulti.Split($cur, [StringSplitOptions]::RemoveEmptyEntries)
    if ($subs.Count -le 1) { $done.Add($cur) }
    else { foreach ($z in $subs) { if (-not [string]::IsNullOrEmpty($z)) { $q.Enqueue($z.Trim()) } } }
  }
  return $done
}

function Is-ValidMartyrName([string]$n) {
  if ([string]::IsNullOrWhiteSpace($n) -or $n.Trim().Length -lt 3) { return $false }
  $n = $n.Trim()
  $tr = [System.Globalization.CultureInfo]::GetCultureInfo('tr-TR')
  if ($tr.CompareInfo.Compare($n, 'Giriş', [System.Globalization.CompareOptions]::IgnoreCase) -eq 0) { return $false }
  if ($tr.CompareInfo.IsPrefix($n, 'İşçi', [System.Globalization.CompareOptions]::IgnoreCase) -or $n -match '^\s*Işçi\s') { return $false }
  return $true
}

function To-AppName([string]$raw) { Strip-Prefix $raw }

$rows = [System.Collections.Generic.List[object]]::new()
$first = Invoke-WebRequest -Uri "$base/sehitlerimiz" -WebSession $egmSess -UseBasicParsing -UserAgent $ua
Get-CardPairs $first.Content | ForEach-Object { $rows.Add($_) }

$page = 2
while ($page -le 1000) {
  $body = "{`"page`":$page,`"ContentTypeId`":`"YNcLZaW4rMBeGR5FZn5E6A==`",`"OrderByAsc`":`"true`",`"ContentCount`":`"6`"}"
  $r = Invoke-RestMethod -Uri "$base/ISAYWebPart/ContentList/DahaFazlaYukle" -Method Post -WebSession $egmSess -ContentType "application/json; charset=UTF-8" -Body $body
  if ([string]::IsNullOrWhiteSpace($r)) { break }
  $pairs = Get-CardPairs $r
  if ($null -eq $pairs -or $pairs.Count -eq 0) { break }
  foreach ($p in $pairs) { $rows.Add($p) }
  $page++
}

$seen = @{}
$list = [System.Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
  $iso = To-Iso $row.d
  if (-not $iso) { continue }
  foreach ($part in (Explode-All $row.t)) {
    $name = To-AppName $part
    if (-not (Is-ValidMartyrName $name)) { continue }
    $k = $iso + "|" + $name
    if ($seen.ContainsKey($k)) { continue }
    $seen[$k] = $true
    $list.Add([ordered]@{
      fullName = $name
      cityName = "Belirtilmedi"
      dateOfMartyrdom = $iso
    })
  }
}

$sorted = @($list | Sort-Object { $_.dateOfMartyrdom } -Descending)
$jsonParts = foreach ($item in $sorted) { (ConvertTo-Json $item -Depth 5 -Compress) }
$json = '[' + ($jsonParts -join ',') + ']'
$dest = Join-Path (Split-Path $PSScriptRoot -Parent) "assets\json\martyrs.json"
[System.IO.File]::WriteAllText($dest, $json, [System.Text.UTF8Encoding]::new($false))
Write-Host "OK: $($sorted.Count) kayit -> $dest"
