<cfcomponent displayname="AccessTypesMembersAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/AccessTypes/{id}">
	
	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<cfset variables.appID = variables.dao.getApplicationID() />
	<!--- <cfset variables.cookieDomainName = variables.dao.getCookieDomainName()> --->
	<cfset variables.cookieDomainName = "">
	<cfset variables.securityPassHash = variables.dao.getSecurityPassHash()>
	<cfset variables.encryptKey = variables.dao.getEncryptKey()>
	<cfset variables.encryptSeed = variables.dao.getEncryptSeed()>
	<cfset variables.encryptAlgorithm = variables.dao.getEncryptAlgorithm()>

	<cffunction name="get" access="public" output="false" hint="returns all user entries">
		<cfargument name="id" type="any" required="false" default=""/>
		<cfargument name="limit" type="numeric" required="false" default="100"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
	
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.securityDSN#">
				select s.ACCESSTYPEID, s.ACCESSTYPE
				from AccessTypes s
				where s.accessTypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
			</cfquery>
			
			<cfscript>
				s = structnew();
				structinsert(s, 'id', local.q.ACCESSTYPEID);
				structinsert(s, 'roleName', local.q.ACCESSTYPE);
				arrayappend(local.retArray, s);
			</cfscript>
		
			<cfset local.success = true/>
		<cfcatch type="any">
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch.detail);
				structinsert(s, 'arguments', arguments);
				arrayappend(local.retArray, s);
			</cfscript>
		</cfcatch>
		</cftry>
		
		<cfscript>
			structinsert(local.stdata, 'rows', local.retArray);
			structinsert(local.stdata, 'success', local.success);
			structinsert(local.stdata, 'results', 1);
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>
	
	
	<cffunction name="put" access="remote" output="false">
	
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		
		<cftry>
			<cfif arguments.id eq 0>
				<!--- insert --->
				<cfquery name="local.max" datasource="#variables.securityDSN#">
					select max(accessTypeID)+1 as newId
					from AccessTypes
				</cfquery>
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					insert into AccessTypes (accessTypeId, applicationId, accessType)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.max.newId#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#int(variables.appID)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.accessType)#" >)
				</cfquery>
			<cfelse>
				<!--- update --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					update AccessTypes
					set accessType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.accessType)#" > 
					where accessTypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#" > 
				</cfquery>
			</cfif>
			<cfset temp = arrayappend(local.retArray, arguments) />
			<cfset local.success = true />
		<cfcatch type="any">
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch.detail);
				structinsert(s, 'arguments', arguments);
				arrayappend(local.retArray, s);
				senderror(arguments,cfcatch,'access types');
			</cfscript>
		</cfcatch>
		</cftry>
		
		<cfscript>
			structinsert(local.stdata, 'rows', local.retArray);
			structinsert(local.stdata, 'success', local.success);
			structinsert(local.stdata, 'results', 1);
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>
	
	
	<cffunction name="delete" access="remote" output="false">
		<cfargument name="id" type="numeric" required="true" default="0">
	
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		<cfset temp = sendError(arguments,structnew(),'put userrole') />
		
		<cftry>
			<cfif isnumeric(arguments.id) and arguments.id gt 0>
				<!--- delete role and any assigned users/accessTypes to that role --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					delete from AccessTypes 
					where accesstypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#">
				</cfquery>
				<cfquery name="local.qq" datasource="#variables.securityDSN#">
					delete from AccessControl
					where accesstypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#">
				</cfquery>
				<cfset temp = arrayappend(local.retArray, arguments) />
				<cfset local.success = true />
			<cfelse>
				<cfscript>
					s = structnew();
					structinsert(s, 'error', 'Invalid ID');
					structinsert(s, 'details', 'ID needs to be an integer greater than 0');
					structinsert(s, 'arguments', arguments);
					arrayappend(local.retArray, s);
				</cfscript>
			</cfif>
		<cfcatch type="any">
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch.detail);
				structinsert(s, 'arguments', arguments);
				arrayappend(local.retArray, s);
			</cfscript>
		</cfcatch>
		</cftry>
		
		<cfscript>
			structinsert(local.stdata, 'rows', local.retArray);
			structinsert(local.stdata, 'success', local.success);
			structinsert(local.stdata, 'results', 1);
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>

</cfcomponent>