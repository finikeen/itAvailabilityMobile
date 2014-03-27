<cfcomponent displayname="security"  hint="Common security logic for Web Systems Flex Applications.">

	<cfset variables.dao = APPLICATION.security.objectFactory.getObjectByName("config","dao","config")>
	<cfset variables.securityDSN = variables.dao.getSecurityDSN()>
	<!--- <cfset variables.cookieDomainName = variables.dao.getCookieDomainName()> --->
	<cfset variables.cookieDomainName = "">
	<cfset variables.securityPassHash = variables.dao.getSecurityPassHash()>
	<cfset variables.encryptKey = variables.dao.getEncryptKey()>
	<cfset variables.encryptSeed = variables.dao.getEncryptSeed()>
	<cfset variables.encryptAlgorithm = variables.dao.getEncryptAlgorithm()>
<!--- ******************************** --->	
<!--- init parameters                  --->
<!--- ******************************** --->	
	<cfparam name="ldapserver" type="string" default="#variables.dao.getLDAPServer()#" />
	<cfparam name="ldapport" type="numeric" default="389" />
	<cfparam name="ldapuser" type="string" default="#variables.dao.getLDAPUser()#" />
	<cfparam name="ldappass" type="string" default="#variables.dao.getLDAPPass()#" />
	<cfparam name="lSubtrees" default="#variables.dao.getLDAPSubTrees()#">
	
	

<!--- ******************************** --->	
<!--- function: checkCookies          --->
<!---                                  --->	
<!--- requires: 						           --->
<!---                                  --->	
<!--- does: checks for cookies and     --->
<!---   returns username or FALSE      --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="checkCookies" access="remote" hint="Checks for authentication cookies" returntype="string" output="false">
	
		<cfset cookies = "na" />
		
		<cfif isdefined("cookie.auth_user") and isdefined("cookie.auth_pass")>
			<cfset cookies = cookie.auth_user />
		</cfif>
		
		<cfreturn cookies />
	</cffunction>
	

