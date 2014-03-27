component persistent="true" datasource="security" table="ApplicationControl"  schema="dbo" output="false"
{
	/* properties */
	
	property name="applicationID" column="applicationID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="tartanID" column="tartanID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="isActive" column="isActive" type="numeric" ormtype="boolean" ; 	
} 
