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
Set-AuthenticodeSignature -FilePath $File_Full_Path -Certificate $Cert -ErrorAction Stop
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
$Main_Form_FN_TB.Items.Clear()
foreach ($File in $Chosen_Directory_Content){
$File_Name = $File.name
$Main_Form_FN_TB.Items.Add($File_Name)
}
$Main_Form_FN_Label.Size = New-Object System.Drawing.Size(150,30)
$Main_Form_FN_Label.Text = "Script:"
$Main_Form.Controls.Add($Main_Form_FN_TB)
}
} else {
$Main_Form.Controls.Remove($Main_Form_FN_TB)
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUi+SwC7MrYvegeJQ+vWc/ZOJu
# +06gggMGMIIDAjCCAeqgAwIBAgIQe3rSWNzysb5CAe3gK2UDqDANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5QU0dDZXJ0aWZpY2F0ZTAeFw0yNTEwMjIxMjA5MDRa
# Fw0yNjEwMjIxMjI5MDRaMBkxFzAVBgNVBAMMDlBTR0NlcnRpZmljYXRlMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzRAFIeuw8fdA+Qonm26yWYZkJBgq
# G+oPs2zQMi4uKayH5Ia7gR2/12LAr3h6PZCEDrlUi4dG5VI7Y4g4Soja612YallC
# jpzAFd+C5Di3Ef4yPZTErlYQ5Hvu4BW3SNKqTwmTZqft14mZhDWx1lVpUcy8TPIg
# D3zalzz/rYCeyLZRfF/FGyWb6oi18h/0H/6nMz4Hp66riwfsylnUOJqMs0wOGcVy
# iWpK+zMdkGqVKj7632ZEYZsDPRkDoIp86Uhh0bIe7lT8NntHoChQhCoU3nrPy3kP
# O7K582i49zoYCoKWTMSsolIGi07/BtWIGfywRn52ont9IvdS+KwYsdPG8QIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFNl1cqZ4fTAthbBXShWveIMTC0UrMA0GCSqGSIb3DQEBCwUAA4IBAQCo0Z/2
# p+v+SQxctlGOIT0xqFkVpdtinmPxtIFWsmMpNTsGD2Q7yKBqdWv57NdAWIs1/N9R
# QQigcQCjH1coiXsNrfLVVsyl54rMxIgUNIaXCXzxQGv06aJmALt4Nl7OtZKeQrrp
# JL3M8WuQ4x+oevvcbGK/uKFm9xyBA4EYFLwgjX0B29JxpYXCKxU3BfCbqyW7NBTw
# m04S74V3eYGLx+odP4z6KW6WgHm2natVyP2cNu0ZfNMFH+PvDkGC5ayj3xNdZszE
# UDXMH39jUIg7jNtDSzDSOWUuVX6TLUhBL0MTO0uAsHlE7OA4Ugiq9WvHGl0vkIKm
# 3dsWob+5FCRXB5yRMYIBzjCCAcoCAQEwLTAZMRcwFQYDVQQDDA5QU0dDZXJ0aWZp
# Y2F0ZQIQe3rSWNzysb5CAe3gK2UDqDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUJTl98rvCiEEn
# wSupS7v9aFeElq4wDQYJKoZIhvcNAQEBBQAEggEAYVEP0hXsgJ/ZWc8aFtFgHvON
# kx6mIguZEYr4DUQXT1CZDBBO32amDW/5ggvrgfijsrDbawlj6dq0zengwJg1cbh9
# MvbPzvWGYgm7SYXB/aTND6vlwZorFet0FBE9HMhwCLZhxI4lTKGo3nrfTLTkHnBd
# 8v/pS0g0tuWafsn/f9e43taaYFrFa1yTUuOYhxmo+Lvp1UhcYacvjMB4CGqF+TDI
# JVKgfR57xOF7xbRa+KmPUulz/ZKCWLg3uBS+BrF4kcRwCdhqq7dwzg5rl81Me8k3
# 3r6ub8glE0vsBGAY1JzgGexzLlyn4E6I57Y4qFxHbi6UmGc3F97xOzwsIpBscQ==
# SIG # End signature block
