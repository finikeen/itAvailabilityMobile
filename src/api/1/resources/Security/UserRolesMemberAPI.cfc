<cfcomponent displayname="UserRolesMembersAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/UserRoles/{id}">
	
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
				select distinct u.networkuserID, u.tartanID
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
			<cfquery name="local.qRoleId" datasource="#variables.securityDSN#">
				select roleId
				from RoleTypes
				where roleName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.roleName#" >
					and applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">
			</cfquery>
			<cfset local.rID = local.qRoleID.roleId />
			<!--- remove the role --->
			<cfquery name="local.qDeleteRoleId" datasource="#variables.securityDSN#">
				delete from RoleControl
				where roleId = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.rID#">
					and tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			<!--- add it back --->
			<cfquery name="local.qAddRoleId" datasource="#variables.securityDSN#">
				insert into RoleControl (roleId, tartanId)
				values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.rID#">
						, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">)
			</cfquery>
			<!--- remove the access type --->
			<cfquery name="local.daq" datasource="#variables.securityDSN#">
				delete from AccessControl
				where roleID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.rID#" >
					and tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
			</cfquery>
			<!--- add them back --->
			<cfloop index="acId" list="#arguments.accessTypes#" delimiters="," >
				<cfif acId is "ALL">
					<cfquery name="local.qGetACID"  datasource="#variables.securityDSN#">
						select accessTypeId
						from AccessTypes
						where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">
					</cfquery>
					<cfloop query="local.qGetACID">
						<cfquery name="local.iaq" datasource="#variables.securityDSN#">
							insert into AccessControl (accessTypeId, tartanId, roleId)
							values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetACID.accessTypeId#" >
									, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
									, <cfqueryparam cfsqltype="cf_sql_integer" value="#local.rID#" >)
						</cfquery>
					</cfloop>
				<cfelse>
					<cfquery name="local.qGetACID"  datasource="#variables.securityDSN#">
						select accessTypeId
						from AccessTypes
						where AccessType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#acID#" > 
							and applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">
					</cfquery>
					<cfquery name="local.iaq" datasource="#variables.securityDSN#">
						insert into AccessControl (accessTypeId, tartanId, roleId)
						values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetACID.accessTypeId#" >
								, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
								, <cfqueryparam cfsqltype="cf_sql_integer" value="#local.rID#" >)
					</cfquery>
				</cfif>
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
		<cfset temp = sendError(arguments,structnew(),'delete user role') />
		
		<cftry>
			<cfif isnumeric(arguments.id) and arguments.id gt 0>
				<!--- delete the role --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					delete from RoleControl
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
						and roleId = (select roleid from RoleTypes
									  where applicationId = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" >
									  	and roleName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.roleName#">)
				</cfquery>
				<!--- delete all assigned access types --->
				<cfquery name="local.qq" datasource="#variables.securityDSN#">
					delete from AccessControl
					where roleid = (select roleid from RoleTypes
									where applicationId = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" >
										and roleName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.roleName#">)
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