<!--- ******************************** --->	
<!--- function: verifyLogin            --->
<!---                                  --->	
<!--- requires: username,password      --->
<!---                                  --->	
<!--- returns: structure of all apps,  --->
<!---    with roles and access types   --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="verifyLogin" access="remote" hint="Verifies a user's existence in LDAP" returntype="struct" output="false">
	
		<cfargument name="username" required="true" type="string" hint="Username required">
		<cfargument name="password" required="true" type="string" hint="Password required">
			
		<cfset security = structnew() />

		<cfif isdefined("arguments.username") and len(arguments.password)>
			
			<cfset curSubTreeFinal = "">
			<cfif len(ldapserver)>
				<!--- loop over subtrees until username is found --->
				<cfloop list="#lSubtrees#" index="curSubtree" delimiters=";">
					<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
									start="#curSubtree#" scope="subtree" attributes="dn"
									filter="(sAMAccountName=#arguments.username#)"
									username="#ldapuser#" password="#ldappass#"
									name="qUser">
					<cfif qUser.recordCount>
						<cfset curSubTreeFinal = curSubtree />
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- If the user was not found via LDAP, check the Security database --->
			<cfif curSubTreeFinal eq "">
				<cfset security = verifyUserSecurityInfo(username=arguments.username,
														 password=arguments.password,
														 verifyPassword=false)>
				<cfif len(security.error)>
					<cfreturn security>
				</cfif>
			</cfif>
			
			<cfif qUser.recordCount>
			
				<cftry>
					
					<cfif len(curSubTreeFinal)>
						<!--- verify password with username from above in ldap --->
						<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
										start="#curSubTreeFinal#" scope="subtree" attributes="*"
										filter="(sAMAccountName=#arguments.username#)"
										username="#qUser.dn#" password="#arguments.password#"
										name="qUser">
					<cfelse>
						
						<!--- If the user was not found via LDAP, check the Security database --->
						<cfif curSubTreeFinal eq "">
							<cfset security = verifyUserSecurityInfo(username=arguments.username,
																	 password=arguments.password,
																	 verifyPassword=true)>
							<cfif len(security.error)>
								<cfreturn security>
							</cfif>
						</cfif>	
					</cfif>

					<!--- and in security --->
					<cfquery name="qGetUser" datasource="#variables.securityDSN#">
						select networkUserID, fullName, tartanID, email
						from UserInfo
						where networkUserID = '#arguments.username#'
					</cfquery>
				<cfcatch type="any">
					<!--- throw into error object - bad password
					<cflocation url="#arguments.failureURL#?msg=1" addtoken="no"> --->
				</cfcatch>
				</cftry>
				
				<cfif qGetUser.recordcount IS 1>
			
					<!--- write "cookies" Flex --->
					<cfset security.user = trim(qGetUser.networkUserID) />
					<cfset security.tartanID = numberformat(right(qGetUser.tartanID,7), 0000000) />
					<cfset security.fname = trim(listlast(qGetUser.fullName, ',')) />
					<cfset security.lname = trim(listfirst(qGetUser.fullName, ',')) />
					<cfset security.pass = hash(trim(qGetUser.networkUserID) & dateFormat(now(),"yyyymmdd") & "#variables.securityPassHash#") />	
					<cfset security.email = trim(qGetUser.email) />
					
                    <!--- write "cookies" CF --->
					<!---
					<cfset request.auth_user = qGetUser.networkUserID>
					--->
					<cfset passhash = hash(qGetUser.networkUserID & dateFormat(now(),"yyyymmdd") & "#variables.securityPassHash#")>	
					<cfcookie name="auth_user" value="#Trim(qGetUser.networkUserID)#" expires="#DateFormat(DateAdd('d', 1, Now()), 'mm/dd/yy')#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_tartanID" value="#Right(qGetUser.tartanID,7)#" expires="#DateFormat(DateAdd('d', 1, Now()), 'mm/dd/yy')#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_fname" value="#Trim(ListLast(qGetUser.fullName, ','))#" expires="#DateFormat(DateAdd('d', 1, Now()), 'mm/dd/yy')#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_lname" value="#Trim(ListFirst(qGetUser.fullName, ','))#" expires="#DateFormat(DateAdd('d', 1, Now()), 'mm/dd/yy')#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_pass" value="#passhash#" expires="#DateFormat(DateAdd('d', 1, Now()), 'mm/dd/yy')#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_email" value="#Trim(qGetUser.email)#" expires="#DateFormat(DateAdd('d', 1, Now()), 'mm/dd/yy')#" domain="#variables.cookieDomainName#">

					<!--- create "client Flex --->
					<cfset security._client = arraynew(1) />
						
						<cfset qGetApps = getAllApps(security.tartanID) />
					
						<cfloop query="qGetApps">
							<cfset newclient = structnew() />
							<cfset newclient.appname = qGetApps.applicationName />
							<cfset newclient.roles = structnew() />
							<!--- create placeholder for current role/accesstype --->
							<cfset newclient.roles.current = structnew() />
							<cfset newclient.roles.current.role = '' />
							<cfset newclient.roles.current._access = arraynew(1) />
							<cfset newclient.roles._available = arraynew(1) />
							<!--- create array of all roles/accesstypes --->
								<cfset test = getUserRole(security.tartanID, newclient.appname) />
								<!--- add in logic for setting current role = single role
											add in logic for "guest" access for those w/ no assigned roles --->
								<cfloop from="1" to="#arraylen(test)#" step="1" index="i">
									<cfset newavailable = structnew() />
									<cfset newavailable.role = test[i].rolename />
									<cfset newavailable.roleid = test[i].roleid />
									<cfset newavailable._access = getAccessTypes(security.tartanID, newclient.appname, newavailable.role) />
									<cfset temp = arrayappend(newclient.roles._available, newavailable) />
								</cfloop>

							<cfset temp = arrayappend(security._client, newclient) />
						</cfloop>

						<!--- Write Client CF --->
                        <cfloop query="qGetApps">
                            <cfset tempDSN = qGetApps.applicationName>
                            
                            <cfquery name="qGetUsers" datasource="#variables.securityDSN#">
                                SELECT	R.roleName
                                FROM	UserInfo U
                                    INNER JOIN RoleControl UR ON U.tartanID = UR.tartanID
                                    INNER JOIN RoleTypes R ON UR.roleID = R.roleID
                                WHERE	U.networkUserID = '#qGetUser.networkUserID#'
                                    AND R.applicationID = (SELECT applicationID
                                        				   FROM ApplicationTypes
                                        				   WHERE applicationName = '#tempDSN#')
                            </cfquery>
                            <cfset "client.#tempDSN#" = ValueList(qGetUsers.RoleName)>		
                        </cfloop>
						
				<cfelse>
					<!--- throw into error object - contact web team
						<cflocation url="#arguments.failureURL#?msg=4" addtoken="no"> --->
				</cfif>
			

			<cfelse>
				<!--- throw into error object - bad username
					<cflocation url="#arguments.failureURL#?msg=1" addtoken="no"> --->
			</cfif>	
			
		<cfelse>
			<!--- throw into error object - no username/password (should never happen)
					<cflocation url="#arguments.failureURL#" addtoken="no"> --->
		</cfif>
	
		<cfreturn security/>
	</cffunction>

