<cfcomponent displayName="ObjectFactory" extends="Singleton" hint="Able to create and return Object/cfc instances for use in the application.">

	<cfscript>
		variables.instance.inited = false;
		variables.instance.dao = APPLICATION.beanFactory.getBean('configDAO');
	</cfscript>

	<cffunction name="dump">
		<cfdump var="#arguments[1]#" label="#arguments[2]#">
	</cffunction>
	<cffunction name="abort"><cfabort></cffunction>  

	<cffunction name="getObjectFactory" access="public" returntype="ObjectFactory" output="false" displayname="getObjectFactory" hint="Returns an instance of the singleton ObjectFactory.">
		
		<cfscript>
		 	if ( getInitState() eq false)
			{
				// Write init code here
				init();	
			}
			
			return this;
		</cfscript>
	</cffunction>	
	
	<cffunction name="init" access="public" returntype="void" output="false" displayname="ObjectFactory Constructor" hint="I initialize an object of type ObjectFactory.">
		
		<cfscript>
		 	if ( getInitState() eq false)
			{
				// Write init code here
				setInitState(true);	
			}
		</cfscript>
	</cffunction>	

<!--- getObjectByName()
	  Method returns an object instance of a .cfc by name and type.
	  Valid types are dao, gateway, service --->
	<cffunction name="getObjectByName" access="public" output="true" hint="Creates an object instance by name and type.">
		<cfargument name="cfcName" type="string" required="true" />
		<cfargument name="cfcType" type="string" required="true" />
		<cfargument name="cfcPath" type="string" default="" required="false" />
		
		<cfscript>
			var compName = "";
			var compPath = "";
			
			path = arguments.cfcPath;		
			
			if (len(path))
			{
				
				switch (path)
				{
					case "config":
						compPath = variables.instance.dao.getConfigComponentsPath();
						break;
						
					case "error":
						compPath = variables.instance.dao.getErrorComponentsPath();
						break;
						
					case "event":
						compPath = variables.instance.dao.getEventComponentsPath();
						break;

					case "availability":
						compPath = variables.instance.dao.getApplicationORMComponentsPath();
						break;

					case "security":
						compPath = variables.instance.dao.getSecurityComponentsPath();
						break;
						
					case "util":
						compPath = variables.instance.dao.getUtilsComponentsPath();
						break;
				}
				
				// account for a bean, dao or service directory. except in utils directory, where none will exist
				if (path neq "util")
				{
					compPath = compPath & cfcType & ".";
				}
			
			} else {
			
				switch (arguments.cfcType)
				{
					case "bean":
						compPath = variables.instance.dao.getBeanComponentsPath();
						break;
											
					case "service":
						compPath = variables.instance.dao.getServiceComponentsPath();
						break;
					
					case "dao":
						compPath = variables.instance.dao.getDAOComponentsPath();
						break;
				}
			}
	
			if (arguments.cfcType EQ "bean" OR arguments.cfcType EQ "") {
				compName = "#arguments.cfcName#";
			}else{
				compName = "#arguments.cfcName#_#arguments.cfcType#";
			}
			
			if (arguments.cfcType eq "bean" OR arguments.cfcType EQ "")
			{
				obj = CreateObject("component", compPath & compName);
			}else{
				if (not isDefined('Application.#compName#'))
				{							
					obj = CreateObject("component", compPath & compName);
					//Application['#compName#'] = obj;
				}else{
					// create an object	
					obj = Application[compName];			
				}
			}
			
			// test if needed to init the obj
			if ( isDefined('obj'))
			{
				//obj.configure();
			}else{
				obj = "";
			}		
		</cfscript>

		<cfreturn obj>
	</cffunction>

	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->	
	<cffunction name="getInitState" access="public" returntype="boolean" output="false" hint="I return the init state of this component.">
		<cfreturn variables.instance.inited />
	</cffunction>
	
	<cffunction name="setInitState" access="private" returntype="VOID" output="false" hint="I set the init state of this component.">
		<cfargument name="initState" type="boolean" required="true" />
		<cfset variables.instance.inited = arguments.initState />
	</cffunction>
	
</cfcomponent>