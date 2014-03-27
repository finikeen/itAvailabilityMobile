<cfcomponent displayname="UserAssignmentsMembersAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/UserAssignments/{id}">
	
	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<cfset variables.appID = variables.dao.getApplicationID() />

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
				select distinct u.networkuserID, u.tartanID, u.fullName
				from UserInfo u
					inner join ApplicationControl ac on u.tartanID = ac.tartanID
					inner join ApplicationTypes a on a.applicationID = ac.applicationID
				where a.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
					and u.tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
			</cfquery>
			
			<cfscript>
				s = structnew();
				structinsert(s, 'id', local.q.TARTANID);
				structinsert(s, 'userName', local.q.NETWORKUSERID);
				structinsert(s, 'fullName', local.q.FULLNAME);
				structinsert(s, 'roles', getRolesByTartanID(local.q.TARTANID));
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
	
	
	<cffunction name="getRolesByTartanID" access="private" output="true" returntype="array"> 
		<cfargument name="tartanID" type="numeric" required="true" > 
		<cfset var local = {} />
		<cfset local.retArray = arrayNew(1) />
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.securityDSN#">
				select rt.roleName, rt.roleID
				from RoleTypes rt
					inner join RoleControl rc on rc.roleID = rt.roleID
				where rc.tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#" >
					and rt.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">
			</cfquery>
			
			<cfloop query="local.q">
				<cfscript>
					s = structnew();
					structinsert(s, 'roleName', local.q.roleName);
					structinsert(s, 'accessTypes', getAccessTypeByRoleAndTartanID(arguments.tartanID, local.q.roleID));
					arrayappend(local.retArray, s);
				</cfscript>
			</cfloop>
			
		<cfcatch type="any">
			<cfscript>
				s = structnew();
				structinsert(s, 'error1', cfcatch.message);
				structinsert(s, 'details1', cfcatch.detail);
				structinsert(s, 'arguments1', arguments);
				arrayappend(local.retArray, s);
			</cfscript>
			
		</cfcatch>
		</cftry>
	
		<cfreturn local.retArray >
	</cffunction>
	
 
	<cffunction name="getAccessTypeByRoleAndTartanID" access="private" output="true" returntype="string"> 
		<cfargument name="tartanID" type="numeric" required="true" > 
		<cfargument name="roleID" type="numeric" required="true" > 
		<cfset var local = {} />
		<cfset local.retStr = '' />
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.securityDSN#">
				select a.accessType
				from AccessTypes a
					inner join AccessControl ac on a.accessTypeID = ac.accessTypeID
				where ac.roleID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
					and ac.tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#" >
					and a.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">
			</cfquery>
			
			<cfset local.retStr = valuelist(local.q.accessType,',') />
			<cfif listfindnocase(local.retStr,'ALL',',')>
				<cfset local.retStr = 'ALL' />
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
			
			<cfabort>
			
		</cfcatch>
		</cftry>
	
		<cfreturn local.retStr >
	</cffunction>
	
	<cffunction name="put" access="remote" output="false">
		
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		
		<cftry>
			<!--- remove the role/access type --->
				<cfquery name="local.drq" datasource="#variables.securityDSN#">
					delete from RoleControl
					where roleID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleName#" >
						and tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
				</cfquery>
				<cfquery name="local.daq" datasource="#variables.securityDSN#">
					delete from AccessControl
					where roleID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleName#" >
						and tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
				</cfquery>
			<!--- add it back --->
				<cfquery name="local.irq" datasource="#variables.securityDSN#">
					insert into RoleControl (roleID, tartanID)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleName#" >
							, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >)
				</cfquery>
				<cfloop index="acId" list="#arguments.accessTypes#" delimiters="," >
					<cfquery name="local.iaq" datasource="#variables.securityDSN#">
						insert into AccessControl (accessTypeId, tartanId, roleId)
						values (<cfqueryparam cfsqltype="cf_sql_integer" value="#acId#" >
								, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
								, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleName#" >)
					</cfquery>
				</cfloop>
				
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
				<!--- delete from the app --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					delete from ApplicationControl
					where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
						and tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
				</cfquery>
				<!--- delete all assigned roles --->
				<cfquery name="local.qq" datasource="#variables.securityDSN#">
					delete from RoleControl
					where roleid in (select roleid from RoleTypes
									 where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" >)
						and tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
				</cfquery>
				<!--- delete all assigned accesstypes --->
				<cfquery name="local.qqq" datasource="#variables.securityDSN#">
					delete from AccessControl
					where roleid in (select roleid from RoleTypes
									 where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" >)
						and tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
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