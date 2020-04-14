[CmdletBinding()]
Param(
		[Parameter(Mandatory=$false)]	
		[string]$XML_output_Folder
	 )	

$List_Features =  get-WindowsOptionalFeature -online | select *
$WinFeatures_XML_Path = "$XML_output_Folder\Windows_Features_Config_File.xml"

$xmlsettings = New-Object System.Xml.XmlWriterSettings
$xmlsettings.Indent = $true
$xmlsettings.IndentChars = "    "

$XmlWriter = [System.XML.XmlWriter]::Create($WinFeatures_XML_Path, $xmlsettings)

$xmlWriter.WriteStartDocument()
$xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")
		
$xmlWriter.WriteStartElement("Windows_Features") 

ForEach($Feature in $List_Features)
	{
		$xmlWriter.WriteStartElement("Feature") 
	
		$Feature_Name = $Feature.FeatureName
		$Feature_State = $Feature.State
		$Feature_Restart_Status = $Feature.RestartNeeded	

		$xmlWriter.WriteElementString("Feature_Name",$Feature_Name)
		$xmlWriter.WriteElementString("Feature_Restart_Status",$Feature_Restart_Status)			
		$xmlWriter.WriteElementString("Feature_Status","Default")
		
		$xmlWriter.WriteEndElement() 
	}
	
$xmlWriter.WriteEndElement() 
$xmlWriter.WriteEndDocument()	

$xmlWriter.Flush()
$xmlWriter.Close()	