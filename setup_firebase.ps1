# HESTORIA - Firebase setup helper. Run from the HESTORIA project folder:
#   powershell -ExecutionPolicy Bypass -File .\setup_firebase.ps1
# Requires: npm install -g firebase-tools   and   firebase login
$project  = "hestoria-english-app"
$location = "eur3"   # Firestore location (cannot be changed later). Use nam5 for US.

function Write-NoBom($path, $text) {
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) $path), $text, (New-Object System.Text.UTF8Encoding $false))
}

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  Write-Host "firebase CLI not found. Run: npm install -g firebase-tools  then: firebase login" -ForegroundColor Red
  exit 1
}
if (-not (Test-Path "firestore.rules")) {
  Write-Host "firestore.rules not found. Run this script from the HESTORIA project folder." -ForegroundColor Red
  exit 1
}

Write-Host "`n[1/4] Writing firebase.json and .firebaserc" -ForegroundColor Cyan
Write-NoBom "firebase.json" '{ "firestore": { "rules": "firestore.rules" } }'
Write-NoBom ".firebaserc" "{ `"projects`": { `"default`": `"$project`" } }"

Write-Host "`n[2/4] Creating Firestore database (ignore 'already exists')" -ForegroundColor Cyan
firebase firestore:databases:create "(default)" --location $location --project $project
if ($LASTEXITCODE -ne 0) {
  Write-Host "Could not create the database automatically. Create it in the console: Build > Firestore Database > Create database (Production mode)." -ForegroundColor Yellow
}

Write-Host "`n[3/4] Publishing Firestore security rules" -ForegroundColor Cyan
firebase deploy --only firestore:rules --project $project
if ($LASTEXITCODE -ne 0) {
  Write-Host "Rules deploy failed. Create the database first (step above), then run this script again." -ForegroundColor Yellow
}

Write-Host "`n[4/4] Android minSdk 23 (needed by Firestore)" -ForegroundColor Cyan
$gradle = @("android\app\build.gradle.kts", "android\app\build.gradle") | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($gradle) {
  $text = [System.IO.File]::ReadAllText((Resolve-Path $gradle))
  if ($text -match "flutter\.minSdkVersion") {
    Copy-Item $gradle "$gradle.bak" -Force
    $text = $text -replace "flutter\.minSdkVersion", "23"
    [System.IO.File]::WriteAllText((Resolve-Path $gradle), $text, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "Patched $gradle (backup: $gradle.bak)"
  } else {
    Write-Host "No flutter.minSdkVersion found in $gradle - leaving it as is."
  }
} else {
  Write-Host "android\app\build.gradle(.kts) not found - skipped."
}

Write-Host "`nDone. ONE manual step left (cannot be automated):" -ForegroundColor Green
Write-Host "Firebase Console > Build > Authentication > Get started > Sign-in method > Anonymous > Enable > Save"
Write-Host "https://console.firebase.google.com/project/$project/authentication/providers"
Write-Host "`nThen run: flutter pub get ; flutter run"