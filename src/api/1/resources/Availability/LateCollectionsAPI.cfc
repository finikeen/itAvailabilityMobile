<cfcomponent displayname="LateCollectionsAPI" 
             extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/Late">

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
					order by dateSubmitted
				</cfif>) as 'RowNumber'
				from Late
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
					querysetcell(local.q, 'dateSubmitted', extraData.dateSubmitted, local.q.currentRow);
					querysetcell(local.q, 'lateBy', local.q.lateBy, local.q.currentRow);
					querysetcell(local.q, 'lateReason', local.q.display, local.q.lateReason);
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
			from Late
			where 0=0
			<cfif arraylen(local.filter)>
				and (
				<cfset delim = ""/>
				<cfloop array="#local.filter#" index="thisFilter">
					<cfif thisFilter.property is "STARTDATEC">
						<cfset newdt = createdate(listgetat(thisFilter.value, 3, '/'), 
						                          listgetat(thisFilter.value, 1, '/'),
						                          listgetat(thisFilter.value, 2, '/'))/>
						<cfset newdt = dateformat(newdt, 'yyyy-mm-dd')/>
						#delim# s.test_date >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#newdt#">
					<cfelseif thisFilter.property is "ENDDATEC">
						<cfset newdt = dateadd('d', 1, 
						                       createdate(listgetat(thisFilter.value, 3, '/'), listgetat(thisFilter.value, 1, '/'), listgetat(thisFilter.value, 2, '/')))/>
						<cfset newdt = dateformat(newdt, 'yyyy-mm-dd')/>
						#delim# s.test_date < <cfqueryparam cfsqltype="cf_sql_varchar" value="#newdt#">
					<cfelseif thisFilter.property is "STARTDATEE">
						<cfset newdt = createdate(listgetat(thisFilter.value, 3, '/'), 
						                          listgetat(thisFilter.value, 1, '/'),
						                          listgetat(thisFilter.value, 2, '/'))/>
						#delim# s.evaluation_dt >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcDateTime(newdt)#">
					<cfelseif thisFilter.property is "ENDDATEE">
						<cfset newdt = dateadd('d', 1, 
						                       createdate(listgetat(thisFilter.value, 3, '/'), listgetat(thisFilter.value, 1, '/'), listgetat(thisFilter.value, 2, '/')))/>
						#delim# s.evaluation_dt < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcDateTime(newdt)#">
					<cfelse>
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
					</cfif>
					<cfset delim = "AND"/>
					<cfif thisFilter.property is "LAST_NM">
						<cfset delim = "OR"/>
					</cfif>
				</cfloop>
				)
			</cfif>
		</cfquery>
	
		<cfreturn local.q.thecount>
	</cffunction>
	
	
	<cffunction name="post" access="public" output="false" hint="updates following status">
		
		<cfset var local = {} />
		<cfset local.retArray = [] />
		<cfset local.stdata = {} />
		<cfset local.success = false />
		<cfset arguments.id = createuuid() />
		<cfset senderror(local,arguments,'post late') />
		<cftry>
			<cfquery name="local.q" datasource="#variables.config.getDSN()#">
				insert into Late (id, tartanId, dateSubmitted, lateBy, lateReason)
				values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" >
						, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanId#">
						, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdatetime(now())#">
						, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.lateBy#">
						, <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lateReason#" >)
			</cfquery>
			<cfset arrayappend(local.retArray, arguments) />
			<cfset local.success = true />
			
			<!--- get list of followers --->
			<cfset local.emails = getEmailList(arguments.tartanId) />
			<!--- send late email to list of followers --->
			<cfif listlen(local.emails,',')>
				<cfquery name="local.qUser" datasource="#APPLICATION.security.DSN#">
					select fullname
					from userinfo
					where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanId#">
				</cfquery>
				<cfset local.fname = listlast(local.quser.fullname) & ' ' & listfirst(local.quser.fullname) />
				<cfset sendLateEmails(emails=local.emails, fname=local.fname, lateBy=arguments.lateBy, lateReason=arguments.lateReason) />
			</cfif>
			
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