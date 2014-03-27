component persistent="true" datasource="security" table="Departments"  schema="dbo" output="false"
{
	/* properties */
	
	property name="departmentID" column="departmentID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="departmentName" column="departmentName" type="string" ormtype="string" ; 
	property name="parentID" column="parentID" type="string" ormtype="string" ; 
	property name="departmentEmail" column="departmentEmail" type="string" ormtype="string" ; 
	property name="departmentPhone" column="departmentPhone" type="string" ormtype="string" ; 
	property name="departmentFax" column="departmentFax" type="string" ormtype="string" ; 
	property name="departmentLocation" column="departmentLocation" type="string" ormtype="string" ; 
	property name="isActive" column="isActive" type="string" ormtype="string" ; 
	property name="departmentAbbr" column="departmentAbbr" type="string" ormtype="string" ; 
	property name="colleagueID" column="colleagueID" type="numeric" ormtype="int" ; 	
} 
