Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName system.drawing
Add-Type -AssemblyName system.io

if ((Test-Path -Path c:\PSSG) -eq $false){
New-Item -Path c:\ -ItemType directory -Name PSSG -Confirm:$false
}
function Generate-Certificate($File_Path, $Cert_Name, $PFXPassword){
$cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=PSGCertificate" -KeyUsage DigitalSignature -CertStoreLocation "Cert:\CurrentUser\My"
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "TrustedPublisher", "CurrentUser"
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()
Export-PfxCertificate -Cert $cert -FilePath "$File_Path\$Cert_Name.pfx" -Password $PFXPassword
Export-Certificate -Cert $cert -FilePath "$File_Path\$Cert_Name.cer"
$RandomNum = Get-Random -Minimum 1 -Maximum 100
Export-PfxCertificate -Cert $cert -FilePath "C:\PSSG\$Cert_Name-$RandomNum.pfx" -Password $PFXPassword
Export-Certificate -Cert $cert -FilePath "C:\PSSG\$Cert_Name-$RandomNum.cer"
Import-Certificate -FilePath "$File_Path\$Cert_Name.cer" -CertStoreLocation Cert:\CurrentUser\Root

}
function Sign-Script($File_Full_Path, $File_Cut_Path, $Cert_Name, $PFXPassword){
$Cert = Import-PfxCertificate -FilePath "$File_Cut_Path\$Cert_Name.pfx" -CertStoreLocation "Cert:\CurrentUser\My" -Password $PFXPassword
# Add to Trusted Publishers
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "TrustedPublisher", "CurrentUser"
$store.Open("ReadWrite")
$store.Add($Cert)
$store.Close()

# Sign script
try{
Set-AuthenticodeSignature -FilePath $File_Full_Path -Certificate $Cert
([System.Windows.Forms.MessageBox]::Show("Script $FullPath signed succesfully", "Done", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information))
} catch {
([System.Windows.Forms.MessageBox]::Show("Unknown error occurred", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error))

}
}

$Main_Form = New-Object System.Windows.Forms.Form
$Main_Form.StartPosition = "centerscreen"
$Main_Form.Text = "PS1 signer"
$Main_Form.Size = New-Object System.Drawing.Size(500,500)

$Main_Form_Label = New-Object System.Windows.Forms.Label
$Main_Form_Label.Font = New-Object System.Drawing.Font("arial", 14)
$Main_Form_Label.Location = New-Object System.Drawing.Point(20,20)
$Main_Form_Label.Text = "Fill in the details and hit the sign button, notice that it is case sensitive :)"
$Main_Form_Label.Size = New-Object System.Drawing.Size(450,80)
$Main_Form.Controls.Add($Main_Form_Label)

$Main_Form_Location_Label = New-Object System.Windows.Forms.Label
$Main_Form_Location_Label.Font = New-Object System.Drawing.Font("arial", 14)
$Main_Form_Location_Label.Location = New-Object System.Drawing.Point(20,100)
$Main_Form_Location_Label.Text = "Location of script {directory}:"
$Main_Form_Location_Label.Size = New-Object System.Drawing.Size(130,80)
$Main_Form.Controls.Add($Main_Form_Location_Label)
$Main_Form_Location_TB = New-Object System.Windows.Forms.TextBox
$Main_Form_Location_TB.Size = New-Object System.Drawing.Size(250)
$Main_Form_Location_TB.Location = New-Object System.Drawing.Point(180,150)
$Main_Form_Location_TB.Font = New-Object System.Drawing.Font("arial", 16)
$Main_Form_Location_TB.Text = "E.G C:\Projects\ADSec"
$Main_Form.Controls.Add($Main_Form_Location_TB)

