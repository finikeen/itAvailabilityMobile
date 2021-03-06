component displayname="ApplicationTypesCollectionsAPI" extends="availability.api.1.resources.AbstractCollectionsAPI" taffy_uri="/ApplicationTypes/"
{	
	variables.service = Application.security.objectFactory.getObjectByName("ApplicationTypes","service","security");
    variables.entityName = "ApplicationTypes";
    
	public any function get( string page = "", string limit = "" )
	{	
		var pageIndex = 0;
		var pageSize = 0;
		var apiFilterSettings = "";
		var result = "";
		if (arguments.page != "" && arguments.limit != "")
        {
        		pageIndex = arguments.page-1;
        		pageSize = arguments.limit;
        		apiFilterSettings = pageIndex & "@" & pageSize;
        		result = getAllPaged( apiFilterSettings, variables.service );	
        }else{
        	result = variables.dataTypeUtil.formatApiRecords( variables.service.getAll(StructNew()) );
        }
        
		return representationOf( result ).withStatus(200);
	}
	
	public any function post()
	{
		var struct = deserializeJson( serializeJson( arguments ) );
		var bean = EntityNew(variables.entityName, struct);
		bean.init();
		result = variables.service.save( bean );      
        return representationOf( deserializeJson( serializeJson( bean ) ) ).withStatus(200);
	}
}
