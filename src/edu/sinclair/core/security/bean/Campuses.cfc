component persistent="true" datasource="security" table="Campuses"  schema="dbo" output="false"
{
	/* properties */
	
	property name="campusID" column="campusID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="campusName" column="campusName" type="string" ormtype="string" ; 
	property name="isActive" column="isActive" type="string" ormtype="string" ; 	
} 
