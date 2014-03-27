<cfcomponent displayname="OnCallMembersAPI"
			 extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/OnCall/{id}">
	
	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.deptlist = "513,449,592,447,581,595,596,456,454,597,593,594,586">
	

	<cffunction name="get" access="public" output="false" hint="returns all user entries">
		<cfargument name="id" type="any" required="false" default=""/>
		<cfargument name="limit" type="numeric" required="false" default="100"/>
		<cfargument name="start" type="numeric" required="false" default="0"/>
		<cfargument name="filter" type="any" required="false" default=""/>
		<cfargument name="sort" type="any" required="false" default=""/>
	
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		<cfset local.dow = dayofweek(now()) />
		<cfif local.dow eq 2>
			<cfset local.startDate = createodbcdate(now()) />
		<cfelseif local.dow gt 2>
			<cfset local.tdate = dateadd('d', (2-dow), now()) />
			<cfset local.startDate = createodbcdate(local.tdate) />
		<cfelse>
			<cfset local.tdate = dateadd('d', -5, now()) />
			<cfset local.startDate = createodbcdate(local.tdate) />
		</cfif>
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.config.getDSN()#">
				select s.*, u.fullName, d.departmentName
				from OnCallList s
					left outer join OnCall oc on s.id = oc.id
					inner join argent.security.dbo.userinfo u on s.id = u.tartanId
					inner join argent.security.dbo.directoryInfo di on s.id = di.tartanId
					inner join argent.security.dbo.departments d on di.deptId = d.departmentId
				where oc.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
					and oc.startDate >= <cfqueryparam cfsqltype="cf_sql_date" value="#local.startDate#" > 
				order by u.fullName 
			</cfquery>
			
			<cfscript>
				s = structnew();
				structinsert(s, 'id', local.q.id);
				structinsert(s, 'onCallWeek0', local.q.ONCALL);
				structinsert(s, 'onCallWeek1', local.q.ONCALL);
				structinsert(s, 'onCallWeek2', local.q.ONCALL);
				structinsert(s, 'onCallWeek3', local.q.ONCALL);
				structinsert(s, 'onCallWeek4', local.q.ONCALL);
				structinsert(s, 'onCallWeek5', local.q.ONCALL);
				structinsert(s, 'onCallWeek6', local.q.ONCALL);
				structinsert(s, 'onCallWeek7', local.q.ONCALL);
				structinsert(s, 'fullName', local.q.FULLNAME);
				structinsert(s, 'departmentName', local.q.DEPARTMENTNAME);
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
		
		<cftry>
			<cfloop from="0" to="7" step="1" index="i">
				<cfset local.checkDate = createodbcdate(dateadd('d', (i*7), arguments.startDate)) />
				<cftry>
					<cfset status = evaluate('arguments.onCallWeek'&i) />
					<cfquery name="local.q" datasource="#variables.config.getDSN()#">
						select *
						from OnCall
						where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
							and startDate = <cfqueryparam cfsqltype="cf_sql_date" value="#local.checkdate#" > 
					</cfquery>
					<cfif status and not local.q.recordCount>
						<!--- insert id,start,end --->
						<cfset local.enddate = dateadd('d', 6, dateadd('d', (i*7), arguments.startDate)) />
						<cfquery name="local.qi" datasource="#variables.config.getDSN()#">
							insert into OnCall (id, startDate, endDate)
							values (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
									, <cfqueryparam cfsqltype="cf_sql_date" value="#local.checkdate#">
									, <cfqueryparam cfsqltype="cf_sql_date" value="#local.enddate#">)
						</cfquery>
					<cfelseif not status and local.q.recordCount>
						<!--- delete --->
						<cfquery name="local.q" datasource="#variables.config.getDSN()#">
							delete from OnCall
							where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
								and startDate = <cfqueryparam cfsqltype="cf_sql_date" value="#local.checkdate#" > 
						</cfquery>
					</cfif>
				<cfcatch type="any"></cfcatch>
				</cftry>
			</cfloop>
			<!--- <cfquery name="local.q" datasource="#variables.config.getDSN()#">
				update OnCall
				set onCall = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.onCall#" > 
				where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#" > 
			</cfquery> --->
			<cfset temp = arrayappend(local.retArray, arguments) />
			<cfset local.success = true />
		<cfcatch type="any">
			<cfscript>
				s = structnew();
				structinsert(s, 'error', cfcatch.message);
				structinsert(s, 'details', cfcatch.detail);
				structinsert(s, 'arguments', arguments);
				arrayappend(local.retArray, s);
				senderror(cfcatch,arguments,'put oncall error');
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
	
	<!---
	<cffunction name="delete" access="remote" output="false">
		<cfargument name="id" type="numeric" required="true" default="0">
	
		<cfset var local = {}/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1)/>
		<cfset local.success = false/>
		<cfset temp = sendError(arguments,structnew(),'put userrole') />
		
		<cftry>
			<cfif isnumeric(arguments.id) and arguments.id gt 0>
				<cfquery name="local.q" datasource="#variables.config.getDSN()#">
					delete from EventTypes 
					where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#">
				</cfquery>
				<cfset arrayappend(local.retArray, arguments) />
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
	 --->
</cfcomponent>