<!--- ******************************** --->	
<!--- function: verifyLoginDSN         --->
<!---                                  --->	
<!--- requires: username,password, dsn --->
<!---                                  --->	
<!--- returns: structure of all roles  --->
<!---    with access types for a given --->
<!---    application/dsn               --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="verifyLoginDSN" access="remote" hint="Verifies a user's existence in LDAP" returntype="struct" output="false">
	
		<cfargument name="username" required="true" type="string" hint="Username required">
		<cfargument name="password" required="true" type="string" hint="Password required">
		<cfargument name="dsn" required="true" type="string" hint="app name">
			
		<cfset security = structnew() />
		
		<cfif isdefined("arguments.username") and len(arguments.password)>
			
			<cfset curSubTreeFinal = "">
			<cfif len(ldapserver)>
				<cfloop list="#lSubtrees#" index="curSubtree" delimiters=";">
					<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
									start="#curSubtree#" scope="subtree" attributes="dn"
									filter="(sAMAccountName=#arguments.username#)"
									username="#ldapuser#" password="#ldappass#"
									name="qUser">
					<cfif qUser.recordCount>
						<cfset curSubTreeFinal = curSubtree />
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
			
			<!--- If the user was not found via LDAP, check the Security database --->
			<cfif curSubTreeFinal eq "">
				<cfset security = verifyUserSecurityInfo(username=arguments.username,
														 password=arguments.password,
														 verifyPassword=false)>
			
				<cfif len(security.error)>
					<cfreturn security>
				</cfif>
			</cfif>			
			
			<cfif qUser.recordCount>
			
				<cftry>
					
					<!--- If the user was found in Active Directory --->
					<!--- verify the password in Active Directory --->
					<cfif len(curSubTreeFinal)>
						<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
										start="#curSubTreeFinal#" scope="subtree" attributes="*"
										filter="(sAMAccountName=#arguments.username#)"
										username="#qUser.dn#" password="#arguments.password#"
										name="qUser">
					
					<cfelse>
						<!--- otherwise, test the password against the security database --->						
						<cfset security = verifyUserSecurityInfo(username=arguments.username,
																 password=arguments.password,
																 verifyPassword=true)>
					
						<cfif len(security.error)>
							<cfreturn security>
						</cfif>
					</cfif>
					
					<cfquery name="qGetUser" datasource="#variables.securityDSN#">
						select u.networkUserID, u.fullName, u.tartanID, u.email, d.deptid
						from UserInfo u
							inner join DirectoryInfo d on u.tartanID = d.tartanID
						where u.networkUserID = '#arguments.username#'
					</cfquery>
					
				<cfcatch type="any">
					<cfset security.error = "Bad Login" />
					<cfset security.detail = "Invalid password." />
					<cfreturn security />
					<!--- throw into error object - bad password
					<cflocation url="#arguments.failureURL#?msg=1" addtoken="no"> --->
				</cfcatch>
				</cftry>
				
				<cfif qGetUser.recordcount GTE 1>
					<!--- write "cookies" Flex --->
					<cfset security.user = trim(qGetUser.networkUserID) />
					<cfset security.tartanID = numberformat(right(qGetUser.tartanID,7), 0000000) />
					<cfset security.fname = trim(listlast(qGetUser.fullName, ',')) />
					<cfset security.lname = trim(listfirst(qGetUser.fullName, ',')) />
					<cfset security.pass = hash(trim(qGetUser.networkUserID) & dateFormat(now(),"yyyymmdd") & "#variables.securityPassHash#") />	
					<cfset security.email = trim(qGetUser.email) />
					<cfset security.deptId = trim(qGetUser.deptId) />
                    <cfset security.currentRole = '' />
					<cfset security.currentAccessTypes = arraynew(1) />
					
                    <!--- write "cookies" CF --->
					<!--- <cfset request.auth_user = qGetUser.networkUserID> --->
					<cfset passhash = hash(qGetUser.networkUserID & dateFormat(now(),"yyyymmdd") & "#variables.securityPassHash#")>	
					<cfcookie name="auth_user" value="#Trim(qGetUser.networkUserID)#" expires="never" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_tartanID" value="#Right(qGetUser.tartanID,7)#" expires="never" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_fname" value="#Trim(ListLast(qGetUser.fullName, ','))#" expires="never" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_lname" value="#Trim(ListFirst(qGetUser.fullName, ','))#" expires="never" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_pass" value="#passhash#" expires="never" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_email" value="#Trim(qGetUser.email)#" expires="never" domain="#variables.cookieDomainName#">
					
					<cfset security._client = structnew() />

					<cfset newclient = structnew() />
					<cfset newclient.appname = arguments.dsn />
					<cfset newclient.roles = structnew() />
					<cfset newclient.roles.current = structnew() />
					<cfset newclient.roles.current.role = '' />
					<cfset newclient.roles.current._access = arraynew(1) />
					<cfset newclient.roles._available = arraynew(1) />
					<cfset test = getUserRole(security.tartanID, newclient.appname) />
					<!--- write client for CF --->
					<cfif isarray(test) and arrayLen(test) gt 0>
						<cfset "client.#arguments.dsn#" = test[1].rolename>
                        <!--- write client for Flex --->
                        <cfloop from="1" to="#arraylen(test)#" step="1" index="i">
							<cfset newavailable = structnew() />
							<cfset newavailable.role = test[i].rolename />
							<cfset newavailable.roleid = test[i].roleid />
							<cfset newavailable.access = getAccessTypes(security.tartanID, newclient.appname, newavailable.role) />
							<cfset temp = arrayappend(newclient.roles._available, newavailable) />
						</cfloop>
					<cfelse>
						<cfset newavailable = structnew() />
						<cfset newavailable.role = 'Employee' />
						<cfset newavailable.roleid = 0 />
						<cfset newavailable._access = arraynew(1) />
						<cfset temp = arrayappend(newclient.roles._available, newavailable) />
                    </cfif>

					<cfset security._client = newclient />		
					<cfset security.availableRoles = newclient.roles._available />
				<cfelse>
					<cfset security.error = "Unknown Login" />
					<cfset security.detail = "Please contact webteam@sinclair.edu to resolve this issue." />
					<cfreturn security />
					<!--- throw into error object - contact web team
						<cflocation url="#arguments.failureURL#?msg=4" addtoken="no"> --->
				</cfif>
		
	
			<cfelse>
				<cfset security.error = "Bad Login" />
				<cfset security.detail = "Invalid username." />
				<cfreturn security />
				<!--- throw into error object - bad username
					<cflocation url="#arguments.failureURL#?msg=1" addtoken="no"> --->
			</cfif>	
			
		<cfelse>
			<cfset security.error = "Bad Login" />
			<cfset security.detail = "Invalid username and password." />
			<cfreturn security />
			<!--- throw into error object - no username/password (should never happen)
					<cflocation url="#arguments.failureURL#" addtoken="no"> --->
		</cfif>
		
		<cfreturn security/>
	</cffunction>


