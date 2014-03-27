<!--- 

 --->
<cfcomponent displayname="errorLog" hint="errorLog">

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodeProperties --->
		<cfproperty name="errorID" type="string" required="1" displayname="errorID" hint="" default="">
		<cfproperty name="applicationName" type="string" required="1" displayname="applicationName" hint="" default="">
		<cfproperty name="componentName" type="string" required="1" displayname="componentName" hint="" default="">
		<cfproperty name="methodName" type="string" required="0" displayname="methodName" hint="" default="">
		<cfproperty name="errorType" type="string" required="1" displayname="errorType" hint="" default="">
		<cfproperty name="errorMessage" type="string" required="1" displayname="errorMessage" hint="" default="">
		<cfproperty name="errorDetail" type="string" required="0" displayname="errorDetail" hint="" default="">
		<cfproperty name="serverName" type="string" required="0" displayname="serverName" hint="" default="">
		<cfproperty name="ipAddress" type="string" required="0" displayname="ipAddress" hint="" default="">
		<cfproperty name="browser" type="string" required="0" displayname="browser" hint="" default="">
		<cfproperty name="httpreferer" type="string" required="0" displayname="httpreferer" hint="" default="">
		<cfproperty name="script" type="string" required="0" displayname="script" hint="" default="">
		<cfproperty name="querystring" type="string" required="0" displayname="querystring" hint="" default="">
		<cfproperty name="template" type="string" required="0" displayname="template" hint="" default="">
		<cfproperty name="errorDate" type="date" required="1" displayname="errorDate" hint="" default="1/1/1900">
	<!--- END MANAGEDCODE BLOCK --->

	<cfscript>
		//START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodeInstanceData
			//used specifically for cfcPowerTools
			//instance data: 
			variables.instance.cfcPackage = "errorService";
			variables.instance.cfcName = "errorLog";
			variables.instance.cfcDSN = "errorService";
			variables.instance.cfcTableName = "errorLog";
			variables.instance.PrimaryKeys = "errorID";
			
			//default values:
			variables.instance.errorID = '';
			variables.instance.applicationName = '';
			variables.instance.componentName = '';
			variables.instance.methodName = '';
			variables.instance.errorType = '';
			variables.instance.errorMessage = '';
			variables.instance.errorDetail = '';
			variables.instance.serverName = '';
			variables.instance.ipAddress = '';
			variables.instance.browser = '';
			variables.instance.httpreferer = '';
			variables.instance.script = '';
			variables.instance.querystring = '';
			variables.instance.template = '';
			variables.instance.errorDate = '1/1/1900';
		//END MANAGEDCODE BLOCK
	
	</cfscript>

	<!--- 
	***********************
	**  INIT
	***********************
	--->
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodeInit --->
	<cffunction name="init" access="public" returntype="errorLog" output="false" displayname="errorLog Constructor" hint="I initialize an object of type errorLog.">
		<cfargument name="errorID" type="string" default=""/>
		<cfargument name="applicationName" type="string" default=""/>
		<cfargument name="componentName" type="string" default=""/>
		<cfargument name="methodName" type="string" default=""/>
		<cfargument name="errorType" type="string" default=""/>
		<cfargument name="errorMessage" type="string" default=""/>
		<cfargument name="errorDetail" type="string" default=""/>
		<cfargument name="serverName" type="string" default=""/>
		<cfargument name="ipAddress" type="string" default=""/>
		<cfargument name="browser" type="string" default=""/>
		<cfargument name="httpreferer" type="string" default=""/>
		<cfargument name="script" type="string" default=""/>
		<cfargument name="querystring" type="string" default=""/>
		<cfargument name="template" type="string" default=""/>
		<cfargument name="errorDate" type="date" default="1/1/1900"/>
		<cfscript>
			seterrorID(arguments.errorID);
			setapplicationName(arguments.applicationName);
			setcomponentName(arguments.componentName);
			setmethodName(arguments.methodName);
			seterrorType(arguments.errorType);
			seterrorMessage(arguments.errorMessage);
			seterrorDetail(arguments.errorDetail);
			setserverName(arguments.serverName);
			setipAddress(arguments.ipAddress);
			setbrowser(arguments.browser);
			sethttpreferer(arguments.httpreferer);
			setscript(arguments.script);
			setquerystring(arguments.querystring);
			settemplate(arguments.template);
			seterrorDate(arguments.errorDate);
			return this;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->


	<!--- 
	***********************
	**  METHODS
	***********************
	--->
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodePopulateFromXML --->
	<cffunction name="populateFromXML" access="public" returntype="errorLog" output="false" displayname="populateFromXML" hint="I populate an object of type errorLog from a provided XML object.">
		<cfargument name="xmlDoc" type="xml" required="true"/>
		<cfscript>
			seterrorID(arguments.xmlDoc.errorLog.errorID);
			setapplicationName(arguments.xmlDoc.errorLog.applicationName);
			setcomponentName(arguments.xmlDoc.errorLog.componentName);
			setmethodName(arguments.xmlDoc.errorLog.methodName);
			seterrorType(arguments.xmlDoc.errorLog.errorType);
			seterrorMessage(arguments.xmlDoc.errorLog.errorMessage);
			seterrorDetail(arguments.xmlDoc.errorLog.errorDetail);
			setserverName(arguments.xmlDoc.errorLog.serverName);
			setipAddress(arguments.xmlDoc.errorLog.ipAddress);
			setbrowser(arguments.xmlDoc.errorLog.browser);
			sethttpreferer(arguments.xmlDoc.errorLog.httpreferer);
			setscript(arguments.xmlDoc.errorLog.script);
			setquerystring(arguments.xmlDoc.errorLog.querystring);
			settemplate(arguments.xmlDoc.errorLog.template);
			seterrorDate(arguments.xmlDoc.errorLog.errorDate);
			return this;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodePopulateObjectProperties --->
	<cffunction name="populateObjectProperties" access="public" returnType="void" output="FALSE">
		<cfscript>
			data = StructNew();
			data.objectID = getErrorID();
			service = APPLICATION.schooollinkages.objectFactory.getObjectByName("ObjectProperties","service","");
			eventResult = service.getByID(data);

			if (eventResult.getSuccess() eq true)
			{
				objPropBean = eventResult.getData();
				super.populateObjectProperties(objPropBean);
			}
		</cfscript>
	</cffunction>
		
	<!--- END MANAGEDCODE BLOCK --->
	

	<!--- 
	getCFCName()
	 --->
	<cffunction returnType="string" access="public" name="getCFCName" output="FALSE">
		<cfreturn variables.instance.cfcName/>
	</cffunction>
	<!--- 
	getTableName()
	 --->
	<cffunction returnType="string" access="public" name="getTableName" output="FALSE">
		<cfreturn variables.instance.cfcTableName/>
	</cffunction>

	<!--- 
	getPrimaryKeys()
	 --->
	<cffunction returnType="string" access="public" name="getPrimaryKeys" output="FALSE">
		<cfreturn variables.instance.PrimaryKeys/>
	</cffunction>

	<!--- 
	getAllProperties()
	--->
	<cffunction name="getAllProperties" access="public" returnType="struct" output="FALSE" hint="structure of all properties">
		<cfargument name="stMetaData" type="struct" required="no" default="#structnew()#">
		<cfargument name="stAllProperties" type="struct" required="no" default="#structnew()#">
		
		<cfscript>
			var z = "";
			var x = "";
			var propertyName = "";
			
			if(structcount(arguments.stMetaData) EQ 0){
				arguments.stMetaData = getmetadata(this);
			}
			
			if(structkeyexists(arguments.stMetaData,"properties")){
				for(z=1; z lte arraylen(arguments.stMetaData.properties); z=z+1){
					propertyName = arguments.stMetaData.properties[z].name;

					//if property does not exist in stAllProperties
					if(NOT structKeyExists(arguments.stAllProperties,propertyName)){
						arguments.stAllProperties[propertyName] = duplicate(arguments.stMetaData.properties[z]);
						//capture implementedin
						arguments.stAllProperties[propertyName]["implementedin"] = arguments.stMetaData.name;
					}
					//else if it does, then loop over iterative property to add attributes not present
					else{
						//loop over this Propertys structure and make sure each key used
						for(x in arguments.stMetaData.Properties[z]){
							if(not structkeyexists(arguments.stAllProperties[propertyName],x)){
								arguments.stAllProperties[propertyName][x] =  duplicate(arguments.stMetaData.Properties[z][x]);
							}
						}
					}
				}
			}
			
			if(IsDefined("arguments.stMetaData.extends") AND IsStruct(arguments.stMetaData.extends)){
				arguments.stAllProperties = getAllProperties(stMetaData=arguments.stMetaData.extends,stAllProperties=arguments.stAllProperties);
			}
			
			return arguments.stAllProperties;
		</cfscript>		
	</cffunction>
	
	<!--- 
	throw()
	 --->
	<cffunction name="throw" output="false" returntype="void" access="public">
		<cfargument default="" type="string" name="message" />
		<cfthrow message="#arguments.message#"/>
	</cffunction>
		
	<!--- 
	getPropertyData()
	--->
	<cffunction name="getPropertyData" access="public" returnType="struct" output="FALSE" hint="get object property data">
		<cfscript>
			var stProperties = getAllProperties();
			var stReturnData = structNew();
			var property = "";
			
			for(property in stProperties){
				if(structkeyexists(variables.instance,property)){
					stReturnData[property] = variables.instance[property];
				}
			}
			return stReturnData;
		</cfscript>
	</cffunction>	

	<!--- 
	getInstanceMemento()
	--->
	<cffunction name="getInstanceMemento" access="public" returntype="struct" output="false"
	            displayname="Get Instance Memento"
	            hint="I set this users instance data from a new memento.">
		<cfreturn variables.instance />
	</cffunction>

	<!--- 
	setInstanceMemento()
	--->
	<cffunction name="setInstanceMemento" access="public" returntype="User" output="false"
	            displayname="Set Instance Memento"
	            hint="I set this users instance data from a new memento.">
		<cfargument name="memento" type="struct" required="true" displayname="Memento"
		            hint="I am a memento - a struct containing data." />
		<cfset variables.instance = arguments.memento />
		<cfreturn this />
	</cffunction>


	<!--- 
	***********************
	**  GETTERS and SETTERS
	***********************
	--->	

		

	
		
		
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodeObjectPropertiesGetterSetters --->
	<!--- sets the object properties object id to the relative primary key field in this cfc --->
	<cffunction name="setObjectPropertiesObjectID" access="public" returnType="void" output="FALSE">
		<cfreturn setObjectID(geterrorID())>
	</cffunction>
	
	<!--- sets the object properties object type value to the type of object for this cfc --->
	<cffunction name="setObjectPropertiesObjectType" access="public" returnType="void" output="FALSE">
		<cfreturn setObjectType(getCFCName())>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->


	<cffunction name="getErrorID" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.errorID>
	</cffunction>
	<cffunction name="setErrorID" access="public" output="FALSE">
		<cfargument name="errorID" type="string" required="1"/>
		<cfset variables.instance.errorID = arguments.errorID>
	</cffunction>
	
	<cffunction name="getApplicationName" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.applicationName>
	</cffunction>
	<cffunction name="setApplicationName" access="public" output="FALSE">
		<cfargument name="applicationName" type="string" required="1"/>
		<cfset variables.instance.applicationName = arguments.applicationName>
	</cffunction>
	
	<cffunction name="getComponentName" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.componentName>
	</cffunction>
	<cffunction name="setComponentName" access="public" output="FALSE">
		<cfargument name="componentName" type="string" required="1"/>
		<cfset variables.instance.componentName = arguments.componentName>
	</cffunction>
	
	<cffunction name="getMethodName" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.methodName>
	</cffunction>
	<cffunction name="setMethodName" access="public" output="FALSE">
		<cfargument name="methodName" type="string" required="1"/>
		<cfset variables.instance.methodName = arguments.methodName>
	</cffunction>
	
	<cffunction name="getErrorType" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.errorType>
	</cffunction>
	<cffunction name="setErrorType" access="public" output="FALSE">
		<cfargument name="errorType" type="string" required="1"/>
		<cfset variables.instance.errorType = arguments.errorType>
	</cffunction>
	
	<cffunction name="getErrorMessage" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.errorMessage>
	</cffunction>
	<cffunction name="setErrorMessage" access="public" output="FALSE">
		<cfargument name="errorMessage" type="string" required="1"/>
		<cfset variables.instance.errorMessage = arguments.errorMessage>
	</cffunction>
	
	<cffunction name="getErrorDetail" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.errorDetail>
	</cffunction>
	<cffunction name="setErrorDetail" access="public" output="FALSE">
		<cfargument name="errorDetail" type="string" required="1"/>
		<cfset variables.instance.errorDetail = arguments.errorDetail>
	</cffunction>
	
	<cffunction name="getServerName" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.serverName>
	</cffunction>
	<cffunction name="setServerName" access="public" output="FALSE">
		<cfargument name="serverName" type="string" required="1"/>
		<cfset variables.instance.serverName = arguments.serverName>
	</cffunction>
	
	<cffunction name="getIpAddress" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.ipAddress>
	</cffunction>
	<cffunction name="setIpAddress" access="public" output="FALSE">
		<cfargument name="ipAddress" type="string" required="1"/>
		<cfset variables.instance.ipAddress = arguments.ipAddress>
	</cffunction>
	
	<cffunction name="getBrowser" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.browser>
	</cffunction>
	<cffunction name="setBrowser" access="public" output="FALSE">
		<cfargument name="browser" type="string" required="1"/>
		<cfset variables.instance.browser = arguments.browser>
	</cffunction>
	
	<cffunction name="getHttpreferer" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.httpreferer>
	</cffunction>
	<cffunction name="setHttpreferer" access="public" output="FALSE">
		<cfargument name="httpreferer" type="string" required="1"/>
		<cfset variables.instance.httpreferer = arguments.httpreferer>
	</cffunction>
	
	<cffunction name="getScript" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.script>
	</cffunction>
	<cffunction name="setScript" access="public" output="FALSE">
		<cfargument name="script" type="string" required="1"/>
		<cfset variables.instance.script = arguments.script>
	</cffunction>
	
	<cffunction name="getQuerystring" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.querystring>
	</cffunction>
	<cffunction name="setQuerystring" access="public" output="FALSE">
		<cfargument name="querystring" type="string" required="1"/>
		<cfset variables.instance.querystring = arguments.querystring>
	</cffunction>
	
	<cffunction name="getTemplate" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.template>
	</cffunction>
	<cffunction name="setTemplate" access="public" output="FALSE">
		<cfargument name="template" type="string" required="1"/>
		<cfset variables.instance.template = arguments.template>
	</cffunction>
	
	<cffunction name="getErrorDate" access="public" returnType="string" output="FALSE">
		<cfreturn variables.instance.errorDate>
	</cffunction>
	<cffunction name="setErrorDate" access="public" output="FALSE">
		<cfargument name="errorDate" type="string" required="1"/>
		<cfscript>
			if(IsDate(arguments.errorDate)){
				variables.instance.errorDate = arguments.errorDate;
			}
			else{
				throw("errorDate property value is not date type");
			}
		</cfscript>
	</cffunction>
	
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.bean:getManagedCodeGetterSetters --->
	<!--- END MANAGEDCODE BLOCK --->

</cfcomponent>
