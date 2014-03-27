<cfcomponent displayname="OutOfOfficeMembersAPI" 
             extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/OutOfOffice/{id}">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert", "", "util")>

	<cffunction name="get" access="public" output="false" hint="returns all contacts">
		<cfargument name="limit" type="numeric" required="false" default="1000"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
		<cfargument name="id" type="string" required="true" />
	
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
				select distinct *, row_number() over (
				<cfif arraylen(local.sort)>
					order by 
					#local.sort[arraylen(local.sort)].property# 
					#local.sort[arraylen(local.sort)].direction#
				<cfelse>
					order by startTime, endTime
				</cfif>) as 'RowNumber'
				from OutOfOffice
				where id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" > 
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
				</cfif>)
				select *
				from OrderedQuery
				where RowNumber between (#arguments.start + 1#) and (#arguments.limit + arguments.start#)
			</cfquery>
			
			<cfloop query="local.q">
				<cfscript>
					querysetcell(local.q, 'id', extraData.id, local.q.currentRow);
					querysetcell(local.q, 'tartanId', extraData.tartanId, local.q.currentRow);
					querysetcell(local.q, 'isAllDay', extraData.isAllDay, local.q.currentRow);
					querysetcell(local.q, 'startDate', dateformat(local.q.startTime,'mm/dd/yyyy'), local.q.currentRow);
					querysetcell(local.q, 'startTime', timeFormat(local.q.startTime, 'hh:mm TT'), local.q.currentRow);
					querysetcell(local.q, 'endDate', dateformat(local.q.endTime,'mm/dd/yyyy'), local.q.currentRow);
					querysetcell(local.q, 'endTime', timeFormat(local.q.endTime, 'hh:mm TT'), local.q.currentRow);
					querysetcell(local.q, 'eventType', local.q.endTime, local.q.currentRow);
					querysetcell(local.q, 'display', local.q.display, local.q.currentRow);
				</cfscript>
			</cfloop>
			
			<cfset local.retArray = variables.dtc.queryToArrayOfStructures(local.q, local.retArray)>
			<cfset local.success = true/>
		<cfcatch type="any">
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
	
	
	<cffunction name="put" access="public" output="false" hint="updates following status">
		
		<cfset var local = {} />
		<cfset local.retArray = [] />
		<cfset local.stdata = {} />
		<cfset local.success = false />
		<cfset local.endTime = createodbcdatetime(dateformat(arguments.endDate, 'mmmm dd yyyy') & timeformat(arguments.endTime, 'hh:mm:ss TT')) />
	
		<cftry>
			<cfquery name="local.q" datasource="#variables.config.getDSN()#">
				update OutOfOffice
				set endTime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.endtime#" null="#(not isdate(arguments.endDate))#">
				where id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" >
			</cfquery>
			<cfset arrayappend(local.retArray, arguments) />
			<cfset local.success = true />
			
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
			structinsert(local.stdata, 'results', 1);
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction> 
	
</cfcomponent>