function Get-LogDate {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)  
} 

$Current_Folder = split-path $MyInvocation.MyCommand.Path
$SystemRoot = $env:SystemRoot
$Log_File = "$SystemRoot\Debug\Manage_Windows_Features.log"
$WinFeatures_XML_Path = "$Current_Folder\Windows_Features_Config_File.xml"

If(test-path $Log_File)
	{
		remove-item $Log_File -force
	}

New-Item $Log_File -force -type file | out-null

	
Add-Content $Log_File  "$(Get-LogDate) - Launching Manage Windows Features process"	
Add-Content $Log_File  ""	

$Get_Features_XML = [xml] (get-content $WinFeatures_XML_Path)
$All_Features = $Get_Features_XML.Windows_Features.Feature | Where {$_.Feature_Status -ne "Default"}
ForEach ($Feature in $All_Features) 
	{
		$Feature_Name = $Feature.Feature_Name
		$Feature_Status = $Feature.Feature_Status
		
		$Current_Windows_Features = get-WindowsOptionalFeature -online | select * | Where {$_.FeatureName -eq "$Feature_Name"}
		$Current_Feature_Name = $Current_Windows_Features.FeatureName
		$Current_Feature_State = $Current_Windows_Features.State
		
		If($Feature_Status -ne $Current_Feature_State)
			{
				Add-Content $Log_File  "$(Get-LogDate) - The current feature status of $Current_Feature_Name is $Current_Feature_State"
				Add-Content $Log_File  "$(Get-LogDate) - The status for this status in the config file is $Feature_Status"
				Add-Content $Log_File  "$(Get-LogDate) - The status for $Current_Feature_Name will change to $Feature_Status"
				
				If($Current_Feature_State -eq "Enabled")
					{
						Try
							{
								Disable-WindowsOptionalFeature -FeatureName $Current_Feature_Name -Online -NoRestart -ErrorAction SilentlyContinue | out-null
								Add-Content $Log_File  "$(Get-LogDate) - The status for $Current_Feature_Name has been successfully $Feature_Status"
							}
						Catch
							{
								Add-Content $Log_File  "$(Get-LogDate) - An error occured while changing status for $Current_Feature_Name to $Feature_Status"
							}
						Add-Content $Log_File""
					}
				Else
					{
						Try
							{
								Enable-WindowsOptionalFeature -FeatureName $Current_Feature_Name -Online -NoRestart -ErrorAction SilentlyContinue | out-null
								Add-Content $Log_File  "$(Get-LogDate) - The status for $Current_Feature_Name has been successfully $Feature_Status"
							}
						Catch
							{
								Add-Content $Log_File  "$(Get-LogDate) - An error occured while changing status for $Current_Feature_Name to $Feature_Status"
							}
						Add-Content $Log_File  ""
					}
			}
		Else
			{
				Add-Content $Log_File"$(Get-LogDate) - The current feature status of $Current_Feature_Name is $Current_Feature_State"
				Add-Content $Log_File"$(Get-LogDate) - The status for this status in the config file is $Feature_Status"
				Add-Content $Log_File"$(Get-LogDate) - The status for $Current_Feature_Name will not change"
				Add-Content $Log_File""
			}
	}

Add-Content $Log_File  "$(Get-LogDate) - Ending Manage Windows Features process"