<!--- ******************************** --->	
<!--- function: verifyUserSecurityInfo --->
<!---                                  --->	
<!--- requires: username,password      --->
<!---                                  --->	
<!--- returns: true if user exists     --->
<!---          and details match       --->
<!--- ******************************** --->
	<cffunction name="verifyUserSecurityInfo" access="remote" hint="Verifies a user's security priviledges in Security database" returntype="struct" output="false">
		<cfargument name="username" required="yes" type="string" hint="Username required"> 
		<cfargument name="password" required="no" type="string" hint="User password">
		<cfargument name="verifyPassword" required="no" type="boolean" default="false" hint="determines if test should include password">
			
		<cfset security = structnew() />
		<cfset security.error = "">
		<cfset security.detail = "">
		
		<cfif arguments.verifyPassword eq true>
			
			<!--- Encrypt password to match it in the database --->
			<cfset encryptedPass = encryptDecryptPassword(password=arguments.password,direction="encrypt")>
			
			<cfquery name="qUser" datasource="#variables.securityDSN#">
				SELECT *
				FROM UserSecurityInfo
				WHERE networkUserID = '#arguments.username#'
				  AND password = '#encryptedPass#'
			</cfquery>					
			
			<cfif qUser.recordCount eq 0>
				<cfset security.error = "Bad Login" />
				<cfset security.detail = "Invalid password." />
			</cfif>
		<cfelse>
			<cfquery name="qUser" datasource="#variables.securityDSN#">
				SELECT *
				FROM UserSecurityInfo
				WHERE networkUserID = '#arguments.username#'
			</cfquery>					
			
			<cfif qUser.recordCount eq 0>
				<cfset security.error = "Bad Login" />
				<cfset security.detail = "Invalid username." />
			</cfif>			
		</cfif>	
		
		<cfreturn security/>
	</cffunction>


<!--- ************************************* --->	
<!--- function: encryptDecryptPassword      --->
<!---                                       --->	
<!--- requires: password                    --->
<!---           direction - Encrypt,Decrypt --->	
<!--- returns: result of encrypt, decrypt   --->
<!---          as a String                  --->
<!--- ************************************* --->
	<cffunction name="encryptDecryptPassword" access="remote" returntype="String" output="false">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="direction" type="string" required="no" default="encrypt">
		
		<cfset result = "">
		<cfif arguments.direction eq "encrypt">
			<cfif len(arguments.password)>
				<cfset encryptSeed = variables.encryptSeed & variables.encryptKey>
				<cfset encryptAlgorithm = variables.encryptAlgorithm>
				<cfset result = Encrypt(arguments.password, encryptSeed, encryptAlgorithm)>
			</cfif>
		<cfelse>
			<cfif len(arguments.password)>
				<cfset encryptSeed = variables.encryptSeed & variables.encryptKey>
				<cfset encryptAlgorithm = variables.encryptAlgorithm>
				<cfset result = Decrypt(arguments.password, encryptSeed, encryptAlgorithm)>
			</cfif>	
		</cfif>	
		
		<cfreturn result>
	</cffunction>


