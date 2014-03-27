<cfcomponent displayname="SearchUsersCollectionsAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/SearchUsers">
	
	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<cfset variables.appID = variables.dao.getApplicationID()>

	<cffunction name="get" access="public" output="false" hint="returns users">
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
				select u.*, row_number() over (
				<cfif arraylen(local.sort)>
					order by 
					#local.sort[arraylen(local.sort)].property# 
					#local.sort[arraylen(local.sort)].direction#
				<cfelse>
					order by u.networkUserID asc
				</cfif>) as 'RowNumber'
				from UserInfo u
				where u.isActive <> <cfqueryparam cfsqltype="cf_sql_char" value="N" >
					and u.tartanid not in (select tartanid from ApplicationControl
										   where applicationId = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">)
				<cfif arraylen(local.filter)>
					<cfloop array="#local.filter#" index="thisFilter">
						<cfif isNumeric(thisFilter.value)>
							and u.tartanId = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisFilter.value#">
						<cfelse>
							and (
								u.networkuserid like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
								or u.fullName like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
							)
						</cfif>
					</cfloop>
				</cfif>)
				select *
				from OrderedQuery
				where RowNumber between #(arguments.start + 1)# and #(arguments.limit + arguments.start)#
			</cfquery>
			
			<cfloop query="local.q">
				
				<cfscript>
					s = structnew();
					structinsert(s, 'id', local.q.TARTANID);
					structinsert(s, 'networkUserId', trim(local.q.NETWORKUSERID));
					structinsert(s, 'fullName', trim(local.q.FULLNAME));
					structinsert(s, 'email', trim(local.q.EMAIL));
					
					arrayappend(local.retArray, s);
				</cfscript>
				
			</cfloop>
		
			<cfset local.success = true/>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
			
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
			where u.isActive <> <cfqueryparam cfsqltype="cf_sql_char" value="N" > 
				and u.tartanid not in (select tartanid from ApplicationControl
									   where applicationId = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">)
			<cfif arraylen(local.filter)>
				<cfloop array="#local.filter#" index="thisFilter">
					<cfif isNumeric(thisFilter.value)>
						and u.tartanId = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisFilter.value#">
					<cfelse>
						and (
							u.networkuserid like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
							or u.fullName like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
						)
					</cfif>
				</cfloop>
			</cfif>
		</cfquery>
	
		<cfreturn local.q.thecount>
	</cffunction>
	

	<cffunction name="post" access="public" output="false" hint="insert a new role record">
		
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1) />
		<cfset local.success = false />
		
		<cfif isdefined('arguments.id')>
			<cfquery name="local.q" datasource="#variables.securityDSN#">
				insert into ApplicationControl(applicationID, tartanID, isActive)
				values (<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">
						, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
						, <cfqueryparam cfsqltype="cf_sql_bit" value="1" >)
			</cfquery>
			<cfset local.success = true />
			<cfset arrayappend(local.retarray, arguments) />
		<cfelse>
			<cfscript>
				s = structnew();
				structinsert(s, 'error', 'Error');
				structinsert(s, 'details', 'A Tartan ID is required.');
				structinsert(s, 'arguments', arguments);
				arrayappend(local.retArray, s);
			</cfscript>
		</cfif>
		
		<cfscript>
			structinsert(local.stdata, 'rows', local.retArray);
			structinsert(local.stdata, 'success', local.success);
			structinsert(local.stdata, 'results', 1);
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>
	
</cfcomponent>
