component persistent="true" datasource="security" table="ApplicationTypes"  schema="dbo" output="false"
{
	/* properties */
	
	property name="applicationID" column="applicationID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="applicationName" column="applicationName" type="string" ormtype="string" ; 
	property name="friendlyName" column="friendlyName" type="string" ormtype="string" ; 
	property name="description" column="description" type="string" ormtype="string" ; 
	property name="serverName" column="serverName" type="string" ormtype="string" ; 
	property name="webRoot" column="webRoot" type="string" ormtype="string" ; 
	property name="docRoot" column="docRoot" type="string" ormtype="string" ; 
	property name="isOff" column="isOff" type="numeric" ormtype="boolean" ; 	
} 
