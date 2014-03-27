component persistent="true" datasource="security" table="UserSecurityInfo"  schema="dbo" output="false"
{
	/* properties */
	
	property name="tartanID" column="tartanID" type="numeric" ormtype="int" fieldtype="id"; 
	property name="networkUserID" column="networkUserID" type="string" ormtype="string" ; 
	property name="password" column="password" type="string" ormtype="string" ; 	
} 
