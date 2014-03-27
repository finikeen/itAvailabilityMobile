<cfcomponent name="users.cfc" extends="Security_Service">


	<cffunction name="getUsers" access="remote" returntype="array" output="true">
		<cfargument name="dsn" type="string" required="false" default="">
		<cfset var userArray = arraynew(1) />
		
		<cfquery name="qGetAllUsers" datasource="#REQUEST.securityDSN#">
			SELECT u.networkUserID, u.fullName, u.email, u.tartanID
			FROM ApplicationControl ac
				INNER JOIN UserInfo u ON ac.tartanID = u.tartanID
			WHERE ac.applicationID = (SELECT atp.applicationID
				FROM ApplicationTypes atp
				WHERE atp.applicationName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.dsn#">)
			ORDER BY u.fullName
		</cfquery>
		<!--- 
		<cfscript>
			oldArray = arrayfromquery(qGetAllUsers);
			for (i=1; i lt arraylen(oldArray); i=i+1) {
				oldItem = oldArray[i];
				newItem = structnew();
				newItem.user = oldItem.networkuserID;
				newItem.fName = listlast(oldItem.fullName);
				newItem.lName = listfirst(oldItem.fullName);
				newItem.email = oldItem.email;
				newItem.isActive = oldItem.isActive;
				newItem.tartanID = oldItem.tartanID;
					_client = structnew();
					_client.appname = arguments.dsn;
						roles = structnew();
							current = structnew();
							current.role = '';
							current._access = arraynew(1);
						roles.current = current;
							available = arraynew(1);
							//available = getAllRolesByUser(tartanid=oldItem.tartanid); 
						roles._available = available;
					_client.roles = roles;
				newItem._client = _client;
				
				arrayappend(userArray, newItem);
			}
		</cfscript>
		 --->
		<cfif qGetAllUsers.recordCount>
			<cfset userArray = arrayfromquery(qGetAllUsers) />
		</cfif>
		
		<cfreturn userArray>
	</cffunction>
	
	
	<cffunction name="getAllUsers" access="remote" returntype="array" output="true">
		<cfargument name="includeInactive" type="string" required="false" default="false">
		
		<cfset var userArray = arraynew(1) />
		
		<cfquery name="qGetAllUsers" datasource="#REQUEST.securityDSN#">
			SELECT  u.* <!--- u.networkUserID, u.fullName, u.email, u.tartanID, u.isActive --->
			FROM UserInfo u
			<cfif ARGUMENTS.includeInactive eq "false">
				WHERE isactive is null or (isactive <> 'n' and isactive <> '0')
			</cfif>
			ORDER BY u.fullName
		</cfquery>

        <!--- Query all passwords if they exist in the database --->
		<cfset arrSecurityPass = ArrayNew(1)>   
        <cfloop query="qGetAllUsers">
			<cfquery name="qUserSecurityInfo" datasource="#REQUEST.securityDSN#">
				SELECT *
				FROM UserSecurityInfo
				WHERE tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetAllUsers.tartanID#">
			</cfquery>
			<cfset decryptedPassword = "">
			<cfif qUserSecurityInfo.RECORDCOUNT gt 0>
				<cfset decryptedPassword = encryptDecryptPassword(password=qUserSecurityInfo.password,direction="decrypt")>
			</cfif>
			<cfset ArrayAppend(arrSecurityPass,decryptedPassword)>           
		</cfloop>              
		<cfset temp = QueryAddColumn(qGetAllUsers,"password","varchar",arrSecurityPass)>

		<!--- Translate all of the users into an array to return to Flex--->
		<cfif qGetAllUsers.recordCount>
			<cfset userArray = arrayfromquery(qGetAllUsers) />
		</cfif>
		
		<cfreturn userArray>
	</cffunction>
	

	<cffunction name="getAllDepartments" access="remote" returntype="query" output="true">
		<cfargument name="includeInactive" type="string" required="false" default="false">
		
		<cfquery name="qGetAllDepartments" datasource="#REQUEST.securityDSN#">
			SELECT d.*
			FROM Departments d
			<cfif ARGUMENTS.includeInactive eq "false">
				WHERE isactive is null or (isactive <> 'n' and isactive <> '0')	
			</cfif>
			ORDER BY d.departmentName
		</cfquery>
		
		<cfreturn qGetAllDepartments>
	</cffunction>
    

	<cffunction name="getDirectoryRoles" access="remote" returntype="query" output="true">
		
		<cfquery name="qGetDirectoryRoles" datasource="#REQUEST.securityDSN#">
			SELECT roleID, roleName
			FROM DirectoryRoles
			ORDER BY roleName
		</cfquery>
		
		<cfreturn qGetDirectoryRoles>
	</cffunction>

	<cffunction name="getDirectoryInfoByUser" access="remote" returntype="query" output="true">
		<cfargument name="networkUserID" type="string" required="true">
		<cfargument name="includeInactive" type="string" required="false" default="false">
				
		<cfquery name="qGetDirectoryInfoByUser" datasource="#REQUEST.securityDSN#">
			SELECT ui.networkUserID, ui.tartanID, di.*
              FROM ((
                UserInfo ui
                    INNER JOIN DirectoryInfo di ON di.tartanID = ui.tartanID)
                )
             WHERE ui.networkUserID = '#ARGUMENTS.networkUserID#'
             <cfif ARGUMENTS.includeInactive eq "false">  
			   AND ui.isActive = 'y'
               AND di.isActive = 'y'
			 </cfif>
		</cfquery>
		
		<cfreturn qGetDirectoryInfoByUser>
	</cffunction>

	<cffunction name="getDepartmentByUser" access="remote" returntype="query" output="true">
		<cfargument name="networkUserID" type="string" required="true">
		
		<cfquery name="qGetDepartmentsByUser" datasource="#REQUEST.securityDSN#">
			SELECT ui.networkUserID, ui.tartanID, di.deptID, d.departmentID, d.departmentName
              FROM (((
                UserInfo ui
                    INNER JOIN DirectoryInfo di ON di.tartanID = ui.tartanID)
                    INNER JOIN Departments d ON di.deptID = departmentID)
                )
             WHERE ui.networkUserID = '#ARGUMENTS.networkUserID#'
               AND ui.isActive = 'y'
               AND di.isActive = 'y'
               AND d.isActive = 'y'
		</cfquery>
		
		<cfreturn qGetDepartmentsByUser>
	</cffunction>
	
	<cffunction name="getUserDetails" access="remote" returntype="struct" output="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="dsn" type="string" required="false" default="scm">
		<cfset var security = structnew() />
		
		<cfquery name="qGetUser" datasource="#REQUEST.securityDSN#">
			select networkUserID, fullName, tartanID, email
			from UserInfo
			where networkUserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
		</cfquery>
		
		<cfif qGetUser.recordcount IS 1>
			<cfset security.user = trim(qGetUser.networkUserID) />
			<cfset security.tartanID = numberformat(right(qGetUser.tartanID,7), 0000000) />
			<cfset security.fname = trim(listlast(qGetUser.fullName, ',')) />
			<cfset security.lname = trim(listfirst(qGetUser.fullName, ',')) />
			<cfset security.pass = hash(trim(qGetUser.networkUserID) & dateFormat(now(),"yyyymmdd") & "#REQUEST.securityPassHash#") />	
			<cfset security.email = trim(qGetUser.email) />
			<cfset security._client = structnew() />

				<cfset newclient = structnew() />
				<cfset newclient.appname = arguments.dsn />
				<cfset newclient.roles = structnew() />
				<cfset newclient.roles.current = structnew() />
				<cfset newclient.roles.current.role = '' />
				<cfset newclient.roles.current._access = arraynew(1) />
				<cfset newclient.roles._available = arraynew(1) />
					<cfset test = getUserRole(security.tartanID, newclient.appname) />
					<cfloop from="1" to="#arraylen(test)#" step="1" index="i">
						<cfset newavailable = structnew() />
						<cfset newavailable.role = test[i].rolename />
						<cfset newavailable.roleid = test[i].roleid />
						<cfset newavailable._access = getAccessTypes(security.tartanID, newclient.appname, newavailable.role) />
						<cfset temp = arrayappend(newclient.roles._available, newavailable) />
					</cfloop>

			<cfset security._client = newclient />

		<cfelse>
			<cfset security.error = "Unknown Login" />
			<cfset security.detail = "Please contact your system administrator to resolve this issue." />
			<cfreturn security />
			<!--- throw into error object - contact web team
				<cflocation url="#arguments.failureURL#?msg=4" addtoken="no"> --->
		</cfif>
		
		<cfreturn security>
	</cffunction>
	
	
	<cffunction name="getAllRolesByUser" access="remote" returntype="array" output="true">
		<cfargument name="tartanid" type="numeric" required="true">
		<cfargument name="dsn" type="string" required="false" default="scm">
		<cfset var roleArray = arraynew(1) />
		
		<cfquery name="qGetAllRolesByUser" datasource="#REQUEST.securityDSN#">
			select rt.roleID, rt.RoleName
			from RoleTypes rt
				inner join RoleControl rc on rt.roleID = rc.roleID
			where rc.tartanID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.tartanid#">
			 and rt.applicationID = (select atp.applicationID
					from ApplicationTypes atp
					where atp.applicationName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.dsn#">)
			order by rt.RoleName
		</cfquery>
		
		<cfscript>
			oldRArray = arrayfromquery(qGetAllRolesByUser);
			for (i=1; i lt arraylen(oldRArray); i=i+1) {
				oldRItem = oldRArray[i];
				newRItem = structNew();
				newRItem.role = oldRItem.RoleName;
				newRItem.roleID = oldRItem.RoleID;
				newRItem._access = arraynew(1);
				//newRItem._access = getAllAccessTypesByRoleByUser(tartanid=arguments.tartanid, roleid=oldRItem.roleID);
				
				arrayappend(roleArray,newRItem);
			}
		</cfscript>
		<!--- 
		<cfif qGetAllRolesByUser.recordCount>
			<cfset roleArray = arrayfromquery(qGetAllRolesByUser) />
		</cfif> --->
		
		<cfreturn roleArray>
	</cffunction>
	
	
	<cffunction name="getAllAccessTypesByRoleByUser" access="remote" returntype="array" output="true">
		<cfargument name="tartanid" type="numeric" required="true">
		<cfargument name="roleid" type="numeric" required="true">
		<cfargument name="dsn" type="string" required="false" default="scm">
		<cfset var atArray = arraynew(1) />
		
		<cfquery name="qGetAllAccessTypesByRoleByUser" datasource="#REQUEST.securityDSN#">
			select ats.accessTypeID, ats.accessType
			from AccessTypes ats
				inner join AccessControl ac on ats.accessTypeID = ac.accessTypeID
			where ac.tartanID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.tartanid#">
			 and ats.applicationID = (select atp.applicationID
					from ApplicationTypes atp
					where atp.applicationName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.dsn#">)
			order by ats.accessType
		</cfquery>
		
		<cfif qGetAllAccessTypesByRoleByUser.recordCount>
			<cfset atArray = arrayfromquery(qGetAllAccessTypesByRoleByUser) />
		</cfif>
		
		<cfreturn atArray>
	</cffunction>


	<cffunction name="addUser" access="remote" returntype="boolean" output="true">
		<cfargument name="applicationID" type="numeric" required="true">
		<cfargument name="tartanID" type="numeric" required="true">
		<cfargument name="isActive" type="boolean" required="true">
		<cfset var success = true />
		
		<cfquery name="qAddUser" datasource="#REQUEST.securityDSN#">
			insert into ApplicationControl (applicationID, tartanID, isActive)
				values (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.applicationID#">
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">
						,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isActive#">)
		</cfquery>
		
		<cfreturn success>
	</cffunction>
	
	
	<cffunction name="deleteUser" access="remote" returntype="boolean" output="true">
		<cfargument name="applicationID" type="numeric" required="true">
		<cfargument name="tartanID" type="numeric" required="true">
		<cfset var success = true />
		
		<cfquery name="qDeleteUser" datasource="#REQUEST.securityDSN#">
			delete from ApplicationControl
			where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.applicationID#">
				and tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">
		</cfquery>
		
		<cfquery name="qDeleteRoles" datasource="#REQUEST.securityDSN#">
			delete from RoleControl
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
				and roleid in (select r.roleID
						from roletypes r
						where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.applicationID#">)
		</cfquery>
		
		<cfquery name="qDeleteAccessTypes" datasource="#REQUEST.securityDSN#">
			delete from AccessControl
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
				and roleid in (select r.roleID
						from roletypes r
						where applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.applicationID#">)
		</cfquery>
		
		<cfreturn success>
	</cffunction>
	
	
	<cffunction name="addRole" access="remote" returntype="string" output="true">
		<cfargument name="roleID" type="numeric" required="true">
		<cfargument name="tartanID" type="numeric" required="true">
		
		<cfquery name="qAddRole" datasource="#REQUEST.securityDSN#">
			insert into RoleControl (roleID, tartanID)
				values (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">)
		</cfquery>
		
		<cfreturn arguments.tartanID>
	</cffunction>
	
	
	<cffunction name="deleteRole" access="remote" returntype="boolean" output="true">
		<cfargument name="roleID" type="numeric" required="true">
		<cfargument name="tartanID" type="numeric" required="true">
		<cfset var success = true />
		
		<cfquery name="qDeleteRoles" datasource="#REQUEST.securityDSN#">
			delete from RoleControl
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
				and roleid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
		</cfquery>
		
		<cfquery name="qDeleteAccessTypes" datasource="#REQUEST.securityDSN#">
			delete from AccessControl
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
				and roleid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
		</cfquery>
		
		<cfreturn success>
	</cffunction>
	
	
	<cffunction name="setAllAccessTypes" access="remote" returntype="boolean" output="true">
		<cfargument name="access" type="array" required="true">
		<cfargument name="roleID" type="numeric" required="true">
		<cfargument name="tartanID" type="numeric" required="true">
		<cfset var success = true />
		
		<cfquery name="qDeleteAccessTypes" datasource="#REQUEST.securityDSN#">
			delete from AccessControl
			where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
				and roleid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
		</cfquery>
		
		<cfloop from="1" to="#arraylen(arguments.access)#" step="1" index="i">
			<cfset j = arguments.access[i] />
			<cfquery name="qAddAccessTypes" datasource="#REQUEST.securityDSN#">
				insert into AccessControl (accessTypeID, tartanID, roleID)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#j.accessTypeID#">
							, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
							, <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">)
			</cfquery>
		</cfloop>
		
		<cfreturn success>
	</cffunction>



	<!--- SECURITY DIRECTORY METHODS --->

	<cffunction name="saveSecurityUser" access="remote" returntype="Struct" output="true">
		<cfargument name="securityUser" type="any" required="true">

		<cfset var result = StructNew() />
		<cfset result.success = true>
		<cfset result.errorMessage = "">
		
		<cfscript>
			// determines if the object already exists by UUID
			qrySQL = "";
		</cfscript>
		
		<cfset securityUser = arguments.securityUser>
		<cfset tartanID = trim(securityUser.getTartanID())>
		<cfif len(tartanID)>
		
			<cfquery name="qrySQL" datasource="#REQUEST.securityDSN#">
				SELECT *
				FROM UserInfo
				WHERE tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#tartanID#">
			</cfquery>

			<cfscript>
				// if the record does not exist create it
				// if it exists then update it
				if(qrySQL.recordcount EQ 0)
				{
					result = CreateSecurityUser(securityUser);
				}
				else{
					result = UpdateSecurityUser(securityUser);
				}
			</cfscript>

		<cfelse>
			<!--- Tartan ID Required --->
			<cfset result.success = false>
			<cfset result.errorMessage = "Tartan ID is required. Please see your system administrator for additional assistance.">
		</cfif>
		
		<cfreturn result>
	</cffunction>
	

<!--- ******************************** --->	
<!--- function: getLDAPUser            --->
<!---                                  --->	
<!--- requires: username    	       --->
<!---                                  --->	
<!--- returns: struct of security      --->
<!---- data props if username          --->
<!---    exists in LDAP                --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="getLDAPUser" access="remote" hint="Returns a user's data from LDAP by username" returntype="struct" output="false">
		<cfargument name="networkUserID" required="true" type="string" hint="Network Username required"><br>

		<cfset var security = structnew() />
		<cfset var result = structnew()>
		<cfset result.success = true>
		<cfset result.errorMessage = "">

		<cfif len(ldapserver)>
		
			<cftry>
				<!--- query user --->
				<cfloop index="curSubTreeFinal" list="#LSubTrees#" delimiters=";">
					<cfldap action = "query"
								server="#ldapserver#"
								port="#ldapport#"
								name="qGetUser"
								start="#curSubTreeFinal#"
								scope="subtree"
								attributes="*"
								username="#ldapuser#"
								password="#ldappass#"
								timeout="300"
								filter="(sAMAccountName=#arguments.networkUserID#)">
					<cfif qGetUser.RecordCount>				
						<!--- break out of the loop, we have what we need --->
						<cfbreak>
					</cfif>
				</cfloop>
	
				<cfset xmlDoc = REQUEST.activeDirectoryUserMapXMLDoc>
				<cfset arrUserFieldMappings = xmlDoc.ActiveDirectoryUserMap.UserFields.XmlChildren>			
	
				<cfif qGetUser.RecordCount>
					<!--- Set Security User Props --->
					<cfset security.networkUserID = trim(arguments.networkUserID) />
					<!---
					<cfset security.tartanID = numberformat(right(qGetUser.employeeID,7), 0000000) />
					<cfset security.fname = trim(listlast(qGetUser.displayName, ',')) />
					<cfset security.lname = trim(listfirst(qGetUser.displayName, ',')) />
					<cfset security.email = trim(qGetUser.email) />	
					--->			
					<cfloop query="qGetUser">
						<cfloop from="1" to="#ArrayLen(arrUserFieldMappings)#" index="idx">
							<cfscript>
								// In qGetUser there are two fields (name, value). Name holds the fieldName
								// of the record in the Active Directory and value holds the value for that
								// field.  These fields are mapped in a config xml file (ActiveDirectoryUserMap.xml)
								// that can be set to map specific fields in the Active Directory to the
								// properties available in the SecurityUserVO.as class in Flex.
								securityFieldName = arrUserFieldMappings[idx].xmlName;
								activeDirectoryFieldName = arrUserFieldMappings[idx].xmlText;
								if (securityFieldName neq "" AND activeDirectoryFieldName neq "")
								{
									if (activeDirectoryFieldName eq qGetUser.name)
									{
										if (securityFieldName eq "tartanID")
										{
											// format the emplyeeID as a set number of digits (ie. 7 for Tartan ID)
											numDigits = arrUserFieldMappings[idx].xmlAttributes.numDigits;
											security[UCase(securityFieldName)] = numberformat(right(qGetUser.value,numDigits), 0000000);
										}else{
											security[UCase(securityFieldName)] = trim(qGetUser.value);
										}
									}
								}
							</cfscript>
						</cfloop>
					
					</cfloop>
					<!--- return the SecurityUser --->
					<cfset result.security = security>		
				<cfelse>
					<cfset result.success = false>
					<cfset result.errorMessage = "Unable to locate user in Directory.  Please try another username or see your system administrator for assistance.">
				</cfif>
				
				<cfcatch type="any">
					<cfset result.success = false>
					<cfset result.errorMessage = "There was an error retrieving user information. Please see your system administrator for assistance.">				
				</cfcatch>
			</cftry>
		
		<cfelse>
		
			<!--- No Server Defined --->
			<cfset result.success = false>
			<cfset result.errorMessage = "There is no server defined for this connection. Please configure a server for the connection or see your system administrator for assistance.">
		
		</cfif>
		
		<cfreturn result>
	</cffunction>


	<cffunction name="createSecurityUser" access="remote" returntype="Struct" output="true">
		<cfargument name="securityUser" type="any" required="true">
	
		<cfset var i=1>
		<cfset var result = StructNew() />
		<cfset result.success = true>
		<cfset result.errorMessage = "">
		

		<cftry>

			<cfquery name="qTestDuplicateTartanID" datasource="#REQUEST.securityDSN#">
				SELECT tartanID
				FROM UserInfo
				WHERE tartanID = #arguments.securityUser.getTartanID()#
			</cfquery>			

			<cfif qTestDuplicateTartanID.RecordCount eq 0>

				<cfquery name="qAddSecurityUser" datasource="#REQUEST.securityDSN#">
					insert into UserInfo (tartanID, networkUserID, ssn, fullName, biographyInfo, personalLink, personalImage, isActive, personalImageAltText, personalImageView, objectID, defaultUrl, credentials, useEktron, isAdmin, email, lastModified, isOverride)
					values (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securityUser.getTartanID()#" null="#checkNull('numeric',arguments.securityUser.getTartanID())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getNetworkUserID()#" null="#checkNull('string',arguments.securityUser.getNetworkUserID())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getSSN()#" null="#checkNull('string',arguments.securityUser.getSSN())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getFullName()#" null="#checkNull('string',arguments.securityUser.getFullName())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getBiographyInfo()#" null="#checkNull('string',arguments.securityUser.getBiographyInfo())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalLink()#" null="#checkNull('string',arguments.securityUser.getPersonalLink())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalImage()#" null="#checkNull('string',arguments.securityUser.getPersonalImage())#">
							,<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.securityUser.getIsActive()#" null="#checkNull('string',arguments.securityUser.getIsActive())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalImageAltText()#" null="#checkNull('string',arguments.securityUser.getPersonalImageAltText())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalImageView()#" null="#checkNull('string',arguments.securityUser.getPersonalImageView())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getObjectID()#" null="#checkNull('string',arguments.securityUser.getObjectID())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getDefaultUrl()#" null="#checkNull('string',arguments.securityUser.getDefaultUrl())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getCredentials()#" null="#checkNull('string',arguments.securityUser.getCredentials())#">
							,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.securityUser.getUseEktron()#" null="#checkNull('boolean',arguments.securityUser.getUseEktron())#">
							,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.securityUser.getIsAdmin()#" null="#checkNull('boolean',arguments.securityUser.getIsAdmin())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getEmail()#" null="#checkNull('string',arguments.securityUser.getEmail)#">
							,null <!--- <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.securityUser.getLastModified()#" null="#checkNull('string',arguments.securityUser.getLastModified())#"> --->
							,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.securityUser.getIsOverride()#" null="#checkNull('boolean',arguments.securityUser.getIsOverride())#">
							)
				</cfquery>
				
				<!--- Insert User Security record --->				
				<cfquery name="qAddUserSecurityInfo" datasource="#REQUEST.securityDSN#">
					INSERT INTO UserSecurityInfo (tartanID, networkUserID, password)
					VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securityUser.getTartanID()#" null="#checkNull('numeric',arguments.securityUser.getTartanID())#">
						   ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getNetworkUserID()#" null="#checkNull('string',arguments.securityUser.getNetworkUserID())#">
						   ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#encryptDecryptPassword(password=arguments.securityUser.getPassword(),direction='encrypt')#" null="#checkNull('string',arguments.securityUser.getPassword())#">
						   )
				</cfquery>

			<cfelse>
			
				<!--- Fail for duplicate tartanID --->
				<cfset result.success = false>
				<cfset result.errorMessage = "The Employee ID #arguments.securityUser.getTartanID()# already exists. Please provide a unique Employee ID.">

			</cfif>

			<cfcatch type="any">
				<cfset result.success = false>
				<cfset result.errorMessage = "There was an error saving the User. Please see your system administrator for additional assistance.">
			</cfcatch>
		</cftry>

		
	
		<cfif result.success eq true>
			
			<cfscript>
				colDirectoryInfo = arguments.securityUser.getColDirectoryInfo();
				tartanID = arguments.securityUser.getTartanID();
				deleteDirectoryInfo(tartanID);
				// loop over the objects and save them 
				for (i=1; i lte ArrayLen(colDirectoryInfo); i=i+1)
				{
					if (result.success eq true)
					{
						// save each object
						directoryInfo = colDirectoryInfo[i];
						directoryInfo.setTartanID(tartanID);
						result.success = saveDirectoryInfo(directoryInfo);
					}else{
						break;
					}
				}			
			</cfscript>
				
			<cfif result.success eq false>
				<cfset result.errorMessage = "There was an error saving Directory Info for this user. Please see your system administrator for additional assistance.">
			</cfif>
				
		</cfif>

		
		<cfreturn result>
	</cffunction>


	<cffunction name="updateSecurityUser" access="remote" returntype="Struct" output="true">
		<cfargument name="securityUser" type="any" required="true">
		
		<cfset var i=1>
		<cfset var result = StructNew() />
		<cfset result.success = true>
		<cfset result.errorMessage = "">
				
		<cftry>
			<cfquery name="qUpdateSecurityUser" datasource="#REQUEST.securityDSN#">
				update UserInfo 
				set networkUserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getNetworkUserID()#" null="#checkNull('string',arguments.securityUser.getNetworkUserID())#">
					,ssn = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getSSN()#" null="#checkNull('string',arguments.securityUser.getSSN())#">
					,fullName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getFullName()#" null="#checkNull('string',arguments.securityUser.getFullName())#">
					,biographyInfo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getBiographyInfo()#" null="#checkNull('string',arguments.securityUser.getBiographyInfo())#">
					,personalLink = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalLink()#" null="#checkNull('string',arguments.securityUser.getPersonalLink())#">
					,personalImage = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalImage()#" null="#checkNull('string',arguments.securityUser.getPersonalImage())#">
					,isActive = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.securityUser.getIsActive()#" null="#checkNull('string',arguments.securityUser.getIsActive())#">
					,personalImageAltText = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalImageAltText()#" null="#checkNull('string',arguments.securityUser.getPersonalImageAltText())#">
					,personalImageView = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getPersonalImageView()#" null="#checkNull('string',arguments.securityUser.getPersonalImageView())#">
					,objectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getObjectID()#" null="#checkNull('string',arguments.securityUser.getObjectID())#">
					,defaultUrl = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getDefaultUrl()#" null="#checkNull('string',arguments.securityUser.getDefaultUrl())#">
					,credentials = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getCredentials()#" null="#checkNull('string',arguments.securityUser.getCredentials())#">
					,useEktron = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.securityUser.getUseEktron()#" null="#checkNull('boolean',arguments.securityUser.getUseEktron())#">
					,isAdmin = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.securityUser.getIsAdmin()#" null="#checkNull('boolean',arguments.securityUser.getIsAdmin())#">
					,email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getEmail()#" null="#checkNull('string',arguments.securityUser.getEmail)#">
					,lastModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.securityUser.getLastModified()#" null="#checkNull('string',arguments.securityUser.getLastModified())#">
					,isOverride = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.securityUser.getIsOverride()#" null="#checkNull('boolean',arguments.securityUser.getIsOverride())#">				
				where tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securityUser.getTartanID()#">
			</cfquery>
			
			<!--- Update security info for this user --->
			<cfquery name="qUpdateUserSecurityInfo" datasource="#REQUEST.securityDSN#">
				UPDATE UserSecurityInfo
				SET networkUserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securityUser.getNetworkUserID()#" null="#checkNull('string',arguments.securityUser.getNetworkUserID())#">
					,password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#encryptDecryptPassword(password=arguments.securityUser.getPassword(),direction='encrypt')#" null="#checkNull('string',arguments.securityUser.getPassword())#">
				WHERE tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securityUser.getTartanID()#">
			</cfquery>			
			
			<cfcatch type="any">
				<cfset result.success = false>
				<cfset result.errorMessage = "There was an error saving the User. Please see your system administrator for additional assistance.">
			</cfcatch>
		</cftry>

		<cfif result.success eq true>
		
			<cfscript>
				colDirectoryInfo = arguments.securityUser.getColDirectoryInfo();
				tartanID = arguments.securityUser.getTartanID();
				// delete existing Directory Info before saving the new results
				deleteDirectoryInfo(tartanID);
				// loop over the objects and save them 
				for (i=1; i lte ArrayLen(colDirectoryInfo); i=i+1)
				{
					if (result.success eq true)
					{
						// save each object
						directoryInfo = colDirectoryInfo[i];
						directoryInfo.setTartanID(tartanID);
						result.success = saveDirectoryInfo(directoryInfo);
					}else{
						break;
					}
				}				
			</cfscript>
		
			<cfif result.success eq false>
				<cfset result.errorMessage = "There was an error saving Directory Info for this user. Please see your system administrator for additional assistance.">
			</cfif>			
		
		</cfif>
		
		<cfreturn result>
	</cffunction>

	
	<cffunction name="deleteSecurityUser" access="remote" returntype="boolean" output="true">
		<cfargument name="tartanID" type="numeric" required="true">
		
		<cfset var success = true />
		
		<cftry>		
			<!--- DELETE APPLICATION CONTROL --->
			<cfquery name="qDeleteApplicationControl" datasource="#REQUEST.securityDSN#">
				delete from ApplicationControl
				where tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">
			</cfquery>
			
			<!--- DELETE ROLES --->
			<cfquery name="qDeleteRoles" datasource="#REQUEST.securityDSN#">
				delete from RoleControl
				where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
			</cfquery>
			
			<!--- DELETE ACCESS TYPES --->
			<cfquery name="qDeleteAccessTypes" datasource="#REQUEST.securityDSN#">
				delete from AccessControl
				where tartanid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanid#">
			</cfquery>
			
			<!--- DELETE DIRECTORY INFO --->
			<cfquery name="qDeleteDirectoryInfo" datasource="#REQUEST.securityDSN#">
				delete from DirectoryInfo
				where tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">
			</cfquery>	

			<!--- DELETE USER SECURITY INFO --->
			<cfquery name="qDeleteUserSecurityInfo" datasource="#REQUEST.securityDSN#">
				delete from UserSecurityInfo
				where tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">
			</cfquery>			

			<!--- DELETE USER INFO --->
			<cfquery name="qDeleteUserInfo" datasource="#REQUEST.securityDSN#">
				delete from UserInfo
				where tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tartanID#">
			</cfquery>	
		
			<cfcatch type="any">
				<cfset success = false>
			</cfcatch>
		</cftry>
		
		<cfreturn success>
	</cffunction>


	<cffunction name="saveDirectoryInfo" access="remote" returntype="boolean" output="true">
		<cfargument name="directoryInfo" type="any" required="true">

		<cfset var success = true />
		<cfscript>
			// determines if the object already exists by UUID
			qrySQL = "";
		</cfscript>
		
		<cfset directoryInfo = arguments.directoryInfo>
		<cfset directoryID = directoryInfo.getDirectoryID()>
		<cfif len(directoryID)>
		
			<cfquery name="qrySQL" datasource="#REQUEST.securityDSN#">
				SELECT *
				FROM DirectoryInfo
				WHERE directoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#directoryID#">
			</cfquery>
		
			<cfscript>
				// if the record does not exist create it
				// if it exists then update it
				if(qrySQL.recordcount EQ 0)
				{
					success = CreateDirectoryInfo(directoryInfo);		
				}
				else{
					success = UpdateDirectoryInfo(directoryInfo);
				}
			</cfscript>
		
		<cfelse>
			<!--- Directory ID Required --->
			<cfset success = false>
		</cfif>
		
		<cfreturn success>
	</cffunction>


	<cffunction name="createDirectoryInfo" access="remote" returntype="boolean" output="true">
		<cfargument name="directoryInfo" type="any" required="true">
		
		<cfset var success = true />
		
		<!---
		<cftry>
		--->
			<cfquery name="getMaxDirectoryID" datasource="#REQUEST.securityDSN#">
				SELECT MAX (directoryID) + 1 AS MaxDirectoryID
				FROM DirectoryInfo
			</cfquery>

			<cfif len(getMaxDirectoryID.MaxDirectoryID)>
				<cfset directoryID = getMaxDirectoryID.MaxDirectoryID>
			<cfelse>
				<cfset directoryID = 1>
			</cfif>			

			<cfquery name="getMaxOrderID" datasource="#REQUEST.securityDSN#">
				SELECT MAX (orderID) + 1 AS MaxOrderID
				FROM DirectoryInfo
				WHERE tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getTartanID()#">
			</cfquery>

			<cfif len(getMaxOrderID.MaxOrderID)>
				<cfset orderID = getMaxOrderID.MaxOrderID>
			<cfelse>
				<cfset orderID = 1>
			</cfif>

			<cfquery name="qAddDirectoryInfo" datasource="#REQUEST.securityDSN#">
				insert into DirectoryInfo (directoryID, tartanID, deptID, divID, orderID, location, title, supervisorUserID, employmentStatus, directoryRole, actualPhone, displayPhone, internalPhone, externalPhone, acdPhone, isActive, isDepartmentHead, contactHours, contactFax)
				values (#directoryID# <!--- <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDirectoryID()#" null="#checkNull('numeric',arguments.directoryInfo.getDirectoryID())#"> --->
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getTartanID()#" null="#checkNull('numeric',arguments.directoryInfo.getTartanID())#">
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDeptID()#" null="#checkNull('numeric',arguments.directoryInfo.getDeptID())#">
						,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDivID()#" null="#checkNull('numeric',arguments.directoryInfo.getDivID())#">
						,#orderID# <!--- <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getOrderID()#" null="#checkNull('numeric',arguments.directoryInfo.getOrderID())#"> --->
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getLocation()#" null="#checkNull('string',arguments.directoryInfo.getLocation())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getTitle()#" null="#checkNull('string',arguments.directoryInfo.getTitle())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getSupervisorUserID()#" null="#checkNull('string',arguments.directoryInfo.getSupervisorUserID())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getEmploymentStatus()#" null="#checkNull('string',arguments.directoryInfo.getEmploymentStatus())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getDirectoryRole()#" null="#checkNull('string',arguments.directoryInfo.getDirectoryRole())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getActualPhone()#" null="#checkNull('string',arguments.directoryInfo.getActualPhone())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getDisplayPhone()#" null="#checkNull('string',arguments.directoryInfo.getDisplayPhone())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getInternalPhone()#" null="#checkNull('string',arguments.directoryInfo.getInternalPhone())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getExternalPhone()#" null="#checkNull('string',arguments.directoryInfo.getExternalPhone())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getAcdPhone()#" null="#checkNull('string',arguments.directoryInfo.getAcdPhone())#">
						,<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.directoryInfo.getIsActive()#" null="#checkNull('string',arguments.directoryInfo.getIsActive())#">
						,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.directoryInfo.getIsDepartmentHead()#" null="#checkNull('string',arguments.directoryInfo.getIsDepartmentHead())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getContactHours()#" null="#checkNull('string',arguments.directoryInfo.getContactHours())#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getContactFax()#" null="#checkNull('string',arguments.directoryInfo.getContactFax())#">
						)
			</cfquery>
		<!---	
			<cfcatch type="any">
				<cfset success = false>
			</cfcatch>
		</cftry>
		--->
		
		<cfreturn success>
	</cffunction>


	<cffunction name="updateDirectoryInfo" access="remote" returntype="boolean" output="true">
		<cfargument name="directoryInfo" type="any" required="true">
		
		<cfset var success = true />
		
		<!---
		<cftry>
		--->
			<cfquery name="qUpdateDirectoryInfo" datasource="#REQUEST.securityDSN#">
				update DirectoryInfo 
				set directoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDirectoryID()#" null="#checkNull('numeric',arguments.directoryInfo.getDirectoryID())#">
					,tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getTartanID()#" null="#checkNull('numeric',arguments.directoryInfo.getTartanID())#">
					,deptID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDeptID()#" null="#checkNull('numeric',arguments.directoryInfo.getDeptID())#">
					,divID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDivID()#" null="#checkNull('numeric',arguments.directoryInfo.getDivID())#">
					,orderID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getOrderID()#" null="#checkNull('numeric',arguments.directoryInfo.getOrderID())#">
					,location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getLocation()#" null="#checkNull('string',arguments.directoryInfo.getLocation())#">
					,title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getTitle()#" null="#checkNull('string',arguments.directoryInfo.getTitle())#">
					,supervisorUserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getSupervisorUserID()#" null="#checkNull('string',arguments.directoryInfo.getSupervisorUserID())#">
					,employmentStatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getEmploymentStatus()#" null="#checkNull('string',arguments.directoryInfo.getEmploymentStatus())#">
					,directoryRole = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getDirectoryRole()#" null="#checkNull('string',arguments.directoryInfo.getDirectoryRole())#">
					,actualPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getActualPhone()#" null="#checkNull('string',arguments.directoryInfo.getActualPhone())#">
					,displayPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getDisplayPhone()#" null="#checkNull('string',arguments.directoryInfo.getDisplayPhone())#">
					,internalPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getInternalPhone()#" null="#checkNull('string',arguments.directoryInfo.getInternalPhone())#">
					,externalPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getExternalPhone()#" null="#checkNull('string',arguments.directoryInfo.getExternalPhone())#">
					,acdPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getAcdPhone()#" null="#checkNull('string',arguments.directoryInfo.getAcdPhone())#">
					,isActive = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.directoryInfo.getIsActive()#" null="#checkNull('string',arguments.directoryInfo.getIsActive())#">
					,isDepartmentHead = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.directoryInfo.getIsDepartmentHead()#" null="#checkNull('string',arguments.directoryInfo.getIsDepartmentHead())#">
					,contactHours = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getContactHours()#" null="#checkNull('string',arguments.directoryInfo.getContactHours())#">
					,contactFax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.directoryInfo.getContactFax()#" null="#checkNull('string',arguments.directoryInfo.getContactFax())#">
				where directoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getDirectoryID()#">
				  and tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.directoryInfo.getTartanID()#">
			</cfquery>
		<!---	
			<cfcatch type="any">
				<cfset success = false>
			</cfcatch>
		</cftry>
		--->
		<cfreturn success>
	</cffunction>


	<cffunction name="deleteDirectoryInfo" access="remote" returntype="boolean" output="true">
		<cfargument name="tartanID" type="any" required="true">

		<cfset var success = true />
		
		<cfset tartanID = arguments.tartanID>
		
		<cfif len(tartanID)>
		

			<cftry>

				<cfquery name="qDeleteDirectoryInfo" datasource="#REQUEST.securityDSN#">
					DELETE
					FROM DirectoryInfo
					WHERE tartanID = <cfqueryparam cfsqltype="cf_sql_integer" value="#tartanID#">
				</cfquery>

				<cfcatch type="any">
					<cfset success = false>
				</cfcatch>
			</cftry>
		
		<cfelse>
			
			<!--- TartanID Required --->
			<cfset success = false>
		
		</cfif>
			
		<cfreturn success>
	</cffunction>


	<cffunction name="saveDepartment" access="remote" returntype="struct" output="true">
		<cfargument name="department" type="any" required="true">

		<cfset var result = StructNew() />
		<cfset result.success = true>
		<cfset result.errorMessage = "">
		<cfscript>
			// determines if the object already exists by UUID
			qrySQL = "";
		</cfscript>
		
		<cfset department = arguments.department>
		<cfset departmentID = department.getDepartmentID()>
		<cfif len(departmentID)>
		
			<cfquery name="qrySQL" datasource="#REQUEST.securityDSN#">
				SELECT *
				FROM Departments
				WHERE departmentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#departmentID#">
			</cfquery>
		
			<cfscript>
				// if the record does not exist create it
				// if it exists then update it
				if(qrySQL.recordcount EQ 0)
				{
					result = CreateDepartment(department);
				}
				else{
					result = UpdateDepartment(department);
				}
			</cfscript>
		
		<cfelse>
			<!--- Department ID Required --->
			<cfset result.success = false>
			<cfset result.errorMessage = "Department ID is required. Please see your administrator for additional assistance.">
		</cfif>
	
		<cfreturn result>
	</cffunction>


	<cffunction name="createDepartment" access="remote" returntype="struct" output="true">
		<cfargument name="department" type="any" required="true">
		
		<cfset var result = StructNew() />
		<cfset result.success = true>
		<cfset result.errorMessage = "">
		
		<!---
		<cftry>
		--->

			<cfquery name="qTestDuplicateDepartment" datasource="#REQUEST.securityDSN#">
				SELECT departmentName
				FROM Departments
				WHERE departmentName = '#arguments.department.getDepartmentName()#'
			</cfquery>			

			<cfif qTestDuplicateDepartment.RecordCount gt 0>
			
				<!--- Fail for duplicate department --->
				<cfset result.success = false>
				<cfset result.errorMessage = "The department #arguments.department.getDepartmentName()# already exists. Please use a unique name.">
				
			<cfelse>
			
				<cfquery name="getMaxDepartmentID" datasource="#REQUEST.securityDSN#">
					SELECT MAX (departmentID) + 1 AS MaxDepartmentID
					FROM Departments
				</cfquery>
	
				<cfif len(getMaxDepartmentID.MaxDepartmentID)>
					<cfset departmentID = getMaxDepartmentID.MaxDepartmentID>
				<cfelse>
					<cfset departmentID = 1>
				</cfif>			
	
				<cfquery name="qAddDepartment" datasource="#REQUEST.securityDSN#">
					insert into Departments (departmentID, departmentName, parentID, departmentEmail, departmentPhone, departmentFax, departmentLocation, isActive, departmentAbbr, colleagueID)
					values (#departmentID# <!--- <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department.getDepartmentID()#" null="#checkNull('numeric',arguments.department.getDepartmentID())#"> --->
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentName()#" null="#checkNull('string',arguments.department.getDepartmentName())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getParentID()#" null="#checkNull('string',arguments.department.getParentID())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentEmail()#" null="#checkNull('string',arguments.department.getDepartmentEmail())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentPhone()#" null="#checkNull('string',arguments.department.getDepartmentPhone())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentFax()#" null="#checkNull('string',arguments.department.getDepartmentFax())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentLocation()#" null="#checkNull('string',arguments.department.getDepartmentLocation())#">
							,<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.department.getIsActive()#" null="#checkNull('string',arguments.department.getIsActive())#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentAbbr()#" null="#checkNull('string',arguments.department.getDepartmentAbbr())#">
							,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department.getColleagueID()#" null="#checkNull('numeric',arguments.department.getColleagueID())#">
							)
				</cfquery>			
				
			
			</cfif>

		<!---	
			<cfcatch type="any">
				<cfset result.success = false>
				<cfset result.errorMessage = "There was an error saving the department. Please see your system administration for additional assistance.">
			</cfcatch>
		</cftry>
		--->
		
		<cfreturn result>
	</cffunction>


	<cffunction name="updateDepartment" access="remote" returntype="Struct" output="true">
		<cfargument name="department" type="any" required="true">
		
		<cfset var result = StructNew() />
		<cfset result.success = true>
		<cfset result.errorMessage = "">
		
		<!---
		<cftry>
		--->
		
			<cfquery name="qUpdateDepartment" datasource="#REQUEST.securityDSN#">
				update Departments 
				set departmentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department.getDepartmentID()#" null="#checkNull('numeric',arguments.department.getDepartmentID())#">
					,departmentName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentName()#" null="#checkNull('string',arguments.department.getDepartmentName())#">
					,parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getParentID()#" null="#checkNull('string',arguments.department.getParentID())#">
					,departmentEmail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentEmail()#" null="#checkNull('string',arguments.department.getDepartmentEmail())#">
					,departmentPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentPhone()#" null="#checkNull('string',arguments.department.getDepartmentPhone())#">
					,departmentFax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentFax()#" null="#checkNull('string',arguments.department.getDepartmentFax())#">
					,departmentLocation = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentLocation()#" null="#checkNull('string',arguments.department.getDepartmentLocation())#">
					,isActive = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.department.getIsActive()#" null="#checkNull('string',arguments.department.getIsActive())#">
					,departmentAbbr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.department.getDepartmentAbbr()#" null="#checkNull('string',arguments.department.getDepartmentAbbr())#">
					,colleagueID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department.getColleagueID()#" null="#checkNull('numeric',arguments.department.getColleagueID())#">
				where departmentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.department.getDepartmentID()#">
			</cfquery>
		<!---	
			<cfcatch type="any">
				<cfset result.success = false>
				<cfset result.errorMessage = "There was an error saving the department. Please see your system administration for additional assistance.">
			</cfcatch>
		</cftry>
		--->
		
		<cfreturn result>
	</cffunction>

	<cffunction name="deleteDepartment" access="remote" returntype="boolean" output="true">
		<cfargument name="departmentID" type="any" required="true">

		<cfset var success = true />
		
		<cfset departmentID = arguments.departmentID>
		
		<cfif len(departmentID)>
		
			<cftry>

				<cfquery name="qDeleteDepartment" datasource="#REQUEST.securityDSN#">
					DELETE
					FROM Departments
					WHERE departmentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#departmentID#">
				</cfquery>

				<cfcatch type="any">
					<cfset success = false>
				</cfcatch>
			</cftry>
			
			<cfif success eq true>
				
				<cftry>
				
					<cfquery name="qDeleteDirectoryInfo" datasource="#REQUEST.securityDSN#">
						DELETE
						FROM DirectoryInfo
						WHERE deptID = <cfqueryparam cfsqltype="cf_sql_integer" value="#departmentID#">
					</cfquery>
					
					<cfcatch type="any">
						<cfset success = false>
					</cfcatch>
					
				</cftry>
				
			</cfif>
			
		<cfelse>
			
			<!--- Department ID Required --->
			<cfset success = false>
		
		</cfif>
			
		<cfreturn success>
	</cffunction>


	<cffunction name="checkNull" access="private" returntype="boolean" output="false">
		<cfargument name="datatype" type="string" required="yes">
		<cfargument name="fieldValue" type="any" required="yes">
		
		<cfscript>
			bUseNull = 0;
			
			switch(arguments.datatype){
				case "string":{
					if(len(arguments.fieldValue) EQ 0){
						bUseNull = 1;
					}
					break;
				}
				case "date":{
					if(not IsDate(arguments.fieldValue)){
						bUseNull = 1;
					}
					break;
				}
				case "boolean":{
					if(not IsBoolean(arguments.fieldValue)){
						bUseNull = 1;
					}
					break;
				}
				case "numeric":{
					if(not IsNumeric(arguments.fieldValue)){

						bUseNull = 1;
					}
					break;
				}
				default:{
					bUseNull = 0;
					break;
				}
			} //end switch			

			return bUseNull;
		</cfscript>
	</cffunction>
	
	
</cfcomponent>