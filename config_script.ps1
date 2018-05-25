Param(
    [string]$ts_admin_un,
    [string]$ts_admin_pw,
    [string]$reg_first_name,
    [string]$reg_last_name,
    [string]$reg_email,
    [string]$reg_company,
    [string]$reg_title,
    [string]$reg_department,
    [string]$reg_industry,
    [string]$reg_phone,
    [string]$reg_city,
    [string]$reg_state,
    [string]$reg_zip,
    [string]$reg_country,
    [string]$license_key
)

## FILES

## 1. make secrets.json file

cd C:/
mkdir tabsetup

$secrets = @{
    content_admin_user = "$ts_admin_un"
    content_admin_pass = "$ts_admin_pw"
}

$secrets | ConvertTo-Json -depth 10 | Out-File "C:/tabsetup/secrets.json" -Encoding ASCII

## 2. make registration.json

# add AZURE QUICKSTART TO COMPANY TO TRACK
$registration = @{
    first_name = "$reg_first_name"
    last_name = "$reg_last_name"
    email = "$reg_email"
    company = "$reg_company"
    title = "$reg_title"
    department = "$reg_department"
    industry = "$reg_industry"
    phone = "$reg_phone"
    city = "$reg_city"
    state = "$reg_state"
    zip = "$reg_zip"
    country = "$reg_country"
}

$registration | ConvertTo-Json -depth 10 | Out-File "C:/tabsetup/registration.json" -Encoding ASCII

## 3. download python installer
## Refer this back to Kitty's hosted version for consistency
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/maddyloo/tableau-server-windows-1node/master/ScriptedInstaller.py" -OutFile "C:/tabsetup/ScriptedInstaller.py"

## 4. Download python .msi
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/2.7.12/python-2.7.12.msi" -OutFile "C:/tabsetup/python-2.7.12.msi"

## 5. download Tableau Server .exe
Invoke-WebRequest -Uri "https://downloads.tableau.com/esdalt/2018.1.0/TableauServer-64bit-2018-1-0.exe" -Outfile "C:/tabsetup/tableau-server-installer.exe"

## COMMANDS

## 1. install python (and add to path) - wait for install to proceed
# & c:/tabsetup/python-2.7.12.msi /quiet /qn -wait
Start-Process "c:/tabsetup/python-2.7.12.msi" -ArgumentList "/quiet /qn" -Wait
$env:Path = "C:/Python27/"

## 2. install yaml
Set-Location -Path C:/Python27/Scripts
.\pip install pyyaml
Set-Location -Path C:/Python27/Scripts

## 2.5 make tabinstall.txt
New-Item c:/tabsetup/tabinstall.txt -ItemType file

## 3. run installer script
# accomodate for trial key
cd C:/Python27/
if ($license_key.ToLower() = "trial") {
    ./python C:/tabsetup/ScriptedInstaller.py install --installerLog C:/tabsetup/tabinstall.txt --enablePublicFwRule --secretsFile C:/tabsetup/secrets.json --registrationFile C:/tabsetup/registration.json --installDir C:/Tableau/ --trialLicense C:/tabsetup/tableau-server-installer.exe
} else {
    ./python C:/tabsetup/ScriptedInstaller.py install --installerLog C:/tabsetup/tabinstall.txt --enablePublicFwRule --secretsFile C:/tabsetup/secrets.json --registrationFile C:/tabsetup/registration.json --installDir C:/Tableau/ --licenseKey $license_key C:/tabsetup/tableau-server-installer.exe
}


##  c:/tabsetup/installer-output.txt 2>&1

## 4. cleanup secrets

del c:/tabsetup/secrets.json