<cfcomponent displayname="contact" hint="Contact Information logic">
	
	<cfset variables.config = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.dtc = APPLICATION.security.objectFactory.getObjectByName("datatypeconvert","","util")>
	<cfset variables.deptlist = "513,449,592,447,581,595,596,456,454,597,593,594">
	
	<cffunction name="getAll" access="remote" returntype="array" output="true">
		<cfset var local = {} />
		<cfset local.results = arraynew(1) />
		
		<cfloop index="dept" list="#variables.deptlist#" delimiters=",">
			<cfquery name="local.q" datasource="security">
				select u.fullname, u.tartanId, di.title, d.departmentName as deptName, d.parentId as parentDeptId, di.deptid, di.location,
				di.supervisorUserId as supervisorName, di.actualPhone as phoneSCC, '' as phoneSCCMoble, '' as phonePersonalMobile,
				'' as phoneHome, u.email, 'false' as isOnCall
				from userinfo u
					inner join directoryinfo di on u.tartanid = di.tartanid
					inner join departments d on di.deptid = d.departmentid
				where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
					and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
					and di.deptid = <cfqueryparam cfsqltype="cf_sql_integer" value="#dept#" > 
				order by di.isdepartmenthead desc, di.orderid, u.fullname
			</cfquery>
			<cfset local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results)>
		</cfloop>
		<cfreturn local.results>
	</cffunction>
	
	
	<cffunction name="getAllTree" access="remote" returntype="struct" output="true">
		<cfargument name="deptId" type="numeric" required="false" hint="top level department Id" default="513">
		<cfscript>
			var local = {};
			/* local.results = structnew();
			local.results.success = true;
			local.results.children = getTreeNodeData(arguments.deptId); */
			local.results = arraynew(1);
			local.q = querynew('success,fullname,children,expanded');
			queryaddrow(local.q,1);
			querysetcell(local.q, 'success','true');
			querysetcell(local.q, 'expanded','true');
			querysetcell(local.q, 'fullname','IT Employee Contact List');
			local.kids = getTreeNodeData(arguments.deptId);
			local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results);
			local.results[1].children = local.kids;
			
			return local.results[1];
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getOnCallTree" access="remote" returntype="struct" output="true">
		<cfscript>
			var local = {};
			local.results = arraynew(1);
			local.q = querynew('success,fullname,children,expanded');
			queryaddrow(local.q,1);
			querysetcell(local.q, 'success','true');
			querysetcell(local.q, 'expanded','true');
			querysetcell(local.q, 'fullname','On Call');
			local.kids = getOnCall();
			local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results);
			local.results[1].children = local.kids;
			
			return local.results[1];
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getOutOfOfficeTree" access="remote" returntype="struct" output="true">
		<cfscript>
			var local = {};
			local.results = arraynew(1);
			local.q = querynew('success,fullname,children,expanded');
			queryaddrow(local.q,1);
			querysetcell(local.q, 'success','true');
			querysetcell(local.q, 'expanded','true');
			querysetcell(local.q, 'fullname','Out Of Office');
			local.kids = getOutOfOffice();
			local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results);
			local.results[1].children = local.kids;
			
			return local.results[1];
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getTreeNodeData" access="private" returntype="struct" output="true" >
		<cfargument name="deptId" type="numeric" required="true" >
		<cfscript>
			var local = {};
			local.results = arraynew(1);
			// local.results = getDeptInfo(arguments.deptId);
			local.results = getDeptInfo(arguments.deptId);
			// queryaddcolumn(local.q,'children',arraynew(1));
			local.kids = arraynew(1);
			
			local.subdepts = getAllDeptsByDept(arguments.deptId);
			if (listlen(local.subdepts) gt 0) {
				
				for (local.i=1; local.i lte listlen(local.subdepts); local.i=(local.i+1)) {
					local.deptId = listgetat(local.subdepts, local.i);
					local.subdeptInfo = getTreeNodeData(local.deptId);
					arrayappend(local.kids, local.subdeptInfo);
				}
				local.contacts = getAllContactsByDept(arguments.deptId);
				if (arraylen(local.contacts)) {
					for (local.j=1; local.j lte arraylen(local.contacts); local.j=(local.j+1)) {
						arrayappend(local.kids, local.contacts[local.j]);
					}
				}
			} else {
				local.contacts = getAllContactsByDept(arguments.deptId);
				if (arraylen(local.contacts)) {
					for (local.k=1; local.k lte arraylen(local.contacts); local.k=(local.k+1)) {
						arrayappend(local.kids, local.contacts[local.k]);
					}
				}
			}
			// local.results.children = local.kids;
			
			// querysetcell(local.q,'children',local.kids);
			// local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results);
			
			local.results[1].children = local.kids;
			
			return local.results[1];
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getDeptInfo" access="private" returntype="array" output="true" >
		<cfargument name="deptId" type="numeric" required="true" default="0" >
		<cfset var local = {} />
		<cfset local.results = arraynew(1) />
		
		<cfquery name="local.q" datasource="security">
			select d.departmentName as fullname, '' as tartanId, '' as title, '' as deptName, '' as parentDeptId, d.departmentid as deptId, '' as location,
				'' as supervisorName, '' as phoneSCC, '' as phoneSCCMobile, '' as phonePersonalMobile,
				'' as phoneHome, '' as email, '' as isOnCall, <cfif arguments.deptId eq 513>'true'<cfelse>'false'</cfif> as expanded,
				'true' as loaded, '' as children
			from departments d
			where d.departmentId = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.deptId#">
		</cfquery>
		<cfset local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results)>
		
		<cfreturn local.results>
	</cffunction>
	
	
	<cffunction name="getAllDeptsByDept" access="private" returntype="string" output="true" >
		<cfargument name="deptId" type="numeric" required="true" default="0" >
		<cfset var local = {} />
		<cfset local.results = '' />
		
		<cfquery name="local.q" datasource="security">
			select d.departmentid
			from departments d
			where d.parentId = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.deptId#">
			<cfif arguments.deptId eq 513>
				and d.departmentname like 'IT %'
			</cfif>
			order by d.departmentname
		</cfquery>
		<cfset local.results = valuelist(local.q.departmentId)>
		<cfreturn local.results>
	</cffunction>
	
	
	<cffunction name="getAllContactsByDept" access="private" returntype="array" output="true" >
		<cfargument name="deptId" type="numeric" required="true" default="0" >
		<cfset var local = {} />
		<cfset local.results = arraynew(1) />
		
		<cfquery name="local.q" datasource="security">
			select u.fullname, u.tartanId, di.title, d.departmentName as deptName, d.parentId as parentDeptId, di.deptid, di.location,
			di.supervisorUserId as supervisorName, di.actualPhone as phoneSCC, '' as phoneSCCMoble, '' as phonePersonalMobile,
			'' as phoneHome, u.email, 'false' as isOnCall, 'true' as leaf
			from userinfo u
				inner join directoryinfo di on u.tartanid = di.tartanid
				inner join departments d on di.deptid = d.departmentid
			where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
				and di.deptid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.deptId#" > 
			order by di.isdepartmenthead desc, u.fullname
		</cfquery>
		<cfset local.results = variables.dtc.queryToArrayOfStructures(local.q, local.results)>
		<cfreturn local.results>
	</cffunction>
	
	
	<cffunction name="getOnCall" access="remote" returntype="struct" output="true" >
		<cfset var local = {} />
		<cfset local.success = false/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1) />
		
		<cftry>
			<cfquery name="local.q" datasource="security">
				select u.fullname, u.tartanId, di.title, d.departmentName as deptName, d.parentId as parentDeptId, di.deptid, di.location,
				di.supervisorUserId as supervisorName, di.actualPhone as phoneSCC, '' as phoneSCCMoble, '' as phonePersonalMobile,
				'' as phoneHome, u.email, 'true' as isOnCall, 'true' as leaf
				from userinfo u
					inner join directoryinfo di on u.tartanid = di.tartanid
					inner join departments d on di.deptid = d.departmentid
				where u.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
					and di.isactive = <cfqueryparam cfsqltype="cf_sql_varchar" value="y">
					and di.deptid = <cfqueryparam cfsqltype="cf_sql_integer" value="456" > 
				order by di.isdepartmenthead desc, u.fullname
			</cfquery>
			<cfset local.retArray = variables.dtc.queryToArrayOfStructures(local.q, local.retArray)>
		
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
			structinsert(local.stdata, 'results', arraylen(local.retArray));
		</cfscript>
		
		<cfreturn local.stdata >
	</cffunction>
	
	
	<cffunction name="getOutOfOffice" access="remote" returntype="struct" output="true" >
		<cfset var local = {} />
		<cfset local.success = false/>
		<cfset local.stdata = {}/>
		<cfset local.retArray = arraynew(1) />
		<cfset local.date = dateformat(now()) />
		
		<cftry>
			<cfquery name="local.qq" datasource="#variables.config.getDSN()#">
				select fullname, tartanId, eventType, endTime, '' as title, '' as deptName, '' as parentDeptId,
				'' as deptid, '' as location, '' as supervisorName, '' as phoneSCC, '' as phoneSCCMoble,
				'' as phonePersonalMobile, '' as phoneHome, '' as email, 'true' as leaf
				from OutOfOffice
				where display = <cfqueryparam cfsqltype="cf_sql_bit" value="true">
			</cfquery>
			
			<cfloop query="local.qq">
				<cfset tartanid = local.qq.tartanid />
				<cfset rowid = local.qq.currentrow />
				<cfquery name="local.q" datasource="security">
					select di.title, d.departmentName as deptName, d.parentId as parentDeptId, di.deptid, di.location,
					di.supervisorUserId as supervisorName, di.actualPhone as phoneSCC, u.email
					from userinfo u
						inner join directoryinfo di on u.tartanid = di.tartanid
						inner join departments d on di.deptid = d.departmentid
					where u.tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#tartanid#" >
				</cfquery>
				<cfscript>
					querysetcell(local.qq, 'title', local.q.title, rowid);
					querysetcell(local.qq, 'deptName', local.q.deptName, rowid);
					querysetcell(local.qq, 'parentDeptId', local.q.parentDeptId, rowid);
					querysetcell(local.qq, 'deptid', local.q.deptid, rowid);
					querysetcell(local.qq, 'location', local.q.location, rowid);
					querysetcell(local.qq, 'supervisorName', local.q.supervisorName, rowid);
					querysetcell(local.qq, 'phoneSCC', local.q.phoneSCC, rowid);
					querysetcell(local.qq, 'email', local.q.email, rowid);
				</cfscript>
			</cfloop>
			<cfset local.retArray = variables.dtc.queryToArrayOfStructures(local.qq, local.retArray)>
		
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
			structinsert(local.stdata, 'results', arraylen(local.retArray));
		</cfscript>
		
		<cfreturn local.stdata >
	</cffunction>
	
</cfcomponent>