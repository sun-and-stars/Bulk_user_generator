#####################################################################################
#######This Script expects the password data to have a space infront of it.##########
############## Variable takes the values from the provided path. ####################

$file_with_data = get-content -path "c:\users\suadmin\Documents\user_password.csv"

# Calls the master file and seprates the users name from password.
$users_names = foreach($i in $file_with_data) {$i.split(",")[0]}


# Calls the master file and pulls the passwords.
$Dirty_passwords = foreach($i in $file_with_data) {$i.split(",")[1]}

# Removes the space from the front of the password during data sepration
$users_passwords = foreach($i in $Dirty_passwords) {$i.replace(" ","")}



######################################################################
$ou_name = read-host "Please Provide a Name for the OU to be created:"

# This command takes the $ou_name variable to make a new OU in the current domain server.
New-ADOrganizationalUnit -Name "$ou_name" -ProtectedFromAccidentalDeletion $false -Description "This is a Lab generated OU for test Purposes."


######################################################################
########## This loop is used to create users. ########################



    for ($i = 0; $i -lt $users_names.Length; $i++) {                           #Iterates over the length of the the usernames extracted from the source file.
        $rough_name = $users_names[$i]                                         #Reffers to the username from the source file accroding to reference pointer.
        $first_name = $rough_name.split(" ")[0].tolower()                      #Extracts First name and converts it to the lower case letters.
        $surname = $rough_name.split(" ")[1].tolower()                         #Extracts lastname and coverts in to lower case letters.
        $username = "$($first_name.substring(0,1))$($surname)".tolower()       #Creates the username with first two characters from the first name and combines it with the lastname.
        $password = Convertto-securestring -string "$users_passwords[$i]" -AsPlainText -force #Value of the password according to the reference pointer.

        Write-host "Creating User: $($username)" -BackgroundColor green -ForegroundColor Black # Writes the username for the user which is being created.

        new-aduser -AccountPassword $password `
                   -GivenName $first_name `
                   -Surname $surname `
                   -DisplayName $username `
                   -Name $username `
                   -EmployeeID $username `
                   -PasswordNeverExpires $true `
                   -Path "OU=$ou_name,DC=localdomain,DC=com" `
                   -Enabled $true
    }