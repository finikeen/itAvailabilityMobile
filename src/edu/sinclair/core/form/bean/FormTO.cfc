Component output="false" persistent="false"
{
	property type="string" name="id";
	property type="string" name="label";
	property type="array" name="sections"; // FormSectionTO

	VARIABLES.id = "";
	VARIABLES.label = "";
	VARIABLES.sections = ArrayNew(1);

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

	public Array function getSections() {
		return VARIABLES.sections;
	}

	public void function setSections(required Array sections) {
		VARIABLES.sections = arguments.sections;
	}
}	