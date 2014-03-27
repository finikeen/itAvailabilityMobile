component output="false" persistent="false"
{
	property type="string" name="id";
	property type="string" name="label";
	property type="string" name="value";
	
	VARIABLES.id = javaCast( "null", 0 );
	VARIABLES.label = javaCast( "null", 0 );
	VARIABLES.value = javaCast( "null", 0 );
	
	public void function populate(string id, string label, string value)
	{
		variables.id = arguments.id;
		variables.label = arguments.label;
		variables.value = arguments.value;
	}
	
 	public struct function getMemento() {
		var i = "";
		var md = getMetaData( this );
		var instance = {};
		for( i=1;i <= arrayLen( md.properties ); i++ ){
			if( structKeyExists( variables,md.properties[i]["name"] ) )
				instance[md.properties[i]["name"]] = variables[md.properties[i]["name"]];
			else
				instance[md.properties[i]["name"]] = javaCast( "null", 0 );
		}
		return instance;
	}
		
	public String function getId() {
		return VARIABLES.id;
	}
	public void function setId(String id) {
		VARIABLES.id = arguments.id;
	}
	public String function getLabel() {
		return VARIABLES.label;
	}
	public void function setLabel(String label) {
		VARIABLES.label = arguments.label;
	}
	public String function getValue() {
		return VARIABLES.value;
	}
	public void function setValue(String value) {
		VARIABLES.value = arguments.value;
	}
}