<!--- ******************************** --->	
<!--- function: verifyLoginCookies     --->
<!---                                  --->	
<!--- requires: username,dsn           --->
<!---                                  --->	
<!--- returns: structure of all roles  --->
<!---    with access types             --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="verifyLoginCookies" access="remote" hint="Verifies a user's existence in LDAP" returntype="struct" output="false">
	
		<cfargument name="username" required="yes" type="string" hint="Username required"> 
		<cfargument name="password" required="no" type="string" hint="not used - just a placeholder">
		<cfargument name="dsn" required="yes" type="string" hint="app name">
		
		<cfset security = structnew() />
		<cfquery name="qGetUser" datasource="#variables.securityDSN#">
			select deptid
			from DirectoryInfo
			where tartanID = #int(cookie.auth_tartanid)#
		</cfquery>
		<cfset security.user = trim(cookie.auth_user) />
		<cfset security.tartanID = int(cookie.auth_tartanid) />
		<cfset security.fname = trim(cookie.auth_fname) />
		<cfset security.lname = trim(cookie.auth_lname) />
		<cfset security.pass = trim(cookie.auth_pass) />	
		<cfset security.email = trim(cookie.auth_email) />
		<cfset security.deptId = trim(qGetUser.deptId) />
        <cfset security.currentRole = structnew() />
        <cfset security.currentRole = '' />
		<cfset security.currentAccessTypes = arraynew(1) />

			<cfset newclient = structnew() />
			<cfset newclient.appname = arguments.dsn />
			<cfset newclient.roles = structnew() />
			<cfset newclient.roles.current = structnew() />
			<cfset newclient.roles.current.role = '' />
			<cfset newclient.roles.current._access = arraynew(1) />
			<cfset newclient.roles._available = arraynew(1) />
				<cfset test = getUserRole(security.tartanID, newclient.appname) />
				<cfif isarray(test) and arraylen(test)>
					<cfloop from="1" to="#arraylen(test)#" step="1" index="i">
						<cfset newavailable = structnew() />
						<cfset newavailable.role = test[i].rolename />
						<cfset newavailable.roleid = test[i].roleid />
						<cfset newavailable._access = getAccessTypes(security.tartanID, newclient.appname, newavailable.role) />
						<cfset temp = arrayappend(newclient.roles._available, newavailable) />
					</cfloop>
				<cfelse>
					<cfset newavailable = structnew() />
					<cfset newavailable.role = 'Employee' />
					<cfset newavailable.roleid = 0 />
					<cfset newavailable._access = arraynew(1) />
					<cfset temp = arrayappend(newclient.roles._available, newavailable) />
				</cfif>

		<cfset security._client = newclient />
		<cfset security.availableRoles = newclient.roles._available />
		
		<cfreturn security/>
	</cffunction>


<!--- ******************************** --->	
<!--- function: doLogout               --->
<!---                                  --->	
<!--- requires:                        --->
<!---                                  --->	
<!--- returns: clears all access       --->
<!---   scopes for user security       --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="doLogout" access="remote" hint="remove all access scopes from the user" returntype="boolean" output="false">
		
		<cfloop index="thisVar" list="#GetClientVariablesList()#">
			<cfset DeleteClientVariable(thisVar)>
		</cfloop>
		<cfif IsDefined("COOKIE.auth_tartanID")>
			<cfquery name="qGetUserApps" datasource="#variables.securityDSN#">
				SELECT at.applicationName, at.applicationID
				FROM ApplicationTypes at INNER JOIN ApplicationControl ac
					ON at.applicationID = ac.applicationID
				WHERE ac.tartanID = #COOKIE.auth_tartanID#
			</cfquery>
			
			<cfloop query="qGetUserApps">
				<cfset tempApp = qGetUserApps.applicationName>
				<cfquery name="qGetSessionTypes" datasource="#variables.securityDSN#">
					SELECT 	at.AccessType
					FROM 	AccessTypes at
					WHERE at.applicationID = #qGetUserApps.applicationID#
				</cfquery>
				
				<cfloop query="qGetSessionTypes">
					<cfset curAccess = tempApp & "_" & qGetSessionTypes.AccessType>
					<cfset StructDelete(Session, curAccess)>
				</cfloop>
			</cfloop>
            <cfset StructDelete(Session, 'accessList')>
		</cfif>
		<cfcookie name="auth_user" value="" domain="#variables.cookieDomainName#" expires="now">
		<cfcookie name="auth_pass" value="" domain="#variables.cookieDomainName#" expires="now">
		<cfcookie name="auth_tartanID" value="" domain="#variables.cookieDomainName#" expires="now">
		<cfcookie name="auth_fname" value="" domain="#variables.cookieDomainName#" expires="now">
		<cfcookie name="auth_lname" value="" domain="#variables.cookieDomainName#" expires="now">
		<cfcookie name="auth_email" value="" domain="#variables.cookieDomainName#" expires="now">

		<cfset loggedOut = 1>
		<cfreturn loggedOut>
	</cffunction>

