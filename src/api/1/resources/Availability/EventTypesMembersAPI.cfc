<cfcomponent displayname="EventTypesMembersAPI"
			 extends="availability.api.1.resources.AbstractCollectionsAPI"
			 taffy_uri="/EventTypes/{id}">
	
	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	

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
		
		<cftry>
			<cfquery name="local.q" datasource="#variables.config.getDSN()#">
				select s.*
				from EventTypes s
				where s.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" >
				order by s.eventType 
			</cfquery>
			
			<cfscript>
				s = structnew();
				structinsert(s, 'id', local.q.id);
				structinsert(s, 'eventType', local.q.EVENTTYPE);
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
		<cfset sendError(arguments,structnew(),'put eventType') />
		
		<cftry>
			<cfif arguments.id eq 0>
				<!--- insert --->
				<cfquery name="local.max" datasource="#variables.config.getDSN()#">
					select max(id)+1 as newId
					from EventTypes
				</cfquery>
				<cfquery name="local.q" datasource="#variables.config.getDSN()#">
					insert into EventTypes (id, eventType)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.max.newId#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.eventType)#" >)
				</cfquery>
			<cfelse>
				<!--- update --->
				<cfquery name="local.q" datasource="#variables.config.getDSN()#">
					update EventTypes
					set eventType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.eventType)#" > 
					where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#int(arguments.id)#" > 
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

</cfcomponent>