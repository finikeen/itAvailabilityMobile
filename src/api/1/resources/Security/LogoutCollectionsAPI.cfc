component displayname="Security_LoginCollectionsAPI" extends="availability.api.1.resources.AbstractRestAPI" taffy_uri="/logout"
{	
	variables.service = Application.security.objectFactory.getObjectByName("security","service","security");
	    
	public any function get()
	{
		result = variables.service.doLogout();
			      
        return representationOf( result ).withStatus(200);
	}
}