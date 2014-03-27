component displayname="Security_LoginCollectionsAPI" extends="availability.api.1.resources.AbstractRestAPI" taffy_uri="/login"
{	
	variables.service = Application.security.objectFactory.getObjectByName("security","service","security");
	variables.dao = Application.security.objectFactory.getObjectByName("config","dao","config");
	    
	public any function post(required any username, required any password, string dsn = "")
	{
		var security = variables.service;
		var config = variables.dao;
		var data = StructNew();
		var appDSN = arguments.dsn;
		data.username = arguments.username;
		data.password = arguments.password;
		if (appDSN eq "") {
			appDSN = config.getDSN();
		}
		if (appDSN eq "")
		{
			result = "No DSN available. Please see the System Administrator to resolve.";
		}else{
			data.dsn = appDSN;
			result = security.verifyLoginDSN( data.username, data.password, appDSN );
			senderror(data,appdsn,'wtf');
		}
			      
        return representationOf( result ).withStatus(200);
	}
}