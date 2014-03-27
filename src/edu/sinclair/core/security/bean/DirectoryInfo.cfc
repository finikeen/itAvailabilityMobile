component persistent="true" datasource="security" table="DirectoryInfo"  schema="dbo" output="false"
{
	/* properties */
	
	property name="directoryID" column="directoryID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="tartanID" column="tartanID" type="numeric" ormtype="int" ; 
	property name="deptID" column="deptID" type="numeric" ormtype="int" ; 
	property name="divID" column="divID" type="numeric" ormtype="int" ; 
	property name="orderID" column="orderID" type="numeric" ormtype="int" ; 
	property name="location" column="location" type="string" ormtype="string" ; 
	property name="title" column="title" type="string" ormtype="string" ; 
	property name="supervisorUserID" column="supervisorUserID" type="string" ormtype="string" ; 
	property name="employmentStatus" column="employmentStatus" type="string" ormtype="string" ; 
	property name="directoryRole" column="directoryRole" type="string" ormtype="string" ; 
	property name="actualPhone" column="actualPhone" type="string" ormtype="string" ; 
	property name="displayPhone" column="displayPhone" type="string" ormtype="string" ; 
	property name="internalPhone" column="internalPhone" type="string" ormtype="string" ; 
	property name="externalPhone" column="externalPhone" type="string" ormtype="string" ; 
	property name="acdPhone" column="acdPhone" type="string" ormtype="string" ; 
	property name="isActive" column="isActive" type="string" ormtype="string" ; 
	property name="isDepartmentHead" column="isDepartmentHead" type="numeric" ormtype="boolean" ; 
	property name="contactHours" column="contactHours" type="string" ormtype="string" ; 
	property name="contactFax" column="contactFax" type="string" ormtype="string" ; 
	property name="preferredPhone" column="preferredPhone" type="numeric" ormtype="boolean" ; 
	property name="showExternal" column="showExternal" type="numeric" ormtype="boolean" ; 
	property name="positionLevel" column="positionLevel" type="string" ormtype="string" ; 
	property name="primaryPos" column="primaryPos" type="numeric" ormtype="boolean" ; 	
} 
