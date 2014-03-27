component persistent="true" datasource="security" table="AccessTypes"  schema="dbo" output="false"
{
	/* properties */
	
	property name="accessTypeID" column="accessTypeID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="applicationID" column="applicationID" type="numeric" ormtype="int" ; 
	property name="accessType" column="accessType" type="string" ormtype="string" ; 	
} 
