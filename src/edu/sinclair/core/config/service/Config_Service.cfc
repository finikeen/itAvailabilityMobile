component name="Config_Service"  displayname="Config Service" hint="I am the primary service for Config objects" output="false"
{
	variables.dao = APPLICATION.beanFactory.getBean('configDAO');

	// INIT
	public void function init(){}
	
	// getConfigSettings
	public struct function getConfigSettings(required any data)
	{
		config = StructNew();
		config.dsn = variables.dao.getDSN();
		config.serverRootPath = variables.dao.getApplicationUrl();
		config.publishingDirectory = variables.dao.getPublishingDirectory();
		config.projectDirectory = variables.dao.getProjectDirectory();
		config.projectMapping = variables.dao.getProjectMapping();
		config.componentPath = variables.dao.getComponentsPath();
		config.versionNumber = variables.dao.getVersionNumber();
		config.applicationMapping = variables.dao.getProjectMapping();
		config.aboutText = "Online Admissions Application is the admissions application for #VARIABLES.dao.getApplicationAdministrativeBody()#.";			
		
		return config;
	}	
}