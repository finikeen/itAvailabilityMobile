<cfcomponent displayname="PreferencesMembersAPI"
			 extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/Preferences/{id}">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert", "", "util")>

	<cffunction name="get" access="public" output="false" hint="returns all contacts">
		<cfargument name="limit" type="numeric" required="false" default="1000"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
		<cfargument name="id" type="any" required="false" default=""/>
	
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
		<cfset local.tartanId = (arguments.id / 4567) />
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.config.getDSN()#" maxrows="#arguments.limit#">
				select id as userid, name, value
				from preferences
				where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" > 
				<cfif arraylen(local.filter)>
					and (
					<cfset delim = ""/>
					<cfloop array="#local.filter#" index="thisFilter">
						#delim# #thisFilter.property#
						<cfif isNumeric(thisFilter.value)>
							= <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisFilter.value#">
						<cfelseif isarray(thisFilter.value)>
							<cfset delim2 = ""/>
							in (
							<cfloop array="#thisFilter.value#" index="thisValue">
								#delim2# '#thisValue#'
								<cfset delim2 = ','/>
							</cfloop>
							)
						<cfelse>
							like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisFilter.value#%">
						</cfif>
						<cfset delim = "AND"/>
					</cfloop>
					)
				</cfif>
			</cfquery>
			
			<cfset local.retArray = variables.dtc.queryToArrayOfStructures(local.q, local.retArray)>
			<cfset local.success = true/>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch.detail);
				structinsert(s, 'arguments', serializeJSON(cfcatch));
				arrayappend(local.retArray, s);
			</cfscript>
			
		</cfcatch>
		</cftry>
	
		<cfscript>
			structinsert(local.stdata, 'rows', local.retArray);
			structinsert(local.stdata, 'success', local.success);
			structinsert(local.stdata, 'results', arraylen(local.retArray));
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>
	

	<cffunction name="put" access="public" output="false">
		<cfargument name="id" required="true" type="any" hint="tartanId / 4567">
		
		<cfset var local = {} />
		<cfset local.retArray = [] />
		<cfset local.stdata = {} />
		<cfset local.success = false />
		<cfset local.tartanId = (arguments.id / 4567) />
		<cfset senderror(arguments, local.tartanid,'pref put') />
		<cftry>
			<cfquery name="local.d" datasource="#variables.config.getDSN()#">
				delete from preferences
				where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" > 
			</cfquery>
			<cfif len(trim(arguments.deptName))>
				<cfquery name="local.d" datasource="#variables.config.getDSN()#">
					insert into preferences (id, name, value)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" >
							, <cfqueryparam cfsqltype="cf_sql_varchar" value="deptName" >
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.deptName#" >)
				</cfquery>
			</cfif>
			<cfif len(trim(arguments.follows))>
				<cfquery name="local.d" datasource="#variables.config.getDSN()#">
					insert into preferences (id, name, value)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" >
							, <cfqueryparam cfsqltype="cf_sql_varchar" value="follows" >
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.follows#" >)
				</cfquery>
			</cfif>
			<cfif len(trim(arguments.keyword))>
				<cfquery name="local.d" datasource="#variables.config.getDSN()#">
					insert into preferences (id, name, value)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" >
							, <cfqueryparam cfsqltype="cf_sql_varchar" value="keyword" >
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.keyword#" >)
				</cfquery>
			</cfif>
			<cfif len(trim(arguments.status))>
				<cfquery name="local.d" datasource="#variables.config.getDSN()#">
					insert into preferences (id, name, value)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" >
							, <cfqueryparam cfsqltype="cf_sql_varchar" value="status" >
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.status#" >)
				</cfquery>
			</cfif>
			<cfset arrayappend(local.retArray, arguments) />
			<cfset local.success = true />
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch.detail);
				structinsert(s, 'arguments', serializeJSON(cfcatch));
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