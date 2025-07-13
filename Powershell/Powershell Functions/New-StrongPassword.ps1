Function CreatePass(){
    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do {
        $newPassword=([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | Sort-Object {Get-Random})[0..21] -join ''
        If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
        -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
        -and ($newPassword -match "[\d]") `
        -and ($newPassword -match "[^\w]")
        ){
            $PassComplexCheck=$True
        }
    }
    While ($PassComplexCheck -eq $false)
    $securePassword = ConvertTo-SecureString -String $newPassword -AsPlainText -Force
    return $securePassword
}