<!--- ******************************** --->	
<!--- function: getAllApps             --->
<!---                                  --->	
<!--- requires: tartanid               --->
<!---                                  --->	
<!--- returns: query of all apps user  --->
<!---    has access to                 --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="getAllApps" access="remote" hint="Returns all applications a user has access to" returntype="query" output="false">
		<cfargument name="tartanID" required="true" type="string" hint="Tartan ID required">
		
		<cfquery name="qGetApps" datasource="#variables.securityDSN#">
			select at.applicationName
			from ApplicationTypes at
				inner join ApplicationControl ac on at.applicationID = ac.applicationID
			where ac.tartanID = #arguments.tartanID#
		</cfquery>
		
		<cfreturn qGetApps>
	</cffunction>


<!--- ******************************** --->	
<!--- function: checkAuth              --->
<!---                                  --->	
<!--- requires: username,dsn,roleName  --->
<!---                                  --->	
<!--- returns: array of all access     --->
<!---   types for a given application  --->
<!---    writes access to session.     --->
<!--- ******************************** --->
	<cffunction name="checkAuth" access="remote" hint="Checks to see what permission a user has" returntype="array" output="false">
		<cfargument name="username" required="true" type="string" hint="Username required.">
		<cfargument name="dsn" required="true" type="string" hint="DSN required to distinguish aUserPermissions between apps.">
		<cfargument name="roleName" required="true" type="string" hint="Current Role.">

	
		<cfquery name="qGetAccess" datasource="#variables.securityDSN#">
			SELECT at.accessType
			FROM AccessTypes at, AccessControl ac
			WHERE at.accessTypeID = ac.accessTypeID
				AND ac.tartanID = (SELECT u.tartanID
					FROM UserInfo u
					WHERE u.networkUserID = '#ARGUMENTS.username#')
				AND ac.roleID = (SELECT rt.roleID
					FROM RoleTypes rt
					WHERE rt.applicationID = (SELECT at.applicationID
							FROM ApplicationTypes at
							WHERE at.applicationName = '#ARGUMENTS.dsn#')
						AND roleName = '#ARGUMENTS.roleName#')
				AND at.applicationID = (SELECT at.applicationID
					FROM ApplicationTypes at
					WHERE at.applicationName = '#ARGUMENTS.dsn#')
		</cfquery>
		<cfset luserPermissions = valueList(qGetAccess.AccessType)>
		
		<cfif ListFind(lUserPermissions, 'ALL', ',')>
			<cfquery name="qGetAccess" datasource="#variables.securityDSN#">
				SELECT accessType
				FROM AccessTypes
				WHERE applicationID = (SELECT applicationID
						FROM ApplicationTypes
						WHERE applicationName = '#ARGUMENTS.dsn#')
			</cfquery>
			<cfset luserPermissions = valueList(qGetAccess.AccessType)>
		</cfif>
		
		<cfset aUserPermissions = listToArray(luserPermissions)>
		<cfset session.accessList = luserPermissions>
		
		<cfloop from="1" to="#arrayLen(aUserPermissions)#" index="i">
			<cfset tempPerm = Trim(aUserPermissions[i])>
			<cfif ListLen(tempPerm) GT 1>
				<cfset "SESSION.#ARGUMENTS.dsn#_#ListFirst(tempPerm)#" = #ListFirst(tempPerm)#>
			<cfelse>
				<cfset "SESSION.#ARGUMENTS.dsn#_#tempPerm#" = #tempPerm#>
			</cfif>
		</cfloop>
	<cfreturn aUserPermissions>
	</cffunction>


<!--- ******************************** --->	
<!--- function: getUserRole            --->
<!---                                  --->	
<!--- requires: tartanid,dsn           --->
<!---                                  --->	
<!--- returns: array of all roles for  --->
<!---    a given application           --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="getUserRole" access="remote" hint="returns array of user's roles" returntype="array" output="false">
		<cfargument name="tartanID" required="true" type="numeric" hint="Tartan ID to check">
		<cfargument name="dsn" required="true" type="string" hint="DSN required to distinguish roles between apps.">

		<cfquery name="qGetUserRoles" datasource="#variables.securityDSN#">
			select rt.rolename, rt.roleID
			from RoleTypes rt
				inner join RoleControl rc on rt.roleID = rc.roleID
			where	rc.tartanID = #arguments.tartanID#
				and rt.applicationID = (
						select applicationID
						from ApplicationTypes
						where applicationName = '#arguments.dsn#')
		</cfquery>

		<cfreturn arrayfromquery(qGetUserRoles)>
	</cffunction>

