component persistent="true" datasource="security" table="RoleTypes"  schema="dbo" output="false"
{
	/* properties */
	
	property name="roleID" column="roleID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="applicationID" column="applicationID" type="numeric" ormtype="int" ; 
	property name="roleName" column="roleName" type="string" ormtype="string" ; 	
} 
