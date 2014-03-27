component persistent="true" table="Schedule"  schema="dbo" output="false" extends="AbstractEntity"
{
	/* properties */
	
	property name="id" column="id" type="string" ormtype="string" fieldtype="id" ; 
	property name="tartanId" column="tartanId" type="numeric" ormtype="int" ; 
	property name="orderId" column="orderId" type="numeric" ormtype="int" ; 
	property name="startTime" column="startTime" type="string" ormtype="string" ; 
	property name="endTime" column="endTime" type="string" ormtype="string" ; 	
} 
