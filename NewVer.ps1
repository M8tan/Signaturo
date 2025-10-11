Add-Type -AssemblyName system.windows.forms
Add-Type -AssemblyName system.drawing

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
$Main_Form_FN_Label.Location = New-Object System.Drawing.Point(20,200)
$Main_Form_FN_Label.Text = "Script name:"
$Main_Form_FN_Label.Size = New-Object System.Drawing.Size(150,30)
$Main_Form.Controls.Add($Main_Form_FN_Label)
$Main_Form_FN_TB = New-Object System.Windows.Forms.TextBox
$Main_Form_FN_TB.Size = New-Object System.Drawing.Size(250)
$Main_Form_FN_TB.Location = New-Object System.Drawing.Point(180,200)
$Main_Form_FN_TB.Font = New-Object System.Drawing.Font("arial", 16)
$Main_Form_FN_TB.Text = "E.G Lock_Users"
$Main_Form.Controls.Add($Main_Form_FN_TB)

$Main_Form_FE_Label = New-Object System.Windows.Forms.Label
$Main_Form_FE_Label.Font = New-Object System.Drawing.Font("arial", 14)
$Main_Form_FE_Label.Location = New-Object System.Drawing.Point(20,230)
$Main_Form_FE_Label.Text = "File extension:"
$Main_Form_FE_Label.Size = New-Object System.Drawing.Size(120,50)
$Main_Form.Controls.Add($Main_Form_FE_Label)
$Main_Form_FE_TB = New-Object System.Windows.Forms.ComboBox
$Main_Form_FE_TB.Size = New-Object System.Drawing.Size(120,60)
$Main_Form_FE_TB.Items.Add(".ps1")
$Main_Form_FE_TB.Items.Add(".psm1")
$Main_Form_FE_TB.Items.Add(".psd1")
$Main_Form_FE_TB.Items.Add(".ps1xml")
$Main_Form_FE_TB.Items.Add(".psc1")
$Main_Form_FE_TB.Items.Add(".pssc")
$Main_Form_FE_TB.Items.Add(".psrc")
$Main_Form_FE_TB.Items.Add(".cdxml")
$Main_Form_FE_TB.Location = New-Object System.Drawing.Point(180,250)
$Main_Form_FE_TB.Font = New-Object System.Drawing.Font("arial", 16)
$Main_Form.Controls.Add($Main_Form_FE_TB)

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

$Main_Form_Button.add_click({

$FilePath = $Main_Form_Location_TB.Text
$FileName = $Main_Form_FN_TB.Text
$FileExtension = $Main_Form_FE_TB.SelectedItem
$PFXPasswordRaw = $Main_Form_PFXPassword_TB.Text
$FullFileName = $FileName + $FileExtension
$FullPath = $FilePath + "\" + $FileName + $FileExtension
$FullPathExists = Test-Path -Path $FullPath

if ($FullPathExists -and $PFXPasswordRaw -notlike ""){
$PFXPassword = ConvertTo-SecureString -AsPlainText $PFXPasswordRaw -Force
Generate-Certificate -File_Path $FilePath -Cert_Name $FileName -PFXPassword $PFXPassword
Sign-Script -File_Full_Path $FullPath -File_Cut_Path $FilePath -Cert_Name $FileName -PFXPassword $PFXPassword
} else {
([System.Windows.Forms.MessageBox]::Show("File or directory not found \ No password set", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error))
}

})

$Main_Form.ShowDialog()


# SIG # Begin signature block
# MIIFagYJKoZIhvcNAQcCoIIFWzCCBVcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnWtbNTx43/hIpfZoj3JLUJWm
# /i2gggMGMIIDAjCCAeqgAwIBAgIQPq5Lu7cXXIRBxhK8e28RTzANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5QU0dDZXJ0aWZpY2F0ZTAeFw0yNTEwMTExOTI1MTZa
# Fw0yNjEwMTExOTQ1MTZaMBkxFzAVBgNVBAMMDlBTR0NlcnRpZmljYXRlMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtVigr+TEty/GhwEfwTGgQqDJuLuM
# tG2z3HiVkby+Fa8IZjqBkKUv/vTzjVZMTH++ZFxZZfKgq3LqbE1yeSlaMTAxURIw
# juEdxNghsIW++2RCa8FW16nSEJNtVPPhzZQU6YMB1knBAxYYd0yS5okQrs3apS66
# 8RkJ1UbR2Zyl3YP45ssB3I0l30FNt2HfAESdjMhr8W6fNdVATjdcm94r3HwO/bxU
# YZnQoNNEFLsvbDT/3/d/ZhNq/1G+CWYnZP6sLpY7De7f6tQDXeGkNyZFZ3KTdMax
# qiEfTJzxxcpohrIScn27VKEU/48Z3JbRS7xn/HUq7QS8ayA8IPLVZSkJtQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFLPFTJqSHgEgSTaNveXMMpbikWoVMA0GCSqGSIb3DQEBCwUAA4IBAQCOjhcb
# cx58MmXd6vqqLzW3jeQKVJ973WerrEC9FBPg5BsDq9taCrzCDOkYSxIv8dUHc5m5
# Uv7mR6VEUITec+AbFicH7GPg7YZsGL4nd2VAFlpX/wNi/Hd9vPbaZfK+2ulIGDpb
# Y5xGI4FX0vAVvAmprLlQhKeBgqv3pftyXMX7zsTxYqb7e7kP59azsqbdHgxTwiZE
# 5Dqrc7abH3cZbZZhNSBzVBa7vKs7e1DbZ/fPm3SAdZ0jTe02lwcELvfg/ERFT1w5
# 4ptnjhDT8CcmcBA2FCHQ/iPw1DBB/a5o02ICA+EaPiZRBlSJTSvKVFBNMnyQmvwk
# F8ed48npI0cfq3t7MYIBzjCCAcoCAQEwLTAZMRcwFQYDVQQDDA5QU0dDZXJ0aWZp
# Y2F0ZQIQPq5Lu7cXXIRBxhK8e28RTzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUzf6sRDMGlyiD
# XH9XzEDbJ/BbZeMwDQYJKoZIhvcNAQEBBQAEggEAevdPvyiv6t5VXTUDXWRi5pFl
# Y+nNqgnrpYo2q9NgAwPRTwFUNQBKelHzwHOlCEM9tYoRzdpoGVcFB+yMtKEFrhgG
# ZIj2r1dbt3RJGXWTOMk8e5h13ZNRQS05hnNlJpT6FgbvGssyJTccvg3lbdRScque
# LUAI5N1c5fCT2Nl+fBIcxPJanLzwIEvfkv03AKjfOrpltPw3LeaXz+fjUUTMtQpB
# VR16Ic5mq0N96j2QfFLLQMw2PUQAyg6V3QMkIHV2ZUi4TjdcRYPDEBEI7Ii21HrU
# tt2WUJ9o8xioijmb3MTb+DJWI4Gw3chVcGbeucCK0dgpvoNAv8PDCeUx47pvew==
# SIG # End signature block
