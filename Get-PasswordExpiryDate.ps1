#requires -version 2
<#
.SYNOPSIS
  showing password expiration date for current user
.DESCRIPTION
  showing password expiration date for current user
.INPUTS
  none
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Nils Lüneburg
  Creation Date:  24.10.2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  none
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Load assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
#$sScriptVersion = "1.0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function main{
  Param()
  
  Begin{}
  
  Process{
    Try{
      $dn = New-Object System.DirectoryServices.DirectoryEntry
      $Rech = new-object System.DirectoryServices.DirectorySearcher($dn)
      $rc = $Rech.filter = "((sAMAccountName=$env:UserName))"
      $rc = $Rech.SearchScope = "subtree"
      $rc = $Rech.PropertiesToLoad.Add("name");
      $rc = $Rech.PropertiesToLoad.Add("userAccountControl");
      $rc = $Rech.PropertiesToLoad.Add("msDS-User-Account-Control-Computed");
      $rc = $Rech.PropertiesToLoad.Add("msDS-UserPasswordExpiryTimeComputed");

      $theUser = $Rech.FindOne()

      if ($theUser -ne $null)
      {     
        if( <# Is Account Enabled? #> ($($theUser.Properties["userAccountControl"]) -BAND 0x00000002 ) -eq 0 )
        {
          if( <# Is Account Unlocked? #>($($theUser.Properties["msDS-User-Account-Control-Computed"]) -BAND 0x00000010 ) -eq 0 )
          {
            if( <# Does Password expires? #>($($theUser.Properties["userAccountControl"]) -BAND 0x00010000 ) -eq 0 )
            {
              if( <# Is Password valid? #>($($theUser.Properties["msDS-User-Account-Control-Computed"]) -BAND 0x00800000 ) -eq 0 )
                   { <# Password is valid #>[System.Windows.Forms.Messagebox]::Show("Ihr Kennwort läuft am $($([System.DateTime]::FromFileTime($theUser.Properties["msDS-UserPasswordExpiryTimeComputed"][0])).ToString()) ab.", "Kennwort Ablaufdatum")}
              else { <# Password expired  #>[System.Windows.Forms.Messagebox]::Show("Ihr Kennwort ist abgelaufen.$([System.Environment]::NewLine)Bitte vergeben Sie ein neues Kennwort.", "Information")}
            }
            else { <# Password does not expire #> [System.Windows.Forms.Messagebox]::Show("Ihr Kennwort läuft nie ab", "Information") }
          }
          else { <# Account locked #> [System.Windows.Forms.Messagebox]::Show("Ihr Benutzerkonto ist gesperrt$([System.Environment]::NewLine)Bitte wenden Sie sich an einen Administrator.", "Information") }
        }
        else { <# Account disabled #> [System.Windows.Forms.Messagebox]::Show("Ihr Benutzerkonto ist deaktiviert$([System.Environment]::NewLine)Bitte wenden Sie sich an einen Administrator.", "Information") }
      }
    }
    Catch{ <# Error action #> [System.Windows.Forms.Messagebox]::Show("Es ist ein Fehler aufgetreten", "Fehler", [System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error); Break;}
  }
  
  End{}
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

main
