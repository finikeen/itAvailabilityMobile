component displayname="Security_VerifyLoginCookiesCollectionsAPI" extends="availability.api.1.resources.AbstractRestAPI" taffy_uri="/verifyLoginCookies"
{
	variables.service = Application.security.objectFactory.getObjectByName("security", "service", "security");
	variables.dao = Application.security.objectFactory.getObjectByName("config", "dao", "config");

	public any function post(required string username, string password="", string dsn="")
	{
		var security = variables.service;
		var config = variables.dao;
		var appDSN = arguments.dsn;
		if (appDSN eq "") {
			appDSN = config.getDSN();
		}
		if(appDSN eq "") {
			appDSN = config.getDSN();
		}
		
		result = security.verifyLoginCookies(arguments.username, arguments.password, appDSN);
	
		return representationOf(result).withStatus(200);
	}
	
}