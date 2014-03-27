<cfcomponent displayName="ServiceCallDescriptionObject" hint="Ties related outgoing calls to each other, through a user defined serviceGroup description.">

	<cfproperty name="id" type="string" required="0" displayname="id" hint="The user defined id for the call." default="">
	<cfproperty name="serviceGroup" type="string" required="0" displayname="serviceGroup" hint="The group to which this call is related." default="">
	<cfproperty name="callback" type="any" required="0" displayname="callback" hint="An object with a result and fault handler method to return data to when the service group is completely loaded." default="">


	<cfscript>
		// Event Result Object Properties
		variables.instance.id = "";
		variables.instance.serviceGroup = "";
		variables.instance.callback = "";
	</cfscript>	

	<!--- dump() --->
	<cffunction name="dump">
		<cfdump var="#arguments[1]#" label="#arguments[2]#">
	</cffunction>
	
	<!--- abort() --->
	<cffunction name="abort"><cfabort></cffunction>  
	
	<!--- init() --->
	<cffunction name="init" access="private" returntype="void" output="false" displayname="ServiceCallDescription Constructor" hint="I initialize an object of type ServiceCallDescription.">
		<cfargument name="id" type="string" default=""/>
		<cfargument name="serviceGroup" type="string" default=""/>
		<cfargument name="callback" type="any" default=""/>

		<cfscript>
			setID(arguments.id);
			setServiceGroup(arguments.serviceGroup);	
			setCallback(arguments.callback);		
		</cfscript>
	</cffunction>
	
	
	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->
	
	<!--- id --->
	<cffunction name="getID" access="public" returntype="string" output="false" hint="I return the id for the service call.">
		<cfreturn variables.instance.id />
	</cffunction>
	<cffunction name="setID" access="public" returntype="VOID" output="false" hint="I set the id for the service call.">
		<cfargument name="id" type="string" required="true" />
		<cfset variables.instance.id = arguments.id />
	</cffunction>
	
	<!--- ServiceGroup --->
	<cffunction name="getServiceGroup" access="public" returntype="string" output="false" hint="I return the serviceGroup name for the service call.">
		<cfreturn variables.instance.serviceGroup />
	</cffunction>
	<cffunction name="setServiceGroup" access="public" returntype="VOID" output="false" hint="I set the serviceGroup name for the service call.">
		<cfargument name="serviceGroup" type="string" required="true" />
		<cfset variables.instance.serviceGroup = arguments.serviceGroup />
	</cffunction>		

	<!--- Callback --->
	<cffunction name="getCallback" access="public" returntype="any" output="false" hint="I return the callback for the service call.">
		<cfreturn variables.instance.callback />
	</cffunction>
	<cffunction name="setCallback" access="public" returntype="VOID" output="false" hint="I set the callback for the service call.">
		<cfargument name="callback" type="any" required="true" />
		<cfset variables.instance.callback = arguments.callback />
	</cffunction>	

</cfcomponent>