<!--- ******************************** --->	
<!--- function: getAccessTypes         --->
<!---                                  --->	
<!--- requires: tartanid,rolename,dsn  --->
<!---                                  --->	
<!--- returns: array of all access     --->
<!---    types for a given role/app    --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="getAccessTypes" access="remote" hint="Checks to see what permission a user has" returntype="array" output="false">
		<cfargument name="tartanid" required="true" type="numeric" hint="Username required.">
		<cfargument name="dsn" required="true" type="string" hint="DSN required to distinguish aUserPermissions between apps.">
		<cfargument name="roleName" required="true" type="string" hint="Current Role.">
		
		<cfquery name="qGetAccess" datasource="#variables.securityDSN#">
			select at.accessType, at.accessTypeID
			from AccessTypes at
				inner join AccessControl ac on at.accessTypeID = ac.accessTypeID
			where ac.tartanID = #arguments.tartanid#
				and ac.roleID = (
						select roleID
					  from RoleTypes
					  where applicationID = (
								select applicationID
								from ApplicationTypes
								where applicationName = '#arguments.dsn#')
							and roleName = '#arguments.roleName#')
				and at.applicationID = (
						select applicationID
						from ApplicationTypes
						where applicationName = '#arguments.dsn#')
		</cfquery>
		
		<cfset luserPermissions = valueList(qGetAccess.AccessType)>
		
		<cfif listfind(lUserPermissions, 'ALL', ',')>
			<cfquery name="qGetAccess" datasource="#variables.securityDSN#">
				select accessType, accessTypeID
				from AccessTypes
				where applicationID = (
						select applicationID
						from ApplicationTypes
						where applicationName = '#arguments.dsn#')
			</cfquery>
		</cfif>
		
		<cfreturn arrayfromquery(qGetAccess)>
	</cffunction>

<!--- ******************************** --->	
<!--- function: checkUserName          --->
<!---                                  --->	
<!--- requires: username					     --->
<!---                                  --->	
<!--- returns: boolean if username     --->
<!---    exists in LDAP                --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="checkUserName" access="remote" hint="Verifies a user's existence in LDAP" returntype="boolean" output="false">
	
		<cfargument name="username" required="true" type="string" hint="Username required"><br>

		<cfset isValid = false>
		
		<cfloop list="#lSubtrees#" index="curSubtree" delimiters=";">
			<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
							start="#curSubtree#" scope="subtree" attributes="dn"
							filter="(sAMAccountName=#arguments.username#)"
							username="#ldapuser#" password="#ldappass#"
							name="qUser">
			<cfif qUser.recordCount>
				<cfset isValid = true>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfreturn isValid>
	</cffunction>


<!--- ******************************** --->	
<!--- function: verifyStudent          --->
<!---                                  --->	
<!--- requires: username,password,dsn  --->
<!---                                  --->	
<!--- returns: structure of all apps,  --->
<!---    with roles and access types   --->
<!---                                  --->
<!---    NEED TO REWRITE STILL!!!!!    --->
<!--- ******************************** --->
	<cffunction name="verifyStudent" access="remote" hint="Verifies a STUDENT's existence in LDAP" returntype="string" output="false">
		<cfargument name="username" required="true" type="string" hint="Username required">
		<cfargument name="password" required="true" type="string" hint="Password required">
		<cfargument name="dsn" required="true" type="string" hint="app name">
		
		<cfset curSubTreeFinal = "ou=Students,dc=scc-nt,dc=sinclair,dc=edu">
		<cfset isValid = 0> 
		
		<cftry>
			<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
							start="#curSubTreeFinal#" scope="subtree" attributes="dn"
							filter="(sAMAccountName=#arguments.username#)"
							username="#ldapuser#" password="#ldappass#"
							name="qUser">
			<cfif qUser.recordcount>
				<cfldap action="query" server="#ldapserver#" port="#ldapport#" timeout="300"
								start="#curSubTreeFinal#" scope="subtree" attributes="*"
								username="#qUser.dn#" password="#arguments.password#"
								filter="(sAMAccountName=#arguments.username#)"
								name="q">
				<cfif q.recordcount>
					<cfquery name="qGetTartanID" dbtype="query">
						select * from q where name = 'employeeID'
					</cfquery>
					<cfquery name="qGetFullName" dbtype="query">
						select * from q where name = 'displayName'
					</cfquery>
					<cfquery name="qGetEmail" dbtype="query">
						select * from q where name = 'mail'
					</cfquery>
					<!--- valid student --->
					<cfset isValid = 1>
					<cfset passhash = hash(arguments.username & dateformat(now(),"yyyymmdd") & "#variables.securityPassHash#")>
					<!--- set cookie variables --->	
					<cfcookie name="auth_user" value="#trim(arguments.username)#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_tartanID" value="#right(qGetTartanID.value,7)#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_fname" value="#trim(listlast(qGetFullName.value, ','))#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_lname" value="#trim(listfirst(qGetFullName.value, ','))#"domain="#variables.cookieDomainName#">
					<cfcookie name="auth_pass" value="#passhash#" domain="#variables.cookieDomainName#">
					<cfcookie name="auth_email" value="#trim(qGetEmail.value)#" domain="#variables.cookieDomainName#">
					
					<!--- set client variables --->
					<cfset "CLIENT.#ARGUMENTS.dsn#" = 'Student'>
					<cfset "CLIENT.#ARGUMENTS.dsn#_role" = 'Student'>
					
					<!--- set session variables --->
					<cfset "SESSION.#ARGUMENTS.dsn#_ALL" = 'ALL'>
					
				</cfif>
			<cfelse>
				<!--- wrong username --->
				<cflocation url="#arguments.failureUrl#?msg=1" addtoken="No">
			</cfif>
			<cfcatch type="Database">
				<!--- system bug/error --->
				<cflocation url="#arguments.failureUrl#?msg=3" addtoken="No">
			</cfcatch>
			<cfcatch type="Application">
				<!--- wrong password --->
				<cflocation url="#arguments.failureUrl#?msg=1" addtoken="No">
			</cfcatch>
		</cftry>
		
		<cfreturn isValid>
	</cffunction>
	

