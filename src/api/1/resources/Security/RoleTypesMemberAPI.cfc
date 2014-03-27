<cfcomponent displayname="RolesTypesMembersAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/RoleTypes/{id}">
	
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
				select s.ROLEID, s.ROLENAME
				from RoleTypes s
				where s.roleID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
			</cfquery>
			
			<cfscript>
				s = structnew();
				structinsert(s, 'id', local.q.ROLEID);
				structinsert(s, 'roleName', local.q.ROLENAME);
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
					select max(roleID)+1 as newId
					from RoleTypes
				</cfquery>
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					insert into RoleTypes (roleId, applicationId, roleName)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.max.newId#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#int(variables.appID)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.roleName)#" >)
				</cfquery>
			<cfelse>
				<!--- update --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					update RoleTypes
					set roleName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.roleName)#" > 
					where roleID = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#" > 
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
					delete from RoleTypes 
					where roleid = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#">
				</cfquery>
				<cfquery name="local.qq" datasource="#variables.securityDSN#">
					delete from RoleControl
					where roleid = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#">
				</cfquery>
				<cfquery name="local.qqq" datasource="#variables.securityDSN#">
					delete from AccessControl
					where roleid = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#">
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