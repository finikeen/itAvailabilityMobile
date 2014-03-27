<cfcomponent displayname="UserAssignmentCollectionsAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/UserAssignments">
	
	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<cfset variables.appID = variables.dao.getApplicationID() />
	<!--- <cfset variables.cookieDomainName = variables.dao.getCookieDomainName()> --->
	<cfset variables.cookieDomainName = "">
	<cfset variables.securityPassHash = variables.dao.getSecurityPassHash()>
	<cfset variables.encryptKey = variables.dao.getEncryptKey()>
	<cfset variables.encryptSeed = variables.dao.getEncryptSeed()>
	<cfset variables.encryptAlgorithm = variables.dao.getEncryptAlgorithm()>

	<cffunction name="get" access="public" output="true" hint="returns all user entries">
		<cfargument name="limit" type="numeric" required="false" default="100"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
	
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		<cfset local.sort = arraynew(1)/>
		<cfif len(trim(arguments.sort))>
			<cfset local.sort = deserializeJSON(arguments.sort)/>
		</cfif>
		<cfset local.filter = arraynew(1)/>
		<cfif len(trim(arguments.filter))>
			<cfset local.filter = deserializeJSON(arguments.filter)/>
		</cfif>
		<cfset local.s = structnew()/>
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.securityDSN#" maxrows="#arguments.limit#">
				with OrderedQuery as (
				select distinct u.networkuserID, u.fullName, u.tartanID, row_number() over (
				<cfif arraylen(local.sort)>
					order by 
					#local.sort[arraylen(local.sort)].property# 
					#local.sort[arraylen(local.sort)].direction#
				<cfelse>
					order by u.fullName desc
				</cfif>) as 'RowNumber'
				from UserInfo u
					inner join ApplicationControl ac on u.tartanID = ac.tartanID
					inner join ApplicationTypes a on a.applicationID = ac.applicationID
				where a.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
				<cfif arraylen(local.filter)>
					and (
					<cfset delim = ""/>
					<cfloop array="#local.filter#" index="thisFilter">
						#delim# #thisFilter.property#
						<cfif isNumeric(thisFilter.value)>
							= <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisFilter.value#">
						<cfelseif isarray(thisFilter.value)>
                           <cfset delim2 = "" />
                           in (<cfloop array="#thisFilter.value#" index="thisValue">
                                  #delim2# '#thisValue#'
								  <cfset delim2 = ',' />
                                  </cfloop>)
						<cfelse>
							like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
						</cfif>
						<cfset delim = "AND"/>
					</cfloop>
					)
				</cfif>)
				select *
				from OrderedQuery
				where RowNumber between #(arguments.start + 1)# and #(arguments.limit + arguments.start)#
			</cfquery>
			
			<cfloop query="local.q">
				
				<cfscript>
					s = structnew();
					structinsert(s, 'id', local.q.TARTANID);
					structinsert(s, 'userName', local.q.NETWORKUSERID);
					structinsert(s, 'fullName', local.q.FULLNAME);
					structinsert(s, 'roles', getRolesByTartanID(local.q.TARTANID));
					arrayappend(local.retArray, s);
				</cfscript>
				
			</cfloop>
		
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
			structinsert(local.stdata, 'results', getCount(arguments.filter));
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>
	
	
	<cffunction name="getCount" access="private" returntype="numeric">
		<cfargument name="filter" type="any" requried="false" default=""/>
	
		<cfset var local = {}/>
		<cfset local.filter = arraynew(1)/>
		<cfif len(trim(arguments.filter))>
			<cfset local.filter = deserializeJSON(arguments.filter)/>
		</cfif>
	
		<cfquery name="local.q" datasource="#variables.securityDSN#">
			select count(*) as thecount
			from UserInfo u
				inner join ApplicationControl ac on u.tartanID = ac.tartanID
				inner join ApplicationTypes a on a.applicationID = ac.applicationID
			where a.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
			<cfif arraylen(local.filter)>
				and (
				<cfset delim = ""/>
				<cfloop array="#local.filter#" index="thisFilter">
					#delim# #thisFilter.property#
					<cfif isNumeric(thisFilter.value)>
						= <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisFilter.value#">
					<cfelseif isarray(thisFilter.value)>
                       <cfset delim2 = "" />
                       in (<cfloop array="#thisFilter.value#" index="thisValue">
                              #delim2# '#thisValue#'
							  <cfset delim2 = ',' />
                              </cfloop>)
					<cfelse>
						like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
					</cfif>
					<cfset delim = "AND"/>
				</cfloop>
				)
			</cfif>
		</cfquery>
	
		<cfreturn local.q.thecount>
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
	

	<cffunction name="post" access="public" output="false" hint="insert a new role record">
		
	
		<cfset var local = {}/>
		
		<cfreturn representationOf(arguments).withStatus(200)>
	</cffunction>
	
</cfcomponent>
