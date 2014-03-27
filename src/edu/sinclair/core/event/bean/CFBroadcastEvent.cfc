<!--- 

 --->
<cfcomponent displayname="CFBroadcastEvent" hint="Event broadcasted from UI and interpreted for cf">
	<cfproperty name="cfcType" type="string" required="0" displayname="cfcType" hint="The type of cfc. Values are bean, service, dao.  Not required.  Defaults to service if no other type is supplied." default="service">
	<cfproperty name="cfServiceMethod" type="string" required="1" displayname="cfServiceMethod" hint="The service method to call." default="">
	<cfproperty name="objectType" type="string" required="1" displayname="object type" hint="The object type related to the data property of this event." default="">
	<cfproperty name="cfcPath" type="string" required="0" displayname="cfcPath" hint="The folder name where the bean, dao and service directories are located for the cfc by objectType." default="">
	<cfproperty name="data" type="any" required="1" displayname="data" hint="The data for the event" default="">
	<cfproperty name="security" type="any" required="0" displayname="security" hint="Security info" default="StructNew()">
	<cfproperty name="optionalParams" type="any" required="0" displayname="optional params" hint="Optional parameters to use in service calls" default="StructNew()">
	<cfproperty name="serviceCallDescriptionObj" type="struct" required="0" displayname="serviceCallDescriptionObj" hint="I associate this call with other calls from a serviceGroup. by id and serviceGroup name." default="structnew()">



	<cfscript>
		//default values:
		variables.instance.cfcType = "service";
		variables.instance.cfServiceMethod = "";
		variables.instance.objectType = "";
		variables.instance.cfcPath = "";
		variables.instance.data = StructNew();
		variables.instance.security = StructNew();
		variables.instance.optionalParams = StructNew();
		variables.instance.serviceCallDescriptionObj = StructNew();
	</cfscript>

	<!--- 
	***********************
	**  INIT
	***********************
	--->
	<cffunction name="init" access="public" returntype="CFBroadcastEvent" output="false" displayname="CFBroadcastEvent Constructor" hint="I initialize an object of type CFBroadcaseEventObject.">
		<cfargument name="cfcType" type="string" required="no" default="service"/>
		<cfargument name="cfServiceMethod" type="string" requires="yes" default=""/>
		<cfargument name="objectType" type="string" requires="yes" default=""/>
		<cfargument name="cfcPath" type="string" requires="no" default=""/>			
		<cfargument name="data" type="any" required="yes" default=""/>
		<cfargument name="security" type="any" required="no" default="StructNew()"/>
		<cfargument name="optionalParams" type="any" required="no" default="StructNew()"/>
		<cfargument name="serviceCallDescriptionObj" type="struct" required="no" default="structnew()"/>

		<cfscript>
			setCFCType(arguments.cfcType);
			setCFServiceMethod(arguments.cfServiceMethod);
			setObjectType(arguments.objectType);
			setCFCPath(arguments.cfcPath);
			setData(arguments.data);
			setSecurity(arguments.security);
			setOptionalParams(arguments.optionalParams);
			setServiceCallDescriptionObj(arguments.serviceCallDescriptionObj);
			
			return this;
		</cfscript>
	</cffunction>


	<!--- 
	***********************
	**  METHODS
	***********************
	--->
	<cffunction name="getArgumentCollectionFromProps" access="public" returntype="struct" output="false" displayname="getArgumentCollectionFromProps" hint="Returns a structure containing properties to be used as arguments in method calls.">
		<cfscript>
			args = StructNew();

			data = getData();
			if (isStruct(data))
			{
				for (key in data)
				{
					args[key] = data[key];
				}
			}else{
				args.data = data;
			}
			args.security = getSecurity();
			args.optionalParams = getOptionalParams();

			return args;
		</cfscript>
	</cffunction>


	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->	

	<cffunction name="getCFCType" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.CFCType>
	</cffunction>
	<cffunction name="setCFCType" access="public" output="FALSE">
		<cfargument name="cfcType" type="string" required="1"/>
		<cfset variables.instance.cfcType = arguments.cfcType>
	</cffunction>
	
	<cffunction name="getCFServiceMethod" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.cfServiceMethod>
	</cffunction>
	<cffunction name="setCFServiceMethod" access="public" output="FALSE">
		<cfargument name="cfServiceMethod" type="string" required="1"/>
		<cfset variables.instance.cfServiceMethod = arguments.cfServiceMethod>
	</cffunction>

	<cffunction name="getObjectType" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.objectType>
	</cffunction>
	<cffunction name="setObjectType" access="public" output="FALSE">
		<cfargument name="objectType" type="string" required="1"/>
		<cfset variables.instance.objectType = arguments.objectType>
	</cffunction>
	
	<cffunction name="getCFCPath" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.cfcPath>
	</cffunction>
	<cffunction name="setCFCPath" access="public" output="FALSE">
		<cfargument name="cfcPath" type="string" required="1"/>
		<cfset variables.instance.cfcPath = arguments.cfcPath>
	</cffunction>

	<cffunction name="getData" access="public" returnType="any" output="FALSE">
		<cfreturn variables.instance.data>
	</cffunction>
	<cffunction name="setData" access="public" output="FALSE">
		<cfargument name="data" type="any" required="1"/>
		<cfset variables.instance.data = arguments.data>
	</cffunction>
	
	<cffunction name="getSecurity" access="public" returnType="any" output="FALSE">
		<cfreturn variables.instance.security>
	</cffunction>
	<cffunction name="setSecurity" access="public" output="FALSE">
		<cfargument name="security" type="any" required="1"/>
		<cfset variables.instance.security = arguments.security>
	</cffunction>

	<cffunction name="getOptionalParams" access="public" returnType="any" output="FALSE">
		<cfreturn variables.instance.optionalParams>
	</cffunction>
	<cffunction name="setOptionalParams" access="public" output="FALSE">
		<cfargument name="optionalParams" type="any" required="1"/>
		<cfset variables.instance.optionalParams = arguments.optionalParams>
	</cffunction>

	<cffunction name="getServiceCallDescriptionObj" access="public" returnType="struct" output="FALSE">
		<cfreturn variables.instance.serviceCallDescriptionObj>
	</cffunction>
	<cffunction name="setServiceCallDescriptionObj" access="public" output="FALSE">
		<cfargument name="serviceCallDescriptionObj" type="struct" required="1"/>
		<cfset variables.instance.serviceCallDescriptionObj = arguments.serviceCallDescriptionObj>
	</cffunction>

</cfcomponent>
