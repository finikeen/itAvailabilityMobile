<cfcomponent name="errorLog" displayname="errorLog Data Access Object" hint="I provide persistence for a single errorLog" output="false">

	<cfscript>
		variables.instance.cfcPackage = "errorService";
		variables.instance.cfcName = "errorLog_DAO";
		variables.instance.errorDSN = "errorService";
		variables.instance.dsn = REQUEST.dsn;
		variables.instance.dbUser = "";
		variables.instance.dbPassword = "";
		variables.instance.useObjectProperties = 1;
	</cfscript>

	<!--- 
	***********************
	**  INIT
	***********************
	--->
	<cffunction name="init" access="public" returntype="errorLog" output="false" displayname="errorLog Data Access Object Constructor" hint="I initialize the errorLog Data Access Object.">
		<cfargument name="dsn" type="string" required="false" />
		<cfargument name="dbUser" type="string" required="false" default=""/>
		<cfargument name="dbPassword" type="string" required="false"  default=""/>
		
		<cfscript>
			//variables.instance.dsn = arguments.dsn;
			//variables.instance.dbUser = arguments.dbUser;
			//variables.instance.dbPassword = arguments.dbPassword;
			return this;
		</cfscript>
	</cffunction>

	<!--- 
	*********************************************
	**  SAVE: DETERMINES CREATE OR UPDATE
	*********************************************
	--->
	<cffunction name="Save" access="public" displayname="Determines Create or Update" output="false">
		<cfargument name="errorLog" type="any" required="true" displayname="errorLog" hint="I am the errorLog for which to create or update a record."/>
		<cfargument name="deleteBeforeSave" type="numeric" required="false" default="0" displayname="deleteBeforeSave" hint="I determine whether all values for this object type were deleted prior to the save event."/>

		<cfscript>
			// determines if the object already exists by UUID
			qrySQL = "";
		</cfscript>

		<!--- CHECK FOR THE EXISTENCE OF PRIMARY KEY TO DETERMINE CREATE/UPDATE ACTION --->
		<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
			SELECT [errorID],[applicationName],[componentName],[methodName],[errorType],[errorMessage],[errorDetail],[serverName],[ipAddress],[browser],[httpreferer],[script],[querystring],[template],[errorDate]
					FROM [errorLog]
					WHERE [errorID] = <cfqueryparam value="#arguments.errorLog.geterrorID()#" cfsqltype="cf_sql_varchar">
		</cfquery>
			
		<cfscript>
			// prevent duplicates by a different criteria than simply the UUID
			restrictDuplicatesByCriteria = 0;
			dupeExists = false;
			if ( restrictDuplicatesByCriteria eq 1)
			{
				// write a filter for duplicate values
				filterCriteria = "";
				// test for existing records
				arrDupeObj = readAll(filter=filterCriteria);
				// prevent insert if the record is a duplicate
				if (ArrayLen(arrDupeObj) gt 0)
				{
					dupeExists = true;
				}
			}
			
			// Test if the objects were deleted prior to being saved.  This would be helpful
			// when this object contains relationships to a master object that uses this object to store sub values.
			if (qrySQL.recordcount EQ 0 AND arguments.deleteBeforeSave eq 1)
			{
				// only need to perform a create statement, since the object was deleted before new objects are inserted
				Create(arguments.errorLog);
			}else{
				if(qrySQL.recordcount EQ 0){
					Create(arguments.errorLog);
				}
				else{
					Update(arguments.errorLog);
				}
			}
		</cfscript>
	</cffunction>

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeCreate --->
		<!--- 
		***********************
		**  CREATE
		***********************
		--->
		<cffunction name="create" access="public" returntype="void" output="false" displayname="CRUD: Create" hint="I create a new database record for the specified errorLog.">
			<cfargument name="errorLog" type="any" required="true" displayname="errorLog" hint="I am the errorLog for which to create a new record."/>
			
			<cfscript>
				qrySQL = "";
				
				// event result object
				eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");
				
				errorLog = arguments.errorLog;
				
				// SET THE PRIMARY KEY FOR INSERT - ONLY CREATE ONE IF ONE DOES NOT EXIST
				// THIS IS NECESSARY SINCE CASCADING SUB OBJECTS, MAY HAVE ALREADY HAD THEIR
				// PARENT ID SET
				if ( len(errorLog.geterrorID()) )
				{
					errorID = errorLog.geterrorID();
				}else{
					errorID = CreateUUID();
					errorLog.seterrorID(errorID);
				}
				
				// Insert Object Properties
				if (variables.instance.useObjectProperties eq 1)
				{
					errorLog.setObjectPropertiesObjectID();
					errorLog.setObjectPropertiesObjectType();
					// Insert the objects
					service = APPLICATION.availability.objectFactory.getObjectByName("ObjectProperties","service","");
					eventResult = service.save(errorLog);
				}
				
				
			</cfscript>
			
			<cftry>
				<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
					INSERT INTO [errorLog]([errorID],[errorMessage],[httpreferer],[template],[browser],[applicationName],[errorDetail],[ipAddress],[errorDate],[methodName],[componentName],[errorType],[serverName],[script],[querystring])
					VALUES(
					<cfqueryparam value="#arguments.errorLog.geterrorID()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.geterrorID())#" >
					,<cfqueryparam value="#arguments.errorLog.geterrorMessage()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.geterrorMessage())#" >
					,<cfqueryparam value="#arguments.errorLog.gethttpreferer()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.gethttpreferer())#" >
					,<cfqueryparam value="#arguments.errorLog.gettemplate()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.gettemplate())#" >
					,<cfqueryparam value="#arguments.errorLog.getbrowser()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getbrowser())#" >
					,<cfqueryparam value="#arguments.errorLog.getapplicationName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getapplicationName())#" >
					,<cfqueryparam value="#arguments.errorLog.geterrorDetail()#" cfsqltype="cf_sql_longvarchar" null="#checkNull('string',arguments.errorLog.geterrorDetail())#" >
					,<cfqueryparam value="#arguments.errorLog.getipAddress()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getipAddress())#" >
					,<cfqueryparam value="#arguments.errorLog.geterrorDate()#" cfsqltype="cf_sql_timestamp" null="#checkNull('date',arguments.errorLog.geterrorDate())#" >
					,<cfqueryparam value="#arguments.errorLog.getmethodName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getmethodName())#" >
					,<cfqueryparam value="#arguments.errorLog.getcomponentName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getcomponentName())#" >
					,<cfqueryparam value="#arguments.errorLog.geterrorType()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.geterrorType())#" >
					,<cfqueryparam value="#arguments.errorLog.getserverName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getserverName())#" >
					,<cfqueryparam value="#arguments.errorLog.getscript()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getscript())#" >
					,<cfqueryparam value="#arguments.errorLog.getquerystring()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getquerystring())#" >
					)
				</cfquery>
			
				<cfcatch>
					<!--- 
					cftransaction commit added in case this method is called from within a <cftransaction>.  
					It allows a second dsn (error dsn) to be called within same transaction 
					DO NOT REMOVE
					--->
					<cftransaction action="commit"/>

					<cfscript>
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
										   methodName="create",
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
							eventResult.setSuccess(false);
							eventResult.setErrorMessage("Error saving errorLog. Please contact the system administrator for assistance.");	
						}
					</cfscript>
					<cfthrow detail="#cfcatch.detail#" extendedinfo="#cfcatch#" message="error: create failed (Error Log ID: #variables.errorID#) - #cfcatch.Message#">
				</cfcatch>
			</cftry>

			
		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeRead --->
		<!--- 
		***********************
		**  READ
		***********************
		--->
		<cffunction name="read" access="public" returntype="any" output="false" displayname="CRUD: Read" hint="I read the specified database record into the specified errorLog.<br />Throws: errorLog.MISSING if the specified errorLog cannot be found.">
			<cfargument name="errorID" type="string" required="yes">
			
			<cfscript>
				qrySQL = "";
			</cfscript>
	
			<cftry>
				<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
					SELECT [errorID],[applicationName],[componentName],[methodName],[errorType],[errorMessage],[errorDetail],[serverName],[ipAddress],[browser],[httpreferer],[script],[querystring],[template],[errorDate]
					FROM [errorLog]
					WHERE [errorID] = <cfqueryparam value="#arguments.errorID#" cfsqltype="cf_sql_varchar">
				</cfquery>
			
				<cfcatch>
					<!--- 
					cftransaction commit added in case this method is called from within a <cftransaction>.  
					It allows a second dsn (error dsn) to be called within same transaction 
					DO NOT REMOVE
					--->
					<cftransaction action="commit"/>

					<cfscript>
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
										   methodName="read",
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
							eventResult.setSuccess(false);
							eventResult.setErrorMessage("Error saving errorLog. Please contact the system administrator for assistance.");	
						}
					</cfscript>
					<cfthrow detail="#cfcatch.detail#" extendedinfo="#cfcatch#" message="error: read failed (Error Log ID: #variables.errorID#) - #cfcatch.Message#">
				</cfcatch>
			</cftry>

				
			<cfscript>
				transferObject = getTransferObject(qrySQL);
				returnBean = loadBean(transferObject);
				return returnBean;
			</cfscript>		
		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeReadAll --->
		<!--- 
		***********************
		**  READ ALL
		***********************
		--->
		<cffunction name="readAll" access="public" returnType="array" output="FALSE" hint="retrieves an array of objects from errorLog table">
			<cfargument name="topx" type="numeric" required="no" default="0">
			<cfargument name="sortBy" type="string" required="no" default="">
			<cfargument name="sortType" type="string" required="no" default="ASC">
			<cfargument name="filter" type="string" required="no" default="">
			<cfargument name="strRecords" type="struct" required="no">

			<cfscript>
				var qrySQL = "";
				stResults = StructNew();
				x = 0;
				field = "";
				arrAllRecords = ArrayNew(1);
				
				// strRecords contains props for variables.instance.mainObjectPrimaryKeyFieldName and idList(list of id values for records to query)
				if (isDefined('arguments.strRecords'))
				{
					primaryKeyField = arguments.strRecords.primaryKeyField;
					idList = ListQualify(arguments.strRecords.idList,"'",",");
				}
			</cfscript>
			
			<cftry>
				<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
					SELECT <cfif arguments.topx>TOP #arguments.topx# </cfif>[errorID],[applicationName],[componentName],[methodName],[errorType],[errorMessage],[errorDetail],[serverName],[ipAddress],[browser],[httpreferer],[script],[querystring],[template],[errorDate]
					FROM [errorLog]
					WHERE 1 = 1
					<cfif len(arguments.filter)>
					AND #PreserveSingleQuotes(arguments.filter)#
					</cfif>
					
					<cfif isDefined('arguments.strRecords')>
					  AND #primaryKeyField# IN (#idList#)
					</cfif>
					
					<cfif len(arguments.sortBy)>ORDER BY #arguments.sortBy# #arguments.sortType#</cfif>
				</cfquery>
			
				<cfcatch>
					<!--- 
					cftransaction commit added in case this method is called from within a <cftransaction>.  
					It allows a second dsn (error dsn) to be called within same transaction 
					DO NOT REMOVE
					--->
					<cftransaction action="commit"/>

					<cfscript>
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
										   methodName="getRecordSet",
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
							eventResult.setSuccess(false);
							eventResult.setErrorMessage("Error saving errorLog. Please contact the system administrator for assistance.");	
						}
					</cfscript>
					<cfthrow detail="#cfcatch.detail#" extendedinfo="#cfcatch#" message="error: getRecordSet failed (Error Log ID: #variables.errorID#) - #cfcatch.Message#">
				</cfcatch>
			</cftry>

			
			<cfif qrySQL.recordcount gt 0>
						<cfloop query="qrySQL">
							<cfscript>
								//loop over column list to get each field name and evaluate it into a structure key/value
								for(x=1; x LTE listlen(qrySQL.columnList); x=x+1){
									field = listgetat(qrySQL.columnList,x);
									stResults[field] = qrySQL['#field#'][qrySQL.CURRENTROW];
								}
								// translate the structure to a bean
								bean = loadBean(stResults);
								// set the bean into the array of all records
								arrAllRecords[qrySQL.CURRENTROW] = bean;
							</cfscript>
						</cfloop>
						
			</cfif>

			<cfreturn arrAllRecords>
		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeUpdate --->
		<!--- 
		***********************
		**  UPDATE
		***********************
		--->
		<cffunction name="update" access="public" returntype="void" output="false" displayname="CRUD: Update" hint="I update the database from the specified errorLog." >
			<cfargument name="errorLog" type="any" required="true" displayname="errorLog" hint="I am the errorLog whose record should be updated." />
			
			<cfscript>
				qrySQL = "";

				// event result object
				eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");

				errorLog = arguments.errorLog;
				
				// IN CASE NECESSARY, SET THE PRIMARY KEY FOR ANY CASCADE UPDATES
				errorID = errorLog.geterrorID();
				
				// Object Properties
				if (variables.instance.useObjectProperties eq 1)
				{				
					errorLog.setObjectPropertiesObjectID();
					errorLog.setObjectPropertiesObjectType();
					service = APPLICATION.availability.objectFactory.getObjectByName("ObjectProperties","service","");
					eventResult = service.save(errorLog);
				}				
				
				
			</cfscript>
			
			<cftry>
				<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
					UPDATE [errorLog] SET
					[errorID] = <cfqueryparam value="#arguments.errorLog.geterrorID()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.geterrorID())#" >
					,[errorMessage] = <cfqueryparam value="#arguments.errorLog.geterrorMessage()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.geterrorMessage())#" >
					,[httpreferer] = <cfqueryparam value="#arguments.errorLog.gethttpreferer()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.gethttpreferer())#" >
					,[template] = <cfqueryparam value="#arguments.errorLog.gettemplate()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.gettemplate())#" >
					,[browser] = <cfqueryparam value="#arguments.errorLog.getbrowser()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getbrowser())#" >
					,[applicationName] = <cfqueryparam value="#arguments.errorLog.getapplicationName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getapplicationName())#" >
					,[errorDetail] = <cfqueryparam value="#arguments.errorLog.geterrorDetail()#" cfsqltype="cf_sql_longvarchar" null="#checkNull('string',arguments.errorLog.geterrorDetail())#" >
					,[ipAddress] = <cfqueryparam value="#arguments.errorLog.getipAddress()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getipAddress())#" >
					,[errorDate] = <cfqueryparam value="#arguments.errorLog.geterrorDate()#" cfsqltype="cf_sql_timestamp" null="#checkNull('date',arguments.errorLog.geterrorDate())#" >
					,[methodName] = <cfqueryparam value="#arguments.errorLog.getmethodName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getmethodName())#" >
					,[componentName] = <cfqueryparam value="#arguments.errorLog.getcomponentName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getcomponentName())#" >
					,[errorType] = <cfqueryparam value="#arguments.errorLog.geterrorType()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.geterrorType())#" >
					,[serverName] = <cfqueryparam value="#arguments.errorLog.getserverName()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getserverName())#" >
					,[script] = <cfqueryparam value="#arguments.errorLog.getscript()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getscript())#" >
					,[querystring] = <cfqueryparam value="#arguments.errorLog.getquerystring()#" cfsqltype="cf_sql_varchar" null="#checkNull('string',arguments.errorLog.getquerystring())#" >
					WHERE [errorID] = <cfqueryparam value="#arguments.errorLog.geterrorID()#" cfsqltype="cf_sql_varchar">
				</cfquery>
			
				<cfcatch>
					<!--- 
					cftransaction commit added in case this method is called from within a <cftransaction>.  
					It allows a second dsn (error dsn) to be called within same transaction 
					DO NOT REMOVE
					--->
					<cftransaction action="commit"/>

					<cfscript>
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
										   methodName="update",
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
							eventResult.setSuccess(false);
							eventResult.setErrorMessage("Error saving errorLog. Please contact the system administrator for assistance.");	
						}
					</cfscript>
					<cfthrow detail="#cfcatch.detail#" extendedinfo="#cfcatch#" message="error: update failed (Error Log ID: #variables.errorID#) - #cfcatch.Message#">
				</cfcatch>
			</cftry>

		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeDelete --->
		<!--- 
		***********************
		**  DELETE
		***********************
		--->
		<cffunction name="delete" access="public" returntype="void" output="false" displayname="CRUD: Delete" hint="I delete the specified errorLog from the database.">
			<cfargument name="errorLog" type="any" required="true" displayname="errorLog" hint="I am the errorLog whose record should be deleted." />
	
			<cfscript>
				qrySQL = "";
				// event result object
				eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");
				
				errorLog = arguments.errorLog;
				
				// SET THE PRIMARY KEY FOR ANY CASCADE DELETES
				errorID = errorLog.geterrorID();
			
				// Object Properties
				if (variables.instance.useObjectProperties eq 1)
				{
					if (eventResult.getSuccess() eq true)
					{
						errorLog.setObjectPropertiesObjectID();
						service = APPLICATION.availability.objectFactory.getObjectByName("ObjectProperties","service","");
						eventResult = service.delete(errorLog);						
					}
				}			
			
			</cfscript>
				
			<cftry>
				<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
					DELETE FROM [errorLog]
					WHERE [errorID] = <cfqueryparam value="#arguments.errorLog.geterrorID()#" cfsqltype="cf_sql_varchar">
				</cfquery>
			
				<cfcatch>
					<!--- 
					cftransaction commit added in case this method is called from within a <cftransaction>.  
					It allows a second dsn (error dsn) to be called within same transaction 
					DO NOT REMOVE
					--->
					<cftransaction action="commit"/>

					<cfscript>
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
							eventResult.setSuccess(false);
							eventResult.setErrorMessage("Error saving errorLog. Please contact the system administrator for assistance.");	
						}
					</cfscript>
					<cfthrow detail="#cfcatch.detail#" extendedinfo="#cfcatch#" message="error: delete failed (Error Log ID: #variables.errorID#) - #cfcatch.Message#">
				</cfcatch>
			</cftry>

		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeDeleteByID --->
		<!--- 
		***********************
		**  DELETE BY ID
		***********************
		--->
		<cffunction name="deleteByID" access="public" returntype="void" output="false" displayname="CRUD: DeleteByID" hint="I delete the specified errorLogs from the database By Master Object ID.">
			<cfargument name="id" type="string" required="true" displayname="Master Object ID" hint="I am the Master Object ID for records that should be deleted." />
	
			<cfscript>
				qrySQL = "";
				// event result object
				eventResult = APPLICATION.availability.objectFactory.getObjectByName("EventResult","bean","event");
				
				// the primary key id to use for the delete
				id = arguments.id;
			
				// Object Properties
				if (variables.instance.useObjectProperties eq 1)
				{
					if (eventResult.getSuccess() eq true)
					{
						// Delete all the object properties
						service = APPLICATION.availability.objectFactory.getObjectByName("ObjectProperties","service","");
						eventResult = service.deleteByID(id);
					}
				}			
			
			</cfscript>
				
			<cftry>
				<cfquery name="qrySQL" datasource="#variables.instance.dsn#" username="#variables.instance.dbUser#" password="#variables.instance.dbPassword#">
					DELETE FROM [errorLog]
					WHERE errorID = '#id#'
				</cfquery>
			
				<cfcatch>
					<!--- 
					cftransaction commit added in case this method is called from within a <cftransaction>.  
					It allows a second dsn (error dsn) to be called within same transaction 
					DO NOT REMOVE
					--->
					<cftransaction action="commit"/>

					<cfscript>
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
							eventResult.setSuccess(false);
							eventResult.setErrorMessage("Error saving errorLog. Please contact the system administrator for assistance.");	
						}
					</cfscript>
					<cfthrow detail="#cfcatch.detail#" extendedinfo="#cfcatch#" message="error: deleteByID failed (Error Log ID: #variables.errorID#) - #cfcatch.Message#">
				</cfcatch>
			</cftry>

		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->