$Main_Form_FN_Label = New-Object System.Windows.Forms.Label
$Main_Form_FN_Label.Font = New-Object System.Drawing.Font("arial", 14)
$Main_Form_FN_Label.Location = New-Object System.Drawing.Point(20,220)
$Main_Form_FN_Label.Text = "No powershell files found"
$Main_Form_FN_Label.Size = New-Object System.Drawing.Size(300,30)
$Main_Form.Controls.Add($Main_Form_FN_Label)
$Main_Form_FN_TB = New-Object System.Windows.Forms.ComboBox
$Main_Form_FN_TB.Size = New-Object System.Drawing.Size(250)
$Main_Form_FN_TB.Location = New-Object System.Drawing.Point(180,220)
$Main_Form_FN_TB.Font = New-Object System.Drawing.Font("arial", 16)
#$Main_Form.Controls.Add($Main_Form_FN_TB)



$Main_Form_PFXPassword_Label = New-Object System.Windows.Forms.Label
$Main_Form_PFXPassword_Label.Font = New-Object System.Drawing.Font("arial", 14)
$Main_Form_PFXPassword_Label.Location = New-Object System.Drawing.Point(20,290)
$Main_Form_PFXPassword_Label.Text = "Certificate password:"
$Main_Form_PFXPassword_Label.Size = New-Object System.Drawing.Size(150,50)
$Main_Form.Controls.Add($Main_Form_PFXPassword_Label)
$Main_Form_PFXPassword_TB = New-Object System.Windows.Forms.TextBox
$Main_Form_PFXPassword_TB.Size = New-Object System.Drawing.Size(250)
$Main_Form_PFXPassword_TB.Location = New-Object System.Drawing.Point(180,315)
$Main_Form_PFXPassword_TB.Font = New-Object System.Drawing.Font("arial", 16)
$Main_Form_PFXPassword_TB.Text = ""
$Main_Form.Controls.Add($Main_Form_PFXPassword_TB)

$Main_Form_Button = New-Object System.Windows.Forms.Button
$Main_Form_Button.Text = "Sign"
$Main_Form_Button.Font = New-Object System.Drawing.Font("arial", 14)
$Main_Form_Button.Location = New-Object System.Drawing.Point(200,400)
$Main_Form_Button.Size = New-Object System.Drawing.Size(100,40)
$Main_Form.Controls.Add($Main_Form_Button)

$Main_Form_Location_TB.add_textchanged({
$Chosen_Directory = $Main_Form_Location_TB.Text
if(Test-Path -Path $Chosen_Directory){
$Chosen_Directory_Content = Get-ChildItem -Path $Chosen_Directory | where {$_.Extension -in ".ps1", ".psm1", ".psd1", ".ps1xml", ".psc1", ".pssc", ".psrc", ".cdxml"}
if($Chosen_Directory_Content -eq $null){
Write-Host ""
} else {
foreach ($File in $Chosen_Directory_Content){
$File_Name = $File.name
$Main_Form_FN_TB.Items.Add($File_Name)
}
$Main_Form_FN_Label.Size = New-Object System.Drawing.Size(150,30)
$Main_Form_FN_Label.Text = "Script:"
$Main_Form.Controls.Add($Main_Form_FN_TB)
}
}
})

$Main_Form_Button.add_click({

$FilePath = $Main_Form_Location_TB.Text
$FileName = $Main_Form_FN_TB.SelectedItem
$PFXPasswordRaw = $Main_Form_PFXPassword_TB.Text
$FullPath = "$FilePath\$FileName"
$FileNameNE = [System.IO.Path]::GetFileNameWithoutExtension($FullPath)
$FullPathExists = Test-Path -Path $FullPath

if ($PFXPasswordRaw -notlike "" -and $FullPathExists -and $FileName -ne $null){
$PFXPassword = ConvertTo-SecureString -AsPlainText $PFXPasswordRaw -Force
Generate-Certificate -File_Path $FilePath -Cert_Name $FileNameNE -PFXPassword $PFXPassword
Sign-Script -File_Full_Path $FullPath -File_Cut_Path $FilePath -Cert_Name $FileNameNE -PFXPassword $PFXPassword
} else {
([System.Windows.Forms.MessageBox]::Show("File or directory not found \ No password set", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error))
}

})

