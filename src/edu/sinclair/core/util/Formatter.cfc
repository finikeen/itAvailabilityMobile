<cfcomponent displayname="Formatters">
	
	<cffunction name="formatFirstLetterCap" access="public" returntype="string">
		<cfargument name="stringToFormat" type="string" required="true">
		
		<cfset var fixedString = "">
		
		<cfif len(arguments.stringToFormat)>
			<cfif len(arguments.stringToFormat) gt 1>
				<cfset stringToFormatLower = LCASE(Trim(arguments.stringToFormat))>
                <cfset firstLetter = UCASE(Left(stringToFormatLower,1))>
                <cfset lastLetters = Right(stringToFormatLower,len(stringToFormatLower)-1)>
                <cfset fixedString = firstLetter & lastLetters>
           	<cfelse>
            	<cfset fixedString = UCASE(Trim(arguments.stringToFormat))>
            </cfif>
		</cfif>

		<cfreturn fixedString>
	</cffunction>

</cfcomponent>