<!--- ******************************** --->	
<!--- function: QueryToArray           --->
<!---                                  --->	
<!--- requires: query                  --->
<!---                                  --->	
<!--- returns: array                   --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="QueryToArray" access="public" output="no" returntype="array" hint="Converts a query to array.">

		<!--- Function Arguments --->
		<cfargument name="query"      required="yes" type="query"  hint="The query to convert.">
		<cfargument name="columnList" required="no"  type="string" hint="Comma-delimited list of the query columns.">

		<cfscript>

			/* Default variables */
			var i = 0;
			var n = 0;
			var cols = "";

			/* Set query column names */
			if(IsDefined("arguments.columnList")) cols = ListToArray(LCase(Replace(arguments.columnList, " ", "")));
			else                                  cols = ListToArray(LCase(arguments.query.columnList));

			/* Create one dimensional array */
			if(ArrayLen(cols) EQ 1)
			{
				array = ArrayNew(1);

				// Loop over rows
				for(i=1; i LTE arguments.query.recordcount; i=i+1)
					array[i] = arguments.query[cols[1]][i];
			}

			/* Create two dimensional array */
			else
			{
				array = ArrayNew(2);

				// Loop over columns
				for(i=1; i LTE ArrayLen(cols); i=i+1)
				{
					// Loop over rows
					for(n=1; n LTE arguments.query.recordcount; n=n+1)
						array[n][i] = arguments.query[cols[i]][n];
				}
			}

			/* Return array */
			return array;

		</cfscript>
	</cffunction>


<!--- ******************************** --->	
<!--- function: ArrayFromQuery           --->
<!---                                  --->	
<!--- requires: query                  --->
<!---                                  --->	
<!--- returns: array                   --->
<!---                                  --->
<!--- ******************************** --->
	<cffunction name="arrayFromQuery" access="public" output="false" displaymethod="false" returntype="array" hint="Takes the input query and writes its values to an array of structures">
		<cfargument name="objectQuery" type="query" required="true">
		<cfscript>
			var ary = arraynew(1);
		</cfscript>
		
		<cfloop query="objectQuery">
			<cfset indx = structnew() />
			<cfloop list="#objectQuery.columnlist#" index="x">
				<cfset "indx.#x#" = trim(evaluate("objectQuery." & #x#)) />
			</cfloop>
			<cfset temp = arrayappend(ary, indx) />
		</cfloop>
		
		<cfreturn ary>
	</cffunction>


	<cffunction name="getAllAccessTypes" access="remote" returntype="query">
		
		<cfquery name="qGetAllAccessTypes" datasource="#variables.securityDSN#">
			select a.accessTypeID as AccessTypeID, a.accessType as AccessType
			from AccessTypes a
			where a.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="52">
			order by AccessType
		</cfquery>
		
		<cfreturn qGetAllAccessTypes>
	</cffunction>
	
	<cffunction name="getAllRoles" access="remote" returntype="query">
		
		<cfquery name="qGetAllRoles" datasource="#variables.securityDSN#">
			select r.roleID as RoleID, r.roleName as RoleName
			from RoleTypes r
				inner join ApplicationTypes ap on r.applicationID = ap.applicationID
			where r.applicationID = <cfqueryparam cfsqltype="cf_sql_integer" value="52">
			order by roleName
		</cfquery>
		
		<cfreturn qGetAllRoles>
	</cffunction>

</cfcomponent>