component persistent="true" datasource="security" table="Divs"  schema="dbo" output="false"
{
	/* properties */
	
	property name="DivID" column="DivID" type="numeric" ormtype="int" fieldtype="id" ; 
	property name="Division" column="Division" type="string" ormtype="string" ; 
	property name="DivAbbr" column="DivAbbr" type="string" ormtype="string" ; 
	property name="colleagueID" column="colleagueID" type="numeric" ormtype="int" ; 	
} 