<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeLoadBean --->
	<!--- 
	***********************
	**  LOAD BEAN
	***********************
	--->
	<cffunction name="loadBean" access="private" returnType="any" output="false">
		<cfargument name="transferObject" type="struct" required="yes"/>

		<cfscript>
			//instantiate value object CFC
			oBean = APPLICATION.availability.objectFactory.getObjectByName("errorLog","Bean","error");
			oBean.init(argumentcollection=arguments.transferObject);
			
			// Populate the ObjectProperties for this object
			if (variables.instance.useObjectProperties eq 1)
			{
				// Object Properties
				oBean.populateObjectProperties();
			}
			
			return oBean;
		</cfscript>
	</cffunction>
<!--- END MANAGEDCODE BLOCK --->
	<!--- START MANAGEDCODE BLOCK: cfcPowerTools.components.core.cfcTypes.Sinclair.components.dao:getManagedCodeTransferObject --->
		<!--- 
		***********************
		**  TRANSFER OBJECT
		***********************
		--->
		<cffunction name="getTransferObject" access="private" returnType="struct" output="false">
			<cfargument name="qryRecord" type="query" required="yes">
	
			<cfscript>
				stResults = structnew();
				 x = "";
				field = "";
	
				//loop over column list to get each field name and evaluate it into a structure key/value
				if(arguments.qryRecord.recordcount){
					for(x=1; x LTE listlen(arguments.qryRecord.columnList); x=x+1){
						field = listgetat(arguments.qryRecord.columnList,x);
						stResults[field] = arguments.qryRecord['#field#'][1];
					}
				}
				return stResults;
			</cfscript>
		</cffunction>
	<!--- END MANAGEDCODE BLOCK --->

	<!--- 
	***********************
	**  EXCEPTION CODE
	***********************
	--->
	<cffunction name="throwerrorLogNotFoundException" access="private" returntype="void" output="false">
		<cfthrow message="No such errorLog" type="errorLog.MISSING" />
	</cffunction>

	<!--- 
	checkNull() 
	--->
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
