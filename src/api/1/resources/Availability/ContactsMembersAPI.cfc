<cfcomponent displayname="ContactsMembersAPI"
			 extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/Contacts/{id}">

	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config", "dao", "config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert", "", "util")>
	<cfset variables.deptlist = "513,449,592,447,581,595,596,456,454,597,593,594">

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
		<cfset local.id = (arguments.id / 4567) />
		<cfset local.myId = (arguments.myId / 4567) />
	
		<cftry>
			<cfquery name="local.q" datasource="#APPLICATION.security.DSN#" maxrows="#arguments.limit#">
				select u.fullname, u.tartanId, di.title, d.departmentName, d.parentId as parentDeptId, 
				di.deptId, di.location, di.isDepartmentHead, di.supervisorUserId, u2.fullName as supervisorName,
				pn.phoneSCC, pn.phoneSCCMobile, pn.phonePersonalMobile, pn.phoneHome, u.email, '' as following,
				'' as isOnCall, '' as outOfOffice, '' as startTime, '' as endTime, '' as eventType, '' as schedule,
				'' as outOfOfficeId, '' as imgLink
				from userinfo u
					inner join directoryinfo di on u.tartanid = di.tartanid
					inner join departments d on di.deptid = d.departmentid
					left outer join userinfo u2 on di.supervisorUserId = u2.networkUserId
					left outer join tundra.employee_availability.dbo.PhoneNumbers pn on u.tartanid = pn.tartanid
				where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and u.tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.id#" > 
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
			
			<cfloop query="local.q">
				<cfscript>
					tid = local.q.tartanid;
					extraData = getExtraData(tid, tid);
					querysetcell(local.q, 'startTime', extraData.startTime, local.q.currentRow);
					querysetcell(local.q, 'endTime', extraData.endTime, local.q.currentRow);
					querysetcell(local.q, 'eventType', extraData.eventType, local.q.currentRow);
					querysetcell(local.q, 'outOfOffice', extraData.outOfOffice, local.q.currentRow);
					querysetcell(local.q, 'outOfOfficeId', extraData.outOfOfficeId, local.q.currentRow);
					querysetcell(local.q, 'schedule', serializeJSON(extraData.schedule), local.q.currentRow);
					querysetcell(local.q, 'following', extraData.following, local.q.currentRow);
					querysetcell(local.q, 'imgLink', extraData.imgLink, local.q.currentRow);
					querysetcell(local.q, 'isOnCall', extraData.isOnCall, local.q.currentRow);
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
			structinsert(local.stdata, 'results', 1);
		</cfscript>
		
		<cfreturn representationOf(local.stdata).withStatus(200)>
	</cffunction>
	
	<cffunction name="getExtraData" access="private" returntype="struct">
		<cfargument name="tartanId" type="numeric" required="true">
		<cfargument name="followeeId" required="true" type="numeric">
		
		<cfset var local = {} />
		<cfset local.retStruct = structnew() />
		<cfset local.retStruct.startTime = '' />
		<cfset local.retStruct.endTime = '' />
		<cfset local.retStruct.eventType = '' />
		<cfset local.retStruct.outOfOffice = false />
		<cfset local.retStruct.outOfOfficeId = '' />
		<cfset local.retStruct.schedule = arraynew(1) />
		<cfset local.retStruct.following = 'No' />
		<cfset local.retStruct.imgLink = '' />
		<cfset local.retStruct.isOnCall = false />
		<!--- check the scheduled out table --->
		<cfquery name="local.q" datasource="#variables.config.getDSN()#">
			select startTime, endTime, eventType, id
			from OutOfOffice
			where tartanId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.followeeId#" >
				and startTime < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#" > 
				and (endTime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#" > 
					or endTime is null)
		</cfquery>
		<cfif local.q.recordCount gt 0>
			<cfif isdate(local.q.startTime)>
				<cfset local.retStruct.startTime = dateformat(local.q.startTime,'mm/dd/yy') & ' ' & timeformat(local.q.startTime,'hh:mmTT') />
			</cfif>
			<cfif isdate(local.q.endTime)>
				<cfset local.retStruct.endTime = dateformat(local.q.endTime,'mm/dd/yy') & ' ' & timeformat(local.q.endTime,'hh:mmTT') />
			</cfif>
			<cfset local.retStruct.eventType = local.q.eventType />
			<cfset local.retStruct.outOfOfficeId = local.q.id />
			<cfset local.retStruct.outOfOffice = true />
		</cfif>
		<!--- get the user's schedule --->
		<cfquery name="local.qq" datasource="#variables.config.getDSN()#">
			select *
			from schedule
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.followeeId#" >
			order by orderId
		</cfquery>
		<cfif local.qq.recordCount gt 0>
			<cfset local.retStruct.schedule = variables.dtc.queryToArrayOfStructures(local.qq, local.retStruct.schedule)>
		</cfif>
		<!--- check following status --->
		<cfquery name="local.qqq" datasource="#variables.config.getDSN()#">
			select *
			from Followers
			where followerId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanId#" > 
				and followeeId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.followeeId#" > 
		</cfquery>
		<cfif local.qqq.recordcount eq 1>
			<cfset local.retStruct.following = 'Yes' />
		</cfif>
		<!--- check for an image
		<cfquery name="local.qqqq" datasource="oneCardImages">
			select imgName
			from TartanImageLU
			where tartanID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#numberformat(arguments.followeeId,'000000000')#" > 
		</cfquery>
		<cfif local.qqqq.recordcount eq 1>
			<!--- <cfset local.retStruct.imgLink = 'https://data.sinclair.edu/images/' & local.qqqq.imgName /> --->
			<cfset local.retStruct.imgLink = 'https://data.sinclair.edu/images/test/' & local.qqqq.imgName />
			<cfset local.retStruct.imgLink = 'availability/assets/images/noImageAvailable.jpg' />
		</cfif> --->
		<cfset local.retStruct.imgLink = 'https://data.sinclair.edu/images/test/' & arguments.followeeId & '.jpg' />
		<!--- check for On Call status --->
		<cfquery name="local.qqqqq" datasource="#variables.config.getDSN()#">
			select *
			from OnCall
			where id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.followeeId#" >
				and startDate <= <cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdate(now())#" >
				and endDate >= <cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdate(now())#" >
		</cfquery>
		<cfif local.qqqqq.recordcount eq 1>
			<cfset local.retStruct.isOnCall = true />
		</cfif>
		
		<cfreturn local.retStruct >
	</cffunction>
	

	<cffunction name="put" access="public" output="false">
		<cfargument name="id" required="true" type="integer" hint="tartanId / 4567">
		
		<cfset local = {} />
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		<cfset local.tartanId = (arguments.id / 4567) />
			
		<cfreturn representationOf(arguments).withStatus(200)>
	</cffunction>

</cfcomponent>