<cfcomponent displayname="UserSecurityInfoCollectionsAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/UserSecurityInfo">
	
	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<cfset variables.appID = variables.dao.getApplicationID()>
	<!--- <cfset variables.cookieDomainName = variables.dao.getCookieDomainName()> --->
	<cfset variables.cookieDomainName = "">
	<cfset variables.securityPassHash = variables.dao.getSecurityPassHash()>
	<cfset variables.encryptKey = variables.dao.getEncryptKey()>
	<cfset variables.encryptSeed = variables.dao.getEncryptSeed()>
	<cfset variables.encryptAlgorithm = variables.dao.getEncryptAlgorithm()>

	<cffunction name="get" access="public" output="false" hint="returns all user entries">
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
				select s.*, u.fullName, u.email, row_number() over (
				<cfif arraylen(local.sort)>
					order by 
					#local.sort[arraylen(local.sort)].property# 
					#local.sort[arraylen(local.sort)].direction#
				<cfelse>
					order by s.networkUserID desc
				</cfif>) as 'RowNumber'
				from UserSecurityInfo s
					left outer join UserInfo u on s.tartanID = u.tartanID
					inner join ApplicationControl ac on s.tartanID = ac.tartanID
				where ac.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
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
					structinsert(s, 'networkUserID', local.q.NETWORKUSERID);
					structinsert(s, 'password', encryptDecryptPassword(local.q.PASSWORD,'decrypt'));
					structinsert(s, 'firstName', listlast(local.q.FULLNAME,','));
					structinsert(s, 'lastName', listfirst(local.q.FULLNAME,','));
					structinsert(s, 'email', local.q.EMAIL);
					
					// structinsert(s, 'password', local.q.PASSWORD);
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
			from UserSecurityInfo s
				inner join ApplicationControl ac on s.tartanID = ac.tartanID
			where ac.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
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
	
	

	<cffunction name="post" access="public" output="false" hint="insert a new user record">
		
		<cfset var local = {}/>
		
		<cfreturn representationOf(arguments).withStatus(200)>
	</cffunction>
	
</cfcomponent>
