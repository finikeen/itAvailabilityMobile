Component output="false" persistent="false"
{
	property type="string" name="id";
	property type="string" name="label";
	property type="array" name="questions"; // FormQuestionTO

	VARIABLES.id = javaCast( "null", 0 );
	VARIABLES.label = javaCast( "null", 0 );
	VARIABLES.questions = javaCast( "null", 0 );

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
	
	public Array function getQuestions() {
		return VARIABLES.questions;
	}
	
	public void function setQuestions(Array questions) {
		VARIABLES.questions = arguments.questions;
	}	
}