component persistent="true" datasource="security" table="DirectoryRoles"  schema="dbo" output="false"
{
	/* properties */
	
	property name="roleID" column="roleID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="roleName" column="roleName" type="string" ormtype="string" ; 	
} 
