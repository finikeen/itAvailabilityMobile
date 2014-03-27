<cfcomponent displayname="EmployeesMembersAPI"
			 extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/Employees/{id}">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert", "", "util")>
	<cfset variables.deptlist = "513,449,592,447,581,595,596,456,454,597,593,594">

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
		<cfset local.deptId = arguments.id />
		
		<cftry>
			<cfquery name="local.q" datasource="#APPLICATION.security.DSN#" maxrows="#arguments.limit#">
				select u.fullname, u.tartanId, di.title, d.departmentName, d.parentId as parentDeptId, 
				di.deptId, di.location, di.isDepartmentHead, di.supervisorUserId, u2.fullName as supervisorName,
				pn.phoneSCC, pn.phoneSCCMobile, pn.phonePersonalMobile, pn.phoneHome, u.email, '' as schedule
				from userinfo u
					inner join directoryinfo di on u.tartanid = di.tartanid
					inner join departments d on di.deptid = d.departmentid
					left outer join userinfo u2 on di.supervisorUserId = u2.networkUserId
					left outer join tundra.employee_availability.dbo.PhoneNumbers pn on u.tartanid = pn.tartanid
				where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.showExternal = <cfqueryparam cfsqltype="cf_sql_bit" value="1"> 
				and di.preferredPhone = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
				and di.deptId in (#local.deptId#)
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
				order by di.isDepartmentHead desc, u.fullname asc
			</cfquery>
			
			<cfloop query="local.q">
				<cfscript>
					tid = local.q.tartanid;
					extraData = getScheduleData(tid);
					querysetcell(local.q, 'schedule', serializeJSON(extraData.schedule), local.q.currentRow);
				</cfscript>
			</cfloop>
			
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
	

	<cffunction name="put" access="public" output="false">
		<cfargument name="id" required="true" type="any" hint="tartanId / 4567">
		
		<cfset var local = {} />
		<cfset local.retArray = [] />
		<cfset local.stdata = {} />
		<cfset local.success = false />
		<cfset local.tartanId = (arguments.id / 4567) />
		
		<cftry>
			<cfif arguments.id is not "0" and isdefined('arguments.phoneHome')>
				<cfquery name="local.q" datasource="#variables.config.getDSN()#">
					update PhoneNumbers
					set phoneHome = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.phoneHome)#">
						, phonePersonalMobile = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.phonePersonalMobile)#">
						, phoneSCCMobile = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.phoneSCCMobile)#">
					where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#" >
				</cfquery>
			</cfif>
			<cfif isdefined('arguments.schedule') and isarray(arguments.schedule)>
				<cfloop from="1" to="#arraylen(arguments.schedule)#" index="i">
					<cfset local.item = arguments.schedule[i] />
					<!--- <cfif len(trim(item.startTime)) or len(trim(item.endTime))> --->
						<cfset local.startTime = '' />
						<cfif isdate(item.startTime)>
							<cfset local.startTime = timeformat(item.startTime, 'hh:mm TT') />
						</cfif>
						<cfset local.endTime = '' />
						<cfif isdate(item.endTime)>
							<cfset local.endTime = timeformat(item.endTime, 'hh:mm TT') />
						</cfif>
						
						<cfquery name="local.du" datasource="#variables.config.getDSN()#">
							delete from Schedule
							where tartanid = <cfqueryparam cfsqltype="cf_sql_numeric" value="#int(local.tartanId)#" >
						</cfquery>
					
						<cfquery name="local.qi" datasource="#variables.config.getDSN()#">
							insert into Schedule (id, tartanId, orderId, startTime, endTime, dayOfWeek)
							values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#createUniqueId()#" >
									, <cfqueryparam cfsqltype="cf_sql_numeric" value="#int(local.tartanId)#" >
									, <cfqueryparam cfsqltype="cf_sql_numeric" value="#getDayOfWeekNumber(item.dayOfWeek)#" >
									, <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.startTime#" >
									, <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.endTime#" >
									, <cfqueryparam cfsqltype="cf_sql_varchar" value="#item.dayOfWeek#" >)
						</cfquery>
						<
					<!--- </cfif> --->
				</cfloop>
			</cfif>
			<cfif isstruct(arguments.outofoffice) and not structisempty(arguments.outofoffice)>
				<cfset local.startDate = '' />
				<cfif isdefined('arguments.outofoffice.startDate') and  isdefined('arguments.outofoffice.startTime') and isdate(arguments.outofoffice.startDate) and isdate(arguments.outofoffice.startTime)>
					<cfset local.startTime = createodbcdatetime(dateformat(arguments.outofoffice.startDate, 'mmmm dd yyyy') & timeformat(arguments.outofoffice.startTime, 'hh:mm:ss TT')) />
				</cfif>
				<cfset local.endTime = '' />
				<cfif isdefined('arguments.outofoffice.endDate') and  isdefined('arguments.outofoffice.endTime') and isdate(arguments.outofoffice.endDate) and isdate(arguments.outofoffice.endTime)>
					<cfset local.endTime = createodbcdatetime(dateformat(arguments.outofoffice.endDate, 'mmmm dd yyyy') & timeformat(arguments.outofoffice.endTime, 'hh:mm:ss TT')) />
				<cfelseif isdefined('arguments.outofoffice.endDate') and isdate(arguments.outofoffice.endDate)>
					<cfset local.endTime = createodbcdatetime(dateformat(arguments.outofoffice.endDate, 'mmmm dd yyyy')) />
				</cfif>
				
				<cfif len(trim(local.starttime))>
					<cfquery name="local.q" datasource="#variables.config.getDSN()#">
						insert into OutOfOffice (id, tartanId, isAllDay, startTime, endTime, eventType, display)
						values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#" >
								, <cfqueryparam cfsqltype="cf_sql_integer" value="#local.tartanId#">
								, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.outofoffice.isAllDay#">
								, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.starttime#">
								, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.endtime#" null="#(not isdate(local.endTime))#">
								, <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.outofoffice.eventType#" >
								, <cfqueryparam cfsqltype="cf_sql_bit" value="1">)
					</cfquery>
					<cfset arrayappend(local.retArray, arguments) />
					<cfset local.success = true />
					
					<!--- send mail to any followers, if startTime = today --->
					<!--- if startTime is tomorrow or later, queue email for 7am --->
					<!--- (need to write scheduled task) --->
				</cfif>
			</cfif>
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