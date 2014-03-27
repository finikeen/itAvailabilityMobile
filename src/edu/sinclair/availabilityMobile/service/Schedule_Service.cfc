<cfcomponent displayname="status" hint="User Status logic">
	
	<cfset variables.dao = APPLICATION.availability.objectFactory.getObjectByName("Schedule","dao","availability")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert","","util")>
	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	
	<cffunction name="get" access="remote" returntype="array" output="true">
		<cfargument name="data" type="struct" required="false" default="#structnew()#" > 
		<cfset var local = {} />
		<cfset local.results = arraynew(1) />
		
		<cfquery name="local.q" datasource="#variables.config.getDSN()#">
			select *
			from schedule
			<cfif structkeyexists(arguments.data,"id")>
				where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.data.id#" >
			</cfif>
			order by orderId desc
		</cfquery>
		<cfset local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results)>

		<cfreturn local.results>
	</cffunction>
	
	
	<cffunction name="save" access="remote" returntype="any" output="true">
		<cfargument name="data" type="any" required="true" default="">
		<!--- <cfmail to="brian.cooney@sinclair.edu" from="availability@sinclair.edu" subject="wtf" type="html">
			<cfdump var="#arguments.data#">
		</cfmail>
		<cfreturn serializejson(arguments.data)> --->
		<cfif not len(trim(arguments.data.getId()))>
			<cfset arguments.data.setId(insert('-', createuuid(), 23)) />
		</cfif>
		<cfreturn variables.dao.save( arguments.data )>
	</cffunction>
	
	
	<cffunction name="delete" access="remote" returntype="any" output="true" >
		<cfargument name="data" type="any" required="true" default="">
		<cfscript>
			id = arguments.data.id;
			variables.dao.delete( id );
			return id;
		</cfscript>
	</cffunction>
	
</cfcomponent>