$Main_Form.ShowDialog()


# SIG # Begin signature block
# MIIFagYJKoZIhvcNAQcCoIIFWzCCBVcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0DJtcIu0F/3eJL8ma85Cydlk
# C1ugggMGMIIDAjCCAeqgAwIBAgIQepp6/cbp5b5OxHHJUZ01OTANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5QU0dDZXJ0aWZpY2F0ZTAeFw0yNTEwMjIwOTQ3MDBa
# Fw0yNjEwMjIxMDA3MDBaMBkxFzAVBgNVBAMMDlBTR0NlcnRpZmljYXRlMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr/eQ7sJkc3nswsxff3TACQ603CIH
# EdEqItfaWJQzROilaXWXSktgXN7GjDAcjsoCRJstUnU57KjopgWfj+HazAfY7F6N
# mpTLJ1P4VoNqmLhLCJ7EySSFfYNDaeyuOeMSJI3l889yhRQMCCnQqhtBkZ1pJnM/
# 4eAX0WoDSKb1vDnXNNvB4MTcGihokralFab/Ba6n7fi9t1NTrgKJYgbJTAQFQt/O
# wsVEOQiD3Kif3jy9LXpGW2CIcGJClBljyVMlmYmCfRQ9ZweOE4h212R3UWcxuoxh
# znRG+WPj5SWhnpvSasEGLmJAVjUGKlQ3QORZNPiWiWRgXhvX9GqSxCyG2QIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFBtAbZHPZy7a0OlL2qOWjMPp3mpeMA0GCSqGSIb3DQEBCwUAA4IBAQBPev0P
# uAdc/ENCGp+YrY0pgUZaUsXDBkezz/19D0VtB8QW8DGAOB7AqTo2YU3EeTlJc5US
# jrBlT7u5CfGprNeLiTgEEDTJm/pF8KsmS4W4XygI7rh85L3WcE6thlblgjZWCpKq
# YB2Fzc18cIdtKcjuC8NmHyqdlgKlP5cXnB+tG+DqP1yq5a5JYP5Y1CUCHAghmd7Q
# ePUD7GGzCFIIF3MhjgxcmgmPW1bzAXq5kl/24nEAEr+I6D8dUJX4jgUWVznC0fRX
# SJqyTYXQXGovyXkpsrreAL5Say1Ob9o7Yg0GXFYR3kuEZYLfO04InBEI5tidCNH9
# 8Yasi8ZGGSVz6B4uMYIBzjCCAcoCAQEwLTAZMRcwFQYDVQQDDA5QU0dDZXJ0aWZp
# Y2F0ZQIQepp6/cbp5b5OxHHJUZ01OTAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUwSZejZP2MOA6
# ij1wbkynXxPdhA8wDQYJKoZIhvcNAQEBBQAEggEAV+g3ZBru4He25vWQOH6NK4Iw
# BNQBkIkyPkk4tBnGgBeWoyemn5mlSFIRHwkmnY6+HDdOtn8B/TVtMYkqg9UdMkbT
# Ee/Fgp6JYSpxDZmCuX1gko3StyQk8QJ42MTwj4Zgwp7xyb7Qr3PUPVSrn822MFSp
# YHnqYm57xhLEzeIFuFUhxhmHyLdOINMlAEJbK/qYi++umCyIOLv9J1rBthQAyuAq
# GF356zVCeOrcTqe33rHPypqfMC4zSsGD4MbfyW4KDh37gHR8LPOF7RbF91k+fpcl
# V+dMXzt5t1S+fqB3Avm6JwNZ2sLeBhOCi6Zi5ms+KTl/rAjus7xq9CslOkT5WA==
# SIG # End signature block
