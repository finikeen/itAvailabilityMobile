<cfcomponent displayname="AbstractRestAPI" extends="taffy.core.resource">
	
	<cfset variables.dataTypeUtil = Application.beanFactory.getBean('dataTypeUtil') >


	<cffunction name="encryptDecryptPassword" access="remote" returntype="String" output="false">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="direction" type="string" required="no" default="encrypt">
		
		<cfset result = "">
		<cfif arguments.direction eq "encrypt">
			<cfif len(arguments.password)>
				<cfset encryptSeed = variables.encryptSeed & variables.encryptKey>
				<cfset encryptAlgorithm = variables.encryptAlgorithm>
				<cfset result = Encrypt(arguments.password, encryptSeed, encryptAlgorithm)>
			</cfif>
		<cfelse>
			<cfif len(arguments.password)>
				<cfset encryptSeed = variables.encryptSeed & variables.encryptKey>
				<cfset encryptAlgorithm = variables.encryptAlgorithm>
				<cfset result = Decrypt(arguments.password, encryptSeed, encryptAlgorithm)>
			</cfif>	
		</cfif>	
		
		<cfreturn result>
	</cffunction>
	
	
	<cffunction name="getDayOfWeekNumber" access="private" returntype="numeric" output="false">
		<cfargument name="dow" type="string" required="true" hint="Sunday, Monday, etc..." >
		
		<cfset var local = {} />
		<cfset local.retVal = 0 />
		<cfswitch expression="#trim(arguments.dow)#">
		<cfcase value="Monday">
			<cfset local.retVal = 1 />
		</cfcase>
		<cfcase value="Tuesday">
			<cfset local.retVal = 2 />
		</cfcase>
		<cfcase value="Wednesday">
			<cfset local.retVal = 3 />
		</cfcase>
		<cfcase value="Thursday">
			<cfset local.retVal = 4 />
		</cfcase>
		<cfcase value="Friday">
			<cfset local.retVal = 5 />
		</cfcase>
		<cfcase value="Saturday">
			<cfset local.retVal = 6 />
		</cfcase>
		</cfswitch>
		
		<cfreturn local.retVal> 
	</cffunction>
	
	
	<cffunction name="createUniqueId" access="private" returntype="string" output="false">
		<cfset var local = {} />
		<cfset local.retVal = insert('-', createuuid(), 23) />
		
		<cfreturn local.retVal>
	</cffunction>
	
	
	<cffunction name="getEmailList" access="private" returntype="string" output="false">
		<cfargument name="tartanId" type="numeric" required="true" >
		<cfset var local = {} />
		<cfset local.emails = '' />
		<!--- get the supervisor email --->
		<cfquery name="qSupervisorId" datasource="#APPLICATION.security.DSN#">
			select u2.email
			from UserInfo u
			inner join DirectoryInfo d on u.tartanID = d.tartanID
				inner join UserInfo u2 on d.supervisorUserId = u2.networkUserId
			where u.tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#" > 
		</cfquery>
		<cfset local.emails = listappend(local.emails, trim(qSupervisorId.email), ',') />
		<!--- get followees' emails --->
		<cfquery name="qFollowees" datasource="#variables.config.getDSN()#">
			select u.email
			from argent.security.dbo.UserInfo u
				inner join followers f on f.followerId = u.tartanId
			where followeeId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#" > 
		</cfquery>
		<cfloop query="qFollowees">
			<cfif not listfindnocase(local.emails, trim(qFollowees.email), ',')>
				<cfset local.emails = listappend(local.emails, trim(qFollowees.email), ',') />
			</cfif>
		</cfloop>
		<cfreturn local.emails>
	</cffunction>
	
	
	<cffunction name="sendOutOfOfficeEmails" access="private" returntype="void" output="false">
		<cfargument name="emails" type="string" required="true">
		<cfargument name="fname" type="string" required="true">
		<cfargument name="startTime" type="string" required="true">
		<cfargument name="endTime" type="string" required="false" default="">
		<cfargument name="event" type="string" required="false" default="">
		
		<cfset var local = {} />
		<cfset local.subject = 'Out of Office - ' & arguments.fname />
		<cfif len(trim(arguments.event))>
			<cfset local.subject = local.subject & ': ' & arguments.event />
		</cfif>
		<cfloop index="email" list="#arguments.emails#" delimiters=",">
