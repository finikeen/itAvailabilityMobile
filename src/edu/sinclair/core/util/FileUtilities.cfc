<cfcomponent>

	<cffunction name="deleteExpiredReports" output="no" access="public" returntype="boolean">
		<cfset success = true>
		
        <cftry>
        
			<!--- Compare date for expiring files --->
            <cfset expiredDateTime = DateAdd("d", -1, now())>
            
            <!--- Directories for Flash and Excel files --->
            <cfset excelFilePath = "#request.projectDirectory#\view\reports\html\display\excel\">
            <cfset flashFilePath = "#request.projectDirectory#\view\reports\html\display\flash\">
            
            <!--- query file lists in Excel and Flash Directories --->
            <cfdirectory action="LIST" directory="#excelFilePath#" name="excelDir" filter="*.cfm">
            <cfdirectory action="LIST" directory="#flashFilePath#" name="flashDir" filter="*.swf">
            
            <!--- ensure all expired reports are deleted from the system --->
            
            <!--- EXCEL REPORTS --->
            <cfoutput query="excelDir">
                <cfif dateLastModified lte expiredDateTime>
                    <cffile action="delete" file="#excelFilePath##name#">
                </cfif>
            </cfoutput>
            
            <!--- FLASH REPORTS --->
            <cfoutput query="flashDir">
				<cfif dateLastModified lte expiredDateTime>
                    <cffile action="delete" file="#flashFilePath##name#">
                </cfif>
            </cfoutput>
        
            <cfcatch type="any">
            	<cfset success = false>
            </cfcatch>
        </cftry>
        
        <cfreturn success>
     </cffunction>

	<cffunction name="writeToFile" access="public" returntype="boolean">
		<cfargument name="fileContent" type="any" required="true" hint="content to write to the file">
		<cfargument name="mimeType" type="string" required="true" hint="type of file to create">
		<cfargument name="filePath" type="string" required="true" hint="path to the file">
		<cfargument name="fileAction" type="string" required="true" hint="write/append the file content">
		
		<!--- use for catching errors --->
		<cfset var success = true>
		
			<!--- create the file to be written  --->
			<cffile action="#arguments.fileaction#" file="#arguments.filePath#" output=" 
			<cfcontent type='#arguments.mimeType#'>#arguments.fileContent#" addnewline="yes">
		
		
		<cfreturn success>
	</cffunction>
	
</cfcomponent>