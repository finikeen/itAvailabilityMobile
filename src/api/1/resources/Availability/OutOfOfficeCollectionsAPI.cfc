<cfcomponent displayname="OutOfOfficeCollectionsAPI" 
             extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/OutOfOffice">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert", "", "util")>

	<cffunction name="get" access="public" output="false" hint="returns all contacts">
		<cfargument name="limit" type="numeric" required="false" default="1000"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
		<cfargument name="myId" type="numeric" required="false" default="0" hint="div by 4567"/>
	
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
		<cfset local.myId = (arguments.myId / 4567) />
	
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
				where 0=0
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
			from OutOfOffice
			where 0=0
			<cfif arraylen(local.filter)>
				and (
				<cfset delim = ""/>
				<cfloop array="#local.filter#" index="thisFilter">
					#delim#
					<cfif thisFilter.property is "LAST_NM">
						(
					</cfif>
					#thisFilter.property#
					<cfif isNumeric(thisFilter.value)>
						= cfqueryparam cfsqltype="cf_sql_numeric" value="#thisFilter.value#">
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
					<cfif thisFilter.property is "FIRST_NM">
						)
					</cfif>
					<cfset delim = "AND"/>
				</cfloop>
				)
			</cfif>
		</cfquery>
	
		<cfreturn local.q.thecount>
	</cffunction>
	
	
	<cffunction name="post" access="public" output="false" hint="updates following status">
		
		<cfscript>
			var local = {};
			arguments.id = createuuid();
			local.retArray = [];
			local.stdata = {};
			local.success = false;
			local.startTime = '';
			local.endTime = '';
			// senderror(local,arguments,'ooo post');
			if (isdate(arguments.startDate) and isdate(arguments.starttime)) {
				local.startTime = createodbcdatetime(dateformat(arguments.startDate, 'mmmm dd yyyy') & timeformat(arguments.startTime, 'hh:mm:ss TT'));
			} else {
				local.stime = '';
				if (isdate(arguments.startDate)) {
					local.stime = dateformat(arguments.startDate, 'mmmm dd yyyy');
				} else {
					local.stime = dateformat(listfirst(arguments.startDate,'T'), 'mmmm dd yyyy');
				}
				if (isdate(arguments.startTime)) {
					local.stime = local.stime & timeformat(arguments.startTime, 'hh:mm:ss TT');
				} else {
					local.stime = local.stime & timeformat(listlast(arguments.startTime,'T'), 'hh:mm:ss TT');
				}
				local.startTime = createodbcdatetime(stime);
			}
			
			if (isdefined('arguments.endDate') and  isdefined('arguments.endTime') and isdate(arguments.endDate) and isdate(arguments.endTime)) {
				local.endTime = createodbcdatetime(dateformat(arguments.endDate, 'mmmm dd yyyy') & timeformat(arguments.endTime, 'hh:mm:ss TT'));
			} else if (isdefined('arguments.endDate') and isdate(arguments.endDate)) {
				local.endTime = createodbcdatetime(dateformat(arguments.endDate, 'mmmm dd yyyy'));
			}
			local.isAllDay = false;
			if (isdefined('arguments.isallday')) {
				local.isAllDay = arguments.isAllDay;
			}
		</cfscript>
		<cftry>
			<cfquery name="local.q" datasource="#variables.config.getDSN()#">
				insert into OutOfOffice (id, tartanId, isAllDay, startTime, endTime, eventType, display)
				values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" >
						, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanId#">
						, <cfqueryparam cfsqltype="cf_sql_bit" value="#local.isAllDay#">
						, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.starttime#">
						, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.endtime#" null="#(not isdate(local.endTime))#">
						, <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.eventType#" >
						, <cfqueryparam cfsqltype="cf_sql_bit" value="1">)
			</cfquery>
			<cfset arrayappend(local.retArray, arguments) />
			<cfset local.success = true />
			<cfset local.emails = '' />
			<!--- get list of followers, if startTime = today and (no endTime or endTime in future) --->
			<cfif dateformat(local.starttime, 'short') is dateformat(now(), 'short')>
				<cfif not isdate(local.endTime)>
					<cfset local.emails = getEmailList(arguments.tartanId) />
				<cfelseif isdate(local.endTime) and datecompare(local.endTime, now(), 'n')>
					<cfset local.emails = getEmailList(arguments.tartanId) />
				</cfif>
			</cfif>
			<!--- send Out of Office email to list of followers --->
			<cfif listlen(local.emails,',')>
				<cfquery name="local.qUser" datasource="#APPLICATION.security.DSN#">
					select fullname
					from userinfo
					where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanId#">
				</cfquery>
				<cfset local.fname = listlast(local.quser.fullname) & ' ' & listfirst(local.quser.fullname) />
				<cfset sendOutOfOfficeEmails(emails=local.emails, fname=local.fname, startTime=local.startTime, endTime=local.endTime, event=arguments.eventType) />
			</cfif>
			<!--- if startTime is tomorrow or later, queue email for 7am --->
			<!--- (need to write scheduled task) --->
			
		<cfcatch type="any">
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch);
				structinsert(s, 'arguments', arguments);
				arrayappend(local.retArray, s);
				senderror(cfcatch,arguments,'ooo error');
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