<cfmail to="#email#"
		from="helpdesk@sinclair.edu"
		subject="#local.subject#"
		type="html">
#arguments.fname# will be Out of the Office beginning #dateformat(arguments.starttime, 'mmm dd, yyyy')# at #timeformat(arguments.starttime, 'hh:mm tt')#<cfif len(trim(arguments.endtime))> and ending #dateformat(arguments.endtime, 'mmm dd, yyyy')# at #timeformat(arguments.endtime, 'hh:mm tt')#</cfif>.
</cfmail>
		</cfloop>
	</cffunction>
	
	
	<cffunction name="sendLateEmails" access="private" returntype="void" output="false">
		<cfargument name="emails" type="string" required="true">
		<cfargument name="fname" type="string" required="true">
		<cfargument name="lateBy" type="string" required="true">
		<cfargument name="lateReason" type="string" required="false" default="">
		
		<cfset var local = {} />
		<cfset local.lateby = arguments.lateby & ' minutes' />
		<cfif arguments.lateby gt 59>
			<cfset local.hours = int(arguments.lateby/60) />
			<cfset local.mins = (arguments.lateby - (local.hours*60)) />
			<cfset local.lateby = local.hours & ' hour' />
			<cfif local.hours neq 1>
				<cfset local.lateby = local.lateby & 's' />
			</cfif>
			<cfif local.mins gt 0>
				<cfset local.lateby = local.lateby & ' and ' & local.mins & ' minute' />
				<cfif local.mins neq 1>
					<cfset local.lateby = local.lateby & 's' />
				</cfif>
			</cfif>
		</cfif>
		<cfset local.subject = arguments.fname & ' - Late by ' & local.lateBy />
		<cfloop index="email" list="#arguments.emails#" delimiters=",">
<cfmail to="#email#"
		from="helpdesk@sinclair.edu"
		subject="#local.subject#"
		type="html">
#arguments.fname# will be Late by #local.lateBy#<cfif len(trim(arguments.lateReason))> due to #arguments.lateReason#</cfif>.
</cfmail>
		</cfloop>
	</cffunction>
	
	
	<cffunction name="sendError" access="remote" returntype="void">
		<cfargument name="prop1" type="any" required="false" default="#structnew()#">
		<cfargument name="prop2" type="any" required="false" default="#structnew()#">
		<cfargument name="funcName" type="string" required="false" default="wtf">
		
<cfmail to="brian.cooney"
		from="mac.availability@sinclair.edu"
		subject="error :: #arguments.funcName#"
		type="html">
		<cfdump var="#arguments.prop1#">
		<cfdump var="#arguments.prop2#">
</cfmail>
	</cffunction>
	
<!--- method to clean up special characters from a string
	** returns a clean string
	**
	--->
	<cffunction name="deAccent" access="remote" returntype="string">
		<cfargument name="str" type="string" required="false" default="">
		<cfscript>
			//based on the approach found here: http://stackoverflow.com/a/1215117/894061
			var Normalizer = createObject("java","java.text.Normalizer");
			var NormalizerForm = createObject("java","java.text.Normalizer$Form");
			var normalizedString = Normalizer.normalize(str, createObject("java","java.text.Normalizer$Form").NFD);
			var pattern = createObject("java","java.util.regex.Pattern").compile("\p{InCombiningDiacriticalMarks}+");
			return pattern.matcher(normalizedString).replaceAll("");
		</cfscript>
	</cffunction>
</cfcomponent>

<!---

component displayname="AbstractRestAPI" extends="taffy.core.resource" 
{
	variables.dataTypeUtil = Application.beanFactory.getBean('dataTypeUtil');
}

--->