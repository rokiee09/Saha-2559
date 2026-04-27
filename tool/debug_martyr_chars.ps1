$base = "https://www.egm.gov.tr"
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0"
$null = Invoke-WebRequest -Uri "$base/sehitlerimiz" -SessionVariable egmSess -UseBasicParsing -UserAgent $ua
$first = Invoke-WebRequest -Uri "$base/sehitlerimiz" -WebSession $egmSess -UseBasicParsing -UserAgent $ua
$m = [regex]::Match($first.Content, 'card-title">([^<]+)</h5>')
$s = $m.Groups[1].Value.Trim()
Write-Host "Len=$($s.Length)"
0..([Math]::Min(9, $s.Length - 1)) | ForEach-Object { Write-Host "$_ : $([int][char]$s[$_])" }

$S = [char]0x015E
Write-Host "s[0]=$([int][char]$s[0]) S=$([int][char]$S) eq: $($s[0] -eq $S)"
$prefix = $S.ToString() + "ehit "
Write-Host "StartsWith sp: $($s.StartsWith($prefix))"
Write-Host "Match simple: $([regex]::IsMatch($s, '^' + $S + 'ehit '))"
Write-Host "Match wstar: $([regex]::IsMatch($s, '^' + $S + 'ehit' + ' ' + 'P'))" 
# Polis
Write-Host "Match star: $([regex]::IsMatch($s, '^' + $S + 'ehit  '))"
$reA = [regex]::new('^' + $S + 'ehit\s+')
Write-Host "reA: $($reA.IsMatch($s))"
