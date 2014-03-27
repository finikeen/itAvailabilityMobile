<cfcomponent name="errorLogService"  displayname="errorLog Service" hint="I am the primary service for errorLog objects" output="false">

<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeInstanceProperties --->
	<cfscript>
		// Set this variable to 1 if you want any objects of this type to be cleared from the database,
		// before new values are inserted.  Note: No updates will take place if you set deleteBeforeSave to 1.		
		variables.instance.deleteBeforeSave = 0;
		
		// The Data Access Object for this Service
		variables.instance.dao = APPLICATION.availability.objectFactory.getObjectByName("errorLog","dao","error");
	</cfscript>
	<!--- END MANAGEDCODE BLOCK --->
	
	
<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeInit --->
	<!--- 
	***********************
	**  INIT
	***********************
	--->
	<cffunction name="init" access="public" returntype="void" output="false" displayname="Service Constructor" hint="I initialize this service as part of the framework startup.">
		<cfscript>
			// run init code here
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeGetByID --->
	<!--- 
	***********************
	**  GET BY ID
	***********************
	--->
	<cffunction name="getByID" access="public" returntype="any" output="false" displayname="Get objects by ID" hint="I return a single errorLog identified by its Object ID">
		<cfargument name="data" type="struct" required="true" hint="data is a structure with properties named by the key values you want to read from the database.  For instance: data.studentID etc." />
		<cfscript>
			e = 0;
			
			// event result object
			eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");
			
			// struct containing data arguments for the read method
			data = arguments.data;
			
			// try {
			
				if ( StructIsEmpty(data) )
				{
					eventResult.setSuccess(false);
					eventResult.setErrorMessage("Error reading errorLog.  No primary key value defined.");		
				}else{
					// read the object passing the arguments structure as a source for the primary keys in the object
					errorLog = variables.instance.dao.read(argumentcollection=data);
				}				
				
				// set the returned object in the data prop of the event result
				eventResult.setData(errorLog);

			/*
			}catch (Any e) {
				
		variables.errorID = CreateUUID();
		try
		{
			// create error service
			error_service = APPLICATION.availability.objectFactory.getObjectByName("errorLog","service","error");
			//create errorLog bean to pass through to the service
			errorBean = APPLICATION.availability.objectFactory.getObjectByName("errorLog","bean","error");			
			//init the bean and pass properties into the init()
			errorBean.init(errorID=variables.errorID,
						   applicationName=variables.instance.cfcPackage,
						   componentName=variables.instance.cfcName,
						   methodName="getByID",
						   errorType=cfcatch.Type,
						   errorMessage=cfcatch.Message,
						   errorDetail=cfcatch.Detail,
						   serverName=CGI.SERVER_NAME,
						   ipAddress=CGI.HTTP_HOST,
						   browser=CGI.HTTP_USER_AGENT,
						   httpReferer=CGI.HTTP_REFERER,
						   script=CGI.SCRIPT_NAME,
						   queryString=CGI.QUERY_STRING,
						   template=CGI.PATH_TRANSLATED,
						   errorDate=CreateODBCDate(now()));
			//pass the bean into the save()
			eventResult = error_service.save(errorBean);
																
			variables.errorID = errorBean.getErrorID();
		}catch(any excpt){
			//log a file
			//send an email
		}

			}
			*/
			
			return eventResult;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeGetAll --->
	<!--- 
	***********************
	**  GET ALL
	***********************
	--->
	<cffunction name="getAll" access="public" returntype="any" output="false" displayname="Get all objects" hint="I return all errorLogs">
		<cfargument name="data" type="struct" required="true" />
		<cfscript>
			e = 0;

			// struct containing data arguments for the read method
			data = arguments.data;
			
			// event result object
			eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");
			
			// try {
			
				if ( StructIsEmpty(data) )
				{
					// assume there is only one primary key for the object.  Read by the default key.
					errorLogs = variables.instance.dao.readAll();				
				}else{
					// read the object passing the arguments structure as a source for the primary keys in the object
					errorLogs = variables.instance.dao.readAll(argumentcollection=data);
				}
				
				// set the returned object in the data prop of the event result
				eventResult.setData(errorLogs);

			/*
			}catch (Any e) {			
				
		variables.errorID = CreateUUID();
		try
		{
			// create error service
			error_service = APPLICATION.availability.objectFactory.getObjectByName("errorLog","service","error");
			//create errorLog bean to pass through to the service
			errorBean = APPLICATION.availability.objectFactory.getObjectByName("errorLog","bean","error");			
			//init the bean and pass properties into the init()
			errorBean.init(errorID=variables.errorID,
						   applicationName=variables.instance.cfcPackage,
						   componentName=variables.instance.cfcName,
						   methodName="getAll",
						   errorType=cfcatch.Type,
						   errorMessage=cfcatch.Message,
						   errorDetail=cfcatch.Detail,
						   serverName=CGI.SERVER_NAME,
						   ipAddress=CGI.HTTP_HOST,
						   browser=CGI.HTTP_USER_AGENT,
						   httpReferer=CGI.HTTP_REFERER,
						   script=CGI.SCRIPT_NAME,
						   queryString=CGI.QUERY_STRING,
						   template=CGI.PATH_TRANSLATED,
						   errorDate=CreateODBCDate(now()));
			//pass the bean into the save()
			eventResult = error_service.save(errorBean);
																
			variables.errorID = errorBean.getErrorID();
		}catch(any excpt){
			//log a file
			//send an email
		}

			}
			*/
			
			return eventResult;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->


	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeSave --->
	
	<!--- 
	***********************
	**  SAVE
	***********************
	--->
	<cffunction name="save" access="public" returntype="any" output="false" displayname="Save object(s)" hint="I cause an object of type errorLog to be created or updated in the database.">
		<cfargument name="data" type="any" required="true" />
		
		<cfscript>
			e = 0;
			
			// the data to save
			data = arguments.data;
			
			// whether or not to delete existing objects before saving new ones
			deleteBeforeSave = variables.instance.deleteBeforeSave;
			deleteBeforeSaveID = "";
			
			// event result object
			eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");			

			// try {

				// If this object demands a deleteBeforeSave relationship
				// Delete all of the objects before inserting the new ones
				if (deleteBeforeSave eq 1)
				{
					// deleteBeforeSaveID holds the main id for the main object of the sub object which is being deleted.
					// for instance, if this object relates to a Student object, then the deleteBeforeSaveID would be the
					// value of a studentID in the table. 
					if ( isArray(data) )
					{
						deleteBeforeSaveID = data[1].geterrorID();
					}else{
						deleteBeforeSaveID = data.geterrorID();
					}
					
					if ( len(deleteBeforeSaveID) )
					{ 
						eventResult = deleteByID(deleteBeforeSaveID);
					}
				
				}
				
				// save the object(s)
				if (eventResult.getSuccess() eq true)
				{
					// determine if saving multiple or single objects
					if ( isArray(data) )
					{
							// if array save each object in the array
							for (s=1; s lte ArrayLen(data); s=s+1)
							{
								variables.instance.dao.save(data[s], deleteBeforeSave);
							} 
					}else{
						variables.instance.dao.save(data, deleteBeforeSave);
					}
				}
				
			/*
			}catch (Any e) {
				
		variables.errorID = CreateUUID();
		try
		{
			// create error service
			error_service = APPLICATION.availability.objectFactory.getObjectByName("errorLog","service","error");
			//create errorLog bean to pass through to the service
			errorBean = APPLICATION.availability.objectFactory.getObjectByName("errorLog","bean","error");			
			//init the bean and pass properties into the init()
			errorBean.init(errorID=variables.errorID,
						   applicationName=variables.instance.cfcPackage,
						   componentName=variables.instance.cfcName,
						   methodName="save",
						   errorType=cfcatch.Type,
						   errorMessage=cfcatch.Message,
						   errorDetail=cfcatch.Detail,
						   serverName=CGI.SERVER_NAME,
						   ipAddress=CGI.HTTP_HOST,
						   browser=CGI.HTTP_USER_AGENT,
						   httpReferer=CGI.HTTP_REFERER,
						   script=CGI.SCRIPT_NAME,
						   queryString=CGI.QUERY_STRING,
						   template=CGI.PATH_TRANSLATED,
						   errorDate=CreateODBCDate(now()));
			//pass the bean into the save()
			eventResult = error_service.save(errorBean);
																
			variables.errorID = errorBean.getErrorID();
		}catch(any excpt){
			//log a file
			//send an email
		}

			}
			*/
			
			return eventResult;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->


	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeDelete --->
	<!--- 
	***********************
	**  DELETE
	***********************
	--->
	<cffunction name="delete" access="public" returntype="any" output="false" displayname="Delete object(s)" hint="I cause an object of type errorLog to be deleted from the database.">
		<cfargument name="data" type="any" required="true" />
		
		<cfscript>
			e = 0;
			
			// the data to delete
			data = arguments.data;
			
			// event result object
			eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");			


			//try {
				
				// determine if deleting multiple or single objects
				if ( isArray(data) )
				{
						for (s=1; s lte ArrayLen(data); s=s+1)
						{
							variables.instance.dao.delete(data[s]);
						} 
				}else{
					variables.instance.dao.delete(data);
				}
			
			/*
			}catch (Any e) {
				
		variables.errorID = CreateUUID();
		try
		{
			// create error service
			error_service = APPLICATION.availability.objectFactory.getObjectByName("errorLog","service","error");
			//create errorLog bean to pass through to the service
			errorBean = APPLICATION.availability.objectFactory.getObjectByName("errorLog","bean","error");			
			//init the bean and pass properties into the init()
			errorBean.init(errorID=variables.errorID,
						   applicationName=variables.instance.cfcPackage,
						   componentName=variables.instance.cfcName,
						   methodName="delete",
						   errorType=cfcatch.Type,
						   errorMessage=cfcatch.Message,
						   errorDetail=cfcatch.Detail,
						   serverName=CGI.SERVER_NAME,
						   ipAddress=CGI.HTTP_HOST,
						   browser=CGI.HTTP_USER_AGENT,
						   httpReferer=CGI.HTTP_REFERER,
						   script=CGI.SCRIPT_NAME,
						   queryString=CGI.QUERY_STRING,
						   template=CGI.PATH_TRANSLATED,
						   errorDate=CreateODBCDate(now()));
			//pass the bean into the save()
			eventResult = error_service.save(errorBean);
																
			variables.errorID = errorBean.getErrorID();
		}catch(any excpt){
			//log a file
			//send an email
		}

			}
			*/
			
			return eventResult;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->


	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.service:getManagedCodeDeleteByID --->
	<!--- 
	***********************
	**  DELETE errorLog BY ID
	***********************
	--->
	<cffunction name="deleteByID" access="private" returntype="any" output="false" displayname="Delete existing objects before saving new ones" hint="I cause an object of type errorLog to be deleted from the database.">
		<cfargument name="id" type="string" required="true" />
		
		<cfscript>
			e = 0;
			
			// the id for the delete
			id = arguments.id;
			
			// event result object
			eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");			


			//try {
				
					variables.instance.dao.deleteByID(id);
			/*
			}catch (Any e) {
				
		variables.errorID = CreateUUID();
		try
		{
			// create error service
			error_service = APPLICATION.availability.objectFactory.getObjectByName("errorLog","service","error");
			//create errorLog bean to pass through to the service
			errorBean = APPLICATION.availability.objectFactory.getObjectByName("errorLog","bean","error");			
			//init the bean and pass properties into the init()
			errorBean.init(errorID=variables.errorID,
						   applicationName=variables.instance.cfcPackage,
						   componentName=variables.instance.cfcName,
						   methodName="deleteByID",
						   errorType=cfcatch.Type,
						   errorMessage=cfcatch.Message,
						   errorDetail=cfcatch.Detail,
						   serverName=CGI.SERVER_NAME,
						   ipAddress=CGI.HTTP_HOST,
						   browser=CGI.HTTP_USER_AGENT,
						   httpReferer=CGI.HTTP_REFERER,
						   script=CGI.SCRIPT_NAME,
						   queryString=CGI.QUERY_STRING,
						   template=CGI.PATH_TRANSLATED,
						   errorDate=CreateODBCDate(now()));
			//pass the bean into the save()
			eventResult = error_service.save(errorBean);
																
			variables.errorID = errorBean.getErrorID();
		}catch(any excpt){
			//log a file
			//send an email
		}

			}
			*/
			
			return eventResult;
		</cfscript>
	</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

</cfcomponent>
