<cfcomponent displayName="Controller" extends="Singleton" hint="Receives events and sends them to the appropriate Service to handle the event.">

	<cfscript>
		variables.instance.inited = false;
		variables.instance.dataTypeUtil = APPLICATION.beanFactory.getBean('dataTypeUtil');
		variables.instance.dao = APPLICATION.beanFactory.getBean('configDAO');
		variables.instance.eventComponentsPath = variables.instance.dao.getEventComponentsPath();
	</cfscript>	

	<!--- dump() --->
	<cffunction name="dump">
		<cfdump var="#arguments[1]#" label="#arguments[2]#">
	</cffunction>
	
	<!--- abort() --->
	<cffunction name="abort"><cfabort></cffunction>  

	<!--- getController() --->
	<cffunction name="getController" access="public" returntype="Controller" output="false" displayname="getController" hint="Returns an instance of the singleton Controller.">
		
		<cfscript>
		 	if ( getInitState() eq false)
			{
				// Write init code here
				init();	
			}
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- init() --->
	<cffunction name="init" access="public" returntype="void" output="false" displayname="Controller Constructor" hint="I initialize an object of type application controller.">

		<cfscript>
			if (getInitState() eq false)
			{
				setInitState(true);
			}
		</cfscript>
	</cffunction>
	
	<!--- broadcastEvent() --->
	<cffunction name="broadcastEvent" access="remote" returntype="any">
		<cfargument name="CFBroadcastEvent" type="any" required="yes">
		
		<cfscript>
			var service = "";
			var serviceName = "";
			
			CFBroadcastEvent = arguments.CFBroadcastEvent;

			/*************************************************
			  variables used to dynamically instantiate the appropriate 
			  service class and method for the provided object type.
			*/
			
			// service class name
			cfcType = CFBroadcastEvent.getCFCType();			
			// the method to call
			cfServiceMethod = CFBroadcastEvent.getCFServiceMethod();
			// the object name; ie cfcName
			objectType = CFBroadcastEvent.getObjectType();
			// the path to a cfc, if the path is not in the main edu.sinclair.(bean/dao/service) directory.
			// if the directory for the cfc is in a user defined location, then set the cfcPath to the folder
			// name and define a variable for the path in the Application.cfc.  See the ObjectFactory.cfc
			// cfcPath argument for more detail.
			cfcPath = CFBroadcastEvent.getCFCPath();
		</cfscript>

		<cfset service = APPLICATION.availability.objectFactory.getObjectByName(cfcName=objectType, cfcType=cfcType, cfcPath=cfcPath)>
		<cfset args = StructNew()>
		<!--- <cfset args.event = CFBroadcastEvent> --->
		<cfset eventData = CFBroadcastEvent.getData()>
		<cfset args.data = eventData>
		<cfinvoke component="#service#" method="#cfServiceMethod#" argumentCollection="#args#" returnvariable="resultData" />
		
		<!--- Accommodate items returned without an EventResult Component --->
		<cfif IsInstanceOf(resultData, "#variables.instance.eventComponentsPath#.bean.EventResult")>
		  	<cfset eventResult = resultData>
		<cfelse>
			<cfset eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event")>
		  	<!--- Format the records as a Query, JSON, etc. --->
		  	<cfif StructKeyExists(eventData,"format")>
				<cfset resultData = variables.instance.dataTypeUtil.formatRecords(resultData,eventData.format)>
			 </cfif>			
			<cfset eventResult.setData(resultData)>
		</cfif>

		<cfreturn eventResult>
	</cffunction>
	
	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->
	
	<!--- Init State --->	
	<cffunction name="getInitState" access="public" returntype="boolean" output="false" hint="I return the init state of this component.">
		<cfreturn variables.instance.inited />
	</cffunction>

	<cffunction name="setInitState" access="private" returntype="VOID" output="false" hint="I set the init state of this component.">
		<cfargument name="initState" type="boolean" required="true" />
		<cfset variables.instance.inited = arguments.initState />
	</cffunction>	

</cfcomponent>