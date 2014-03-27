component persistent="true" table="OutOfOffice" schema="dbo" output="false" extends="AbstractEntity"
{
	/* properties */
	property name="id" column="id" type="string" ormtype="string" fieldtype="id";
	property name="tartanId" column="tartanId" type="numeric" ormtype="int";
	property name="isAllDay" column="isAllDay" type="numeric" ormtype="boolean";
	property name="startTime" column="startTime";
	property name="endTime" column="endTime";
	property name="eventType" column="eventType" type="string" ormtype="string";
	property name="display" column="display" type="numeric" ormtype="boolean";
	property name="fullName" column="fullname" type="string" ormtype="string";
}