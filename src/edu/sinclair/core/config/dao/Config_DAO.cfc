component displayname="Config"
{
	//where the ini configuration file is located, this assumes it is located
	//in the same directory as the application.cfc, but if you move it to a different directory,
	//for example if you you transferred it to a non-web accessible directory for security, change as needed
	VARIABLES.baseDirectory = getDirectoryFromMapping("availability");
	// VARIABLES.configPath = "C:\OnlineAdmissionsConfig\";
	VARIABLES.configPath = VARIABLES.baseDirectory & "/config/";
	VARIABLES.config = VARIABLES.configPath & "config.ini";
	VARIABLES.section = 'default';
	
	// The ini file for managing versioning and associated SSP properties
	VARIABLES.versionManager = VARIABLES.configPath & "versionManager.ini";	
	
	// returns the securityApplicationName property from the configuration settings 
	// Variable used to determine the application to retrieve from the Security database.
	public string function getSecurityApplicationName()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "securityApplicationName");
	}	
	
	// returns the CFCPackage property from the configuration settings
	public string function getCFCPackage()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "name");
	}	

	// returns the dsn property from the configuration settings
	public string function getDSN()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "dsn");
	}

	// returns the errordsn property from the configuration settings
	public string function getErrorDSN()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "errorDSN");
	}
	
	// returns the securitydsn property from the configuration settings
	public string function getSecurityDSN()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "securityDSN");
	}	
	
	// returns the LDAPServer property from the configuration settings
	public string function getLDAPServer()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "LDAPServer");
	}	

	// returns the LDAPUser property from the configuration settings
	public string function getLDAPUser()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "LDAPUser");
	}

	// returns the LDAPPass property from the configuration settings
	public string function getLDAPPass()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "LDAPPass");
	}

	/* returns the LDAPSubTrees property from the configuration settings 
	* LDAP TREES TO BE SEARCHED FOR SECURITY LOGIN INFORMATION. 
	* USE (|) SYMBOL AS A DELIMITER FOR MULTIPLE TREES IN CONFIG FILE. 
	* WILL CONVERT BACK TO (;) FOR USE IN Security_Service.cfc
	*/
	public string function getLDAPSubTrees()
	{
		return ListChangeDelims(GetProfileString(VARIABLES.config, VARIABLES.section, "LDAPSubTrees"), ";", "|");
	}	

	/* returns the linkedSecurityServerPath property from the configuration settings
	* SECURITY DATABASE SERVER RELATIONSHIP LINK PATH
	*/ 
	public string function getLinkedSecurityServerPath()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "linkedSecurityServerPath");
	}	

	/* * returns the linkedSecurityDBName property from the configuration settings
	* SECURITY DATABASE NAME FOR JOINS
	*/ 
	public string function getLinkedSecurityDBName()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "linkedSecurityDBName");
	}
	
	// Encrypt Seed
	public string function getEncryptSeed()
	{
		return "scc@";
	}	

	// encryptKey
	public string function getEncryptKey()
	{
		return "3E9195BE-306E-11A1-E99F35FC4CD0AB0F";
	}		

	// encryptAlgorithm
	public string function getEncryptAlgorithm()
	{
		return "CFMX_COMPAT";
	}
	
	// cookieDomainName
	public string function getCookieDomainName()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "cookieDomainName");
	}	

	// securityPassHash
	public string function getSecurityPassHash()
	{
		return getEncryptKey();
	}

	// returns the systemGeneratedNotificationFromEmailAddress property from the configuration settings
	// The from email address for system generated notifications.
	public string function getSystemGeneratedNotificationFromEmailAddress()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "systemGeneratedNotificationFromEmailAddress");
	}

	// The directory for included files
	public string function getIncludesRootPath()
	{
		return getApplicationUrl() & "/common/includes";
	}
	
	// returns the systemGeneratedNotificationFromEmailAddress property from the configuration settings
	// The from email address for system generated notifications.
	public string function getVersionNumber()
	{
		return GetProfileString(VARIABLES.versionManager, VARIABLES.section, "VersionNumber");
	}
	
	// returns the logDirectory property from the configuration settings
	public string function getLogDirectory()
	{
		return VARIABLES.configPath & "log";
	}	

	// returns the publishingDirectory property from the configuration settings
	public string function getPublishingDirectory()
	{
		// The directory the site is published into.
		// Also the base directory path for the site.
		propValue = "";
		if (isDefined('VARIABLES.baseDirectory'))
		{
			if (len(VARIABLES.baseDirectory))
			{
				propValue = VARIABLES.baseDirectory;
			}else{
				propValue = GetProfileString(VARIABLES.config, VARIABLES.section, "publishingDirectory");
			}
		}else{
			propValue = GetProfileString(VARIABLES.config, VARIABLES.section, "publishingDirectory");
		}		
			
		return propValue;
	}

	// returns the projectDirectory property from the configuration settings
	// The directory of your Flex project
	public string function getProjectDirectory()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "projectDirectory");
	}

	// returns the projectMapping property from the configuration settings
	// Mapping for the project in the CFAdmin
	public string function getProjectMapping()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "projectMapping");
	}

	// returns the applicationUrl property from the configuration settings
	// Url under which the site is deployed
	public string function getApplicationUrl()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "applicationUrl");
	}	

	// returns the applicationAdministrativeBody property from the configuration settings
	// The name of the administrative organization running the application. Generally, Sinclair Community College.
	public string function getApplicationAdministrativeBody()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "applicationAdministrativeBody");
	}

	// returns the applicationID from the configuration settings
	public string function getApplicationID()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "applicationID");
	}

	// returns the componentsPath property from the configuration settings
	public string function getComponentsPath()
	{
		return GetProfileString(VARIABLES.config, VARIABLES.section, "componentPath");
	}

	// returns the coreComponentsPath property from the configuration settings
	public string function getCoreComponentsPath()
	{
		return getComponentsPath() & "core.";
	}

	// returns the configComponentsPath property from the configuration settings
	public string function getConfigComponentsPath()
	{
		return getCoreComponentsPath() & "config.";
	}

	// returns the errorComponentsPath property from the configuration settings
	public string function getErrorComponentsPath()
	{
		return getCoreComponentsPath() & "error.";
	}

	// returns the eventComponentsPath property from the configuration settings
	public string function getEventComponentsPath()
	{
		return getCoreComponentsPath() & "event.";
	}	
		
	// returns the securityComponentsPath property from the configuration settings
	public string function getSecurityComponentsPath()
	{
		return getCoreComponentsPath() & "security.";
	}

	// Application objects
	public string function getApplicationORMComponentsPath()
	{
		return getComponentsPath() & "availability.";
	}

	// returns the utilsComponentsPath property from the configuration settings
	public string function getUtilsComponentsPath()
	{
		return getCoreComponentsPath() & "util.";
	}
 
	/****************************
	**  getDirectoryFromMapping()
	**  Use: Use this method to return
	**  the base install directory from
	**  a mapping name for the root directory.
	****************************/
	public string function getDirectoryFromMapping(required string mapping)
	{
		var runtime = "";
		var map = "";
		var result = "";
				
		// Get mapping object from JAVA
		factory = CreateObject("Java","coldfusion.server.ServiceFactory");
		runtime = factory.getRuntimeService();
		try{
			// Search for mapping value in structure
			result = StructFind(runtime.getMappings(),"/#arguments.mapping#");
		}	
		catch (any e) {
			result = "No such mapping defined in the system....";
		}
		
		return result;
	}
		
}