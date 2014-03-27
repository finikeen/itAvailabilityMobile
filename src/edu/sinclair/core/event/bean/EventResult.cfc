<cfcomponent displayName="EventResult" hint="Transport object for results from broadcasted events.">

	<cfproperty name="success" type="boolean" required="1" displayname="success" hint="Whether or not the service call was successfull." default="true">
	<cfproperty name="errorMessage" type="string" required="0" displayname="errorMessage" hint="Transports error messages for failed method calls." default="">
	<cfproperty name="data" type="any" required="0" displayname="data" hint="Transports data results from broadcasted events." default="">

	<cfscript>
		// Event Result Object Properties
		variables.instance.success = true;
		variables.instance.errorMessage = "";
		variables.instance.data = "";
	</cfscript>	

	<!--- dump() --->
	<cffunction name="dump">
		<cfdump var="#arguments[1]#" label="#arguments[2]#">
	</cffunction>
	
	<!--- abort() --->
	<cffunction name="abort"><cfabort></cffunction>  
	
	<!--- init() --->
	<cffunction name="init" access="private" returntype="void" output="false" displayname="EventResult Constructor" hint="I initialize an object of type EventResult.">
		<cfargument name="success" type="boolean" default="true"/>
		<cfargument name="errorMessage" type="string" default=""/>
		<cfargument name="data" type="any" default=""/>

		<cfscript>
			setSuccess(arguments.success);
			setErrorMessage(arguments.errorMessage);
			setData(arguments.data);			
		</cfscript>
	</cffunction>
	
	
	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->
	
	<!--- Success --->	
	<cffunction name="getSuccess" access="public" returntype="boolean" output="false" hint="I return the state of the service call result.">
		<cfreturn variables.instance.success />
	</cffunction>
	<cffunction name="setSuccess" access="public" returntype="VOID" output="false" hint="I set the state of the service call result.">
		<cfargument name="success" type="boolean" required="true" />
		<cfset variables.instance.success = arguments.success />
	</cffunction>

	<!--- ErrorMessage --->
	<cffunction name="getErrorMessage" access="public" returntype="string" output="false" hint="I return the error message for a service call event result.">
		<cfreturn variables.instance.errorMessage />
	</cffunction>
	<cffunction name="setErrorMessage" access="public" returntype="VOID" output="false" hint="I set the error message for a service call result.">
		<cfargument name="errorMessage" type="string" required="true" />
		<cfset variables.instance.errorMessage = arguments.errorMessage />
	</cffunction>
	
	<!--- Data --->
	<cffunction name="getData" access="public" returntype="any" output="false" hint="I return the data from a service call event result.">
		<cfreturn variables.instance.data />
	</cffunction>
	<cffunction name="setData" access="public" returntype="VOID" output="false" hint="I set the data from a service call result.">
		<cfargument name="data" type="any" required="true" />
		<cfset variables.instance.data = arguments.data />
	</cffunction>		

</cfcomponent>