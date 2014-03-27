component persistent="true" datasource="security" table="UserInfo"  schema="dbo" output="false"
{
	/* properties */
	
	property name="tartanID" column="tartanID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="networkUserID" column="networkUserID" type="string" ormtype="string" ; 
	property name="ssn" column="ssn" type="string" ormtype="string" ; 
	property name="fullName" column="fullName" type="string" ormtype="string" ; 
	property name="biographyInfo" column="biographyInfo" type="string" ormtype="string" ; 
	property name="personalLink" column="personalLink" type="string" ormtype="string" ; 
	property name="personalImage" column="personalImage" type="string" ormtype="string" ; 
	property name="isActive" column="isActive" type="string" ormtype="string" ; 
	property name="personalImageAltText" column="personalImageAltText" type="string" ormtype="string" ; 
	property name="personalImageView" column="personalImageView" type="string" ormtype="string" ; 
	property name="objectID" column="objectID" type="string" ormtype="string" ; 
	property name="defaultURL" column="defaultURL" type="string" ormtype="string" ; 
	property name="credentials" column="credentials" type="string" ormtype="string" ; 
	property name="useEktron" column="useEktron" type="string" ormtype="string" ; 
	property name="isAdmin" column="isAdmin" type="numeric" ormtype="boolean" ; 
	property name="email" column="email" type="string" ormtype="string" ; 
	property name="lastModified" column="lastModified" type="date" ormtype="timestamp" ; 
	property name="isOverride" column="isOverride" type="numeric" ormtype="boolean" ; 
	property name="ourTutorial" column="ourTutorial" type="numeric" ormtype="boolean" ; 	
} 
