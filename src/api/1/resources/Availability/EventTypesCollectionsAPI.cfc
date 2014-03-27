<cfcomponent displayname="EventTypesCollectionsAPI" 
             extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/EventTypes">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	

	<cffunction name="get" access="public" output="false" hint="returns all event types">
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
			<cfquery name="local.q" datasource="#variables.config.getDSN()#" maxrows="#arguments.limit#">
				with OrderedQuery as (
				select s.*, row_number() over (
				<cfif arraylen(local.sort)>
					order by 
					#local.sort[arraylen(local.sort)].property# 
					#local.sort[arraylen(local.sort)].direction#
				<cfelse>
					order by s.eventType desc
				</cfif>) as 'RowNumber'
				from EventTypes s
				where 0=0
				<cfif arraylen(local.filter)>
					and (0=0
					<cfloop array="#local.filter#" index="thisFilter">
						<cfif isdefined('thisFilter.value')>
							and #thisFilter.property#
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
						</cfif>
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
					structinsert(s, 'id', local.q.id);
					structinsert(s, 'eventType', local.q.EVENTTYPE);
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
	
		<cfquery name="local.q" datasource="#variables.config.getDSN()#">
			select count(*) as thecount
			from EventTypes s
			where 0=0
			<cfif arraylen(local.filter)>
				and (0=0
				<cfloop array="#local.filter#" index="thisFilter">
					<cfif isdefined('thisFilter.value')>
						and #thisFilter.property#
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
					</cfif>
				</cfloop>
				)
			</cfif>
		</cfquery>
	
		<cfreturn local.q.thecount>
	</cffunction>
	

	<cffunction name="post" access="public" output="false" hint="insert a new role record">
		<cfset var local = {}/>
		
		<cfreturn representationOf(arguments).withStatus(200)>
	</cffunction>
	
</cfcomponent>