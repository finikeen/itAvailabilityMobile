<cfcomponent name="EmailService"  displayname="EmailService Service" hint="I am the primary service for EmailService objects" output="false">

<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeInstanceProperties --->
	<cfscript>
		variables.instance.cfcPackage = APPLICATION.cfcPackage;
		variables.instance.cfcName = "EmailService";
		
		// The Data Access Object for this Service
		//variables.instance.dao = APPLICATION.availability.objectFactory.getObjectByName("EmailService","dao","");
	</cfscript>
	<!--- END MANAGEDCODE BLOCK --->
	
		
	
	<cffunction name="init" access="public" returntype="void" output="false" displayname="Service Constructor" hint="I initialize this service as part of the framework startup.">
		<cfscript>
			// run init code here
		</cfscript>
	</cffunction>


	
	
	<!--- 
	***********************
	**  DISTRIBUTE EMAILS
	***********************
	--->
	<cffunction name="distributeEmails" access="public" returntype="any" output="false" displayname="distributeEmails" hint="I distribute email messages for a given group of email addresses.">
		<cfargument name="event" type="any" required="true" />
		<cfscript>
			// event result object
			eventResult = APPLICATION.onlineAdmissions.objectFactory.getObjectByName("EventResult","bean","event");
			args = StructNew();
			event = arguments.event;
			data = event.getData();

			// Set security and optionalParams
			args.security = event.getSecurity();
			args.optionalParams = event.getOptionalParams();
			
			// Params for the EmailService
			// arrEmailAddresses should be an Array with 
			// a series of structures containing sendToEmail
			// and sendFromEmail properties
			arrEmailAddresses = ArrayNew(1);
			if (StructKeyExists(data, 'arrEmailAddresses'))
			{
				arrEmailAddresses = data.arrEmailAddresses;
			
			}

			emailSubject = "";
			if (StructKeyExists(data, 'emailSubject'))
			{
				emailSubject = data.emailSubject;
			}
			
			templatePath = "";
			if (StructKeyExists(data,'templatePath'))
			{
				templatePath = data.templatePath;
			}
			
			emailMessage = "";
			if (StructKeyExists(data,'emailMessage'))
			{
				emailMessage = data.emailMessage;
			}
			
			// The messageParams Structure is used to include any variables in the email message, in case the type
			// of message is an included html page. all of the variables will then appear
			// in the messageParams structure for use in the email message.
			messageParams = StructNew();
			if (StructKeyExists(data,'messageParams'))
			{
				messageParams = data.messageParams;
			}
			
		</cfscript>

		<!---
		<cftry>
		--->
        
			<cfloop from="1" to="#ArrayLen(arrEmailAddresses)#" index="i">
				
				<cfset strCurrEmailAddresses = arrEmailAddresses[i]>
				<cfset sendToEmail = strCurrEmailAddresses.toEmail>
				<cfset sendFromEmail = strCurrEmailAddresses.fromEmail>
				
				<!--- send the email message --->
				<cfmail to="#sendToEmail#"
						from="#sendFromEmail#"
						subject="#emailSubject#"
						type="html">
							<cfif len(templatePath)>
								<cfinclude template="#templatePath#">
							<cfelse>
								#emailMessage#
							</cfif>
						</cfmail>			
			
			</cfloop>
		
        <!---
			<cfcatch type="any">
				<cfset eventResult.setSuccess(false)>
				<cfset eventResult.setErrorMessage("There was an error distributing the email messages. Please contact your system administrator for additional assistance.")>
			</cfcatch>
		</cftry>
	--->

		
		<cfreturn eventResult>
	</cffunction>

</cfcomponent>
