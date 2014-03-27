<cfcomponent displayname="UserSecurityInfoMembersAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/UserSecurityInfo/{id}">
	
	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<cfset variables.appID = variables.dao.getApplicationID() />
	<cfset variables.minTartanId = (variables.appID * 1000000) />
	<!--- <cfset variables.cookieDomainName = variables.dao.getCookieDomainName()> --->
	<cfset variables.cookieDomainName = "">
	<cfset variables.securityPassHash = variables.dao.getSecurityPassHash()>
	<cfset variables.encryptKey = variables.dao.getEncryptKey()>
	<cfset variables.encryptSeed = variables.dao.getEncryptSeed()>
	<cfset variables.encryptAlgorithm = variables.dao.getEncryptAlgorithm()>

	<cffunction name="get" access="public" output="false" hint="returns user entry by id">
		<cfargument name="limit" type="numeric" required="false" default="100"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.securityDSN#">
				select s.*
				from UserSecurityInfo s
				where s.tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
			</cfquery>
			
			<cfscript>
				s = structnew();
				structinsert(s, 'id', local.q.TARTANID);
				structinsert(s, 'networkUserID', local.q.NETWORKUSERID);
				structinsert(s, 'password', encryptDecryptPassword(local.q.PASSWORD,'decrypt'));
				// structinsert(s, 'password', local.q.PASSWORD);
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
		<cfset local.newTartanId = (variables.minTartanId + 1) />
		<cfset local.password = encryptDecryptPassword(arguments.password,'encrypt') />
		<cftry>
			<cfif arguments.id eq 0>
				<cfquery name="q" datasource="#variables.securityDSN#">
					select max(tartanid)+1 as newTartanId
					from UserInfo
					where tartanId > <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.minTartanId#" >
						and tartanId < <cfqueryparam cfsqltype="cf_sql_integer" value="#(variables.minTartanId + 1000000)#" >
				</cfquery>
				<cfif q.recordcount eq 1 and q.newTartanId gt variables.minTartanId>
					<cfset local.newTartanId = q.newTartanId />
				</cfif>
				<!--- insert into userSecurityInfo --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					insert into UserSecurityInfo (tartanId, networkUserId, password)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.newTartanId#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.networkuserid)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.password#" >)
				</cfquery>
				<!--- insert into UserInfo --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					insert into UserInfo (tartanID, networkUserID, fullName, isActive, objectID, email)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.newTartanId#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.networkuserid)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.lastName)#, #trim(arguments.firstName)#" >,
							<cfqueryparam cfsqltype="cf_sql_char" value="y" >,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuID()#" >,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.email)#" > )
				</cfquery>
				<!--- add tartanid to ApplicationControl, so the user shows up --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					insert into ApplicationControl (applicationID, tartanID, isActive)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#local.newTartanId#">,
							<cfqueryparam cfsqltype="cf_sql_bit" value="1">)
				</cfquery>
			<cfelse>
				<!--- update --->
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					update UserSecurityInfo
					set networkUserId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.networkuserid)#" >,
						password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.password#" > 
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
				</cfquery>
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					update UserInfo
					set networkUserId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.networkuserid)#" >,
						fullName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.lastName)#, #trim(arguments.firstName)#" > ,
						email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.email)#" >
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
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
		
		<cftry>
			<cfif isnumeric(arguments.id) and arguments.id gt variables.minTartanId>
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					delete from UserSecurityInfo 
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
				</cfquery>
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					delete from UserInfo
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
				</cfquery>
				<cfquery name="local.q" datasource="#variables.securityDSN#">
					delete from ApplicationControl
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" > 
						and applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.appID#" > 
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