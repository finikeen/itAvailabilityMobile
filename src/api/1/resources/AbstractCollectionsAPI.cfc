component displayname="AbstractCollectionsAPI" extends="AbstractRestAPI"
{	
	public struct function translatePagingResults( required array records )
	{
		var result = StructNew();
		result["results"] = 0;
		result["rows"] = ArrayNew(1);
		result["success"] = true;
		if ( ArrayLen(records) gt 0 )
		{
			result["rows"] = records;
        	result["results"] = records[1].totalRecords;			
		}
		return result;
	}
	
    public any function getAllPaged( required string apiFilterSettings, required any service)
    {
        var result = "";
        var records = "";
        var filter = APPLICATION.availability.objectFactory.getObjectByName("FilterCollection","bean","event");
        filter.translateApiFilterSettings( arguments.apiFilterSettings );
        records = variables.dataTypeUtil.formatApiRecords( service.getPaged( filter ) );
        result = translatePagingResults( records );
        return result;
    }
    
   // Accepts arguments for:
    //    service to use when searching
    //    filterExpressions - json array of expression objects [{"columnName":"name","filterOperation":"equals","expression":"My downtime"}]
    public any function search( required array filterExpressions, required any service )
    {   
        var filter = APPLICATION.onlineadmissions.objectFactory.getObjectByName("FilterCollection","bean","event");
        var pageIndex = 0;
        var pageSize = 100;
        var result = "";
        var records = 0;
        var data = StructNew();
        var expressionCount = ArrayLen(arguments.filterExpressions);
        if ( expressionCount gt 0)
        {
                filter.setPageIndex( pageIndex );
                filter.setPageSize( pageSize );
                for (i=1; i lte expressionCount; i=i+1)
                {
                     filter.addFilterExpression( arguments.filterExpressions[i] );
                }
                data.filterCollection = filter;
                records = variables.dataTypeUtil.formatApiRecords( arguments.service.getAll( data ) );
                result = translatePagingResults( records );
        }
        return result;
    }
    
	
	public any function encryptDecrypt(required string password, string direction="encrypt")
	{
		var result = '';
		var encryptSeed = APPLICATION.encryptSeed & APPLICATION.encryptKey;
		var encryptAlgorithm = APPLICATION.encryptAlgorithm;
		
		if (arguments.direction eq "encrypt") {
			result = encrypt(arguments.password, encryptSeed, encryptAlgorithm);
		} else {
			result = decrypt(arguments.password, encryptSeed, encryptAlgorithm);
		}
		
		return result;
	}
}