<cfcomponent displayname="EmployeesCollectionsAPI" 
             extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/Employees">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert", "", "util")>
	<cfset variables.deptlist = "513,449,592,447,581,595,596,456,454,597,593,594">

	<cffunction name="get" access="public" output="false" hint="returns all contacts">
		<cfargument name="limit" type="numeric" required="false" default="1000"/>
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
			<cfquery name="local.q" datasource="#APPLICATION.security.DSN#" maxrows="#arguments.limit#">
				with OrderedQuery as (
				select distinct u.fullname, u.tartanId, di.title, d.departmentName, d.parentId as parentDeptId, 
				di.deptId, di.location, di.isDepartmentHead, di.supervisorUserId, u2.fullName as supervisorName,
				pn.phoneSCC, pn.phoneSCCMobile, pn.phonePersonalMobile, pn.phoneHome, u.email, '' as following,
				'' as isOnCall, '' as outOfOffice, '' as startTime, '' as endTime, '' as eventType, '' as schedule,
				'' as imgLink, row_number() over (
				<cfif arraylen(local.sort)>
					order by 
					#local.sort[arraylen(local.sort)].property# 
					#local.sort[arraylen(local.sort)].direction#
				<cfelse>
					order by d.departmentName asc, di.isDepartmentHead asc, u.fullname asc
				</cfif>) as 'RowNumber'
				from userinfo u
					inner join directoryinfo di on u.tartanid = di.tartanid
					inner join departments d on di.deptid = d.departmentid
					left outer join userinfo u2 on di.supervisorUserId = u2.networkUserId
					left outer join tundra.employee_availability.dbo.PhoneNumbers pn on u.tartanid = pn.tartanid
				where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.showExternal = <cfqueryparam cfsqltype="cf_sql_bit" value="1"> 
				and di.preferredPhone = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
				and di.deptid in (#variables.deptlist#)
				<cfif arraylen(local.filter)>
					and (0=0
					<cfset delim = "and"/>
					<cfloop array="#local.filter#" index="thisFilter">
						<cfif isdefined('thisFilter.property')>
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
						</cfif>
					</cfloop>
					)
				</cfif>)
				select *
				from OrderedQuery
				where RowNumber between (#arguments.start + 1#) and (#arguments.limit + arguments.start#)
			</cfquery>
			
			<cfloop query="local.q">
				<cfscript>
					tid = local.q.tartanid;
					schedData = getScheduleData(tid);
					querysetcell(local.q, 'schedule', serializeJSON(schedData.schedule), local.q.currentRow);
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
		
		<cfquery name="local.q" datasource="#APPLICATION.security.DSN#">
			select count(*) as thecount
			from userinfo u
				inner join directoryinfo di on u.tartanid = di.tartanid
				inner join departments d on di.deptid = d.departmentid
			where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.deptid in (#variables.deptlist#)
			<cfif arraylen(local.filter)>
				and (0=0
				<cfset delim = "AND"/>
				<cfloop array="#local.filter#" index="thisFilter">
					<cfif isdefined('thisFilter.property')>
						#delim#
						<cfif thisFilter.property is "LAST_NM">
							(
						</cfif>
						#thisFilter.property#
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
						<cfif thisFilter.property is "FIRST_NM">
							)
						</cfif>
					</cfif>
				<cfset delim = "AND"/>
				</cfloop>
				)
			</cfif>
		</cfquery>
	
		<cfreturn local.q.thecount>
	</cffunction>
	
	
	<cffunction name="getScheduleData" access="private" returntype="struct">
		<cfargument name="tartanId" type="numeric" required="true">
		
		<cfset var local = {} />
		<cfset local.retStruct = structnew() />
		<cfset local.retStruct.schedule = arraynew(1) />
		<!--- get the user's schedule --->
		<cfquery name="local.qq" datasource="#variables.config.getDSN()#">
			select *
			from schedule
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanId#" >
			order by orderId
		</cfquery>
		<cfif local.qq.recordCount gt 0>
			<cfset local.retStruct.schedule = variables.dtc.queryToArrayOfStructures(local.qq, local.retStruct.schedule)>
		<cfelse>
			<cfloop from="1" to="6" index="i" step="1">
				<cfset local.item = structnew() />
				<cfset structinsert(local.item, 'id', '') />
				<cfset structinsert(local.item, 'tartanid', arguments.tartanId) />
				<cfset structinsert(local.item, 'orderId', i) />
				<cfset structinsert(local.item, 'startTime', '') />
				<cfset structinsert(local.item, 'endTime', '') />
				<cfset structinsert(local.item, 'dayOfWeek', dayofweekasstring(i+1)) />
				<cfset arrayappend(local.retstruct.schedule, local.item) />
			</cfloop>
		</cfif>
		
		<cfreturn local.retStruct >
	</cffunction>
	
</cfcomponent>