Component output="false" persistent="false"
{
	property type="string" name="id";
	property type="string" name="label";
	property type="string" name="type";
	property type="numeric" name="readOnly";
	property type="numeric" name="required";
	property type="string" name="value";
	property type="array" name="values"; // String
	property type="string" name="maximumLength";
	property type="array" name="options"; // FormOptionTO
	property type="string" name="validationExpression";
	property type="string" name="visibilityExpression";
	property type="string" name="availabilityExpression";
	
	VARIABLES.id = javaCast( "null", 0 );
	VARIABLES.label = javaCast( "null", 0 );
	VARIABLES.type = javaCast( "null", 0 );
	VARIABLES.readOnly = javaCast( "null", 0 );
	VARIABLES.required = javaCast( "null", 0 );
	VARIABLES.value = javaCast( "null", 0 );
	VARIABLES.values = javaCast( "null", 0 );
	VARIABLES.maximumLength = javaCast( "null", 0 );
	VARIABLES.options = javaCast( "null", 0 );
	VARIABLES.validationExpression = javaCast( "null", 0 );
	VARIABLES.visibilityExpression = javaCast( "null", 0 );
	VARIABLES.availabilityExpression = javaCast( "null", 0 );
	
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
	public String function getType() {
		return VARIABLES.type;
	}
	public void function setType(String type) {
		VARIABLES.type = arguments.type;
	}
	public numeric function isReadOnly() {
		return VARIABLES.readOnly;
	}
	public void function setReadOnly(numeric readOnly) {
		VARIABLES.readOnly = arguments.readOnly;
	}
	public numeric function isRequired() {
		return VARIABLES.required;
	}
	public void function setRequired(numeric value) {
		VARIABLES.required = arguments.value;
	}
	public String function getValue() {
		return VARIABLES.value;
	}
	public void function setValue(String value) {
		VARIABLES.value = arguments.value;
	}
	public Array function getValues() {
		return VARIABLES.values;
	}
	public void function setValues(Array values) {
		VARIABLES.values = arguments.values;
	}
	public String function getMaximumLength() {
		return VARIABLES.maximumLength;
	}
	public void function setMaximumLength(String maximumLength) {
		VARIABLES.maximumLength = arguments.maximumLength;
	}
	public Array function getOptions() {
		return VARIABLES.options;
	}
	public void function setOptions(Array options) {
		VARIABLES.options = arguments.options;
	}
	public String function getValidationExpression() {
		return VARIABLES.validationExpression;
	}
	public void function setValidationExpression(String validationExpression) {
		VARIABLES.validationExpression = arguments.validationExpression;
	}
	public String function getVisibilityExpression() {
		return VARIABLES.visibilityExpression;
	}
	public void function setVisibilityExpression(String visibilityExpression) {
		VARIABLES.visibilityExpression = arguments.visibilityExpression;
	}
	public String function getAvailabilityExpression() {
		return VARIABLES.availabilityExpression;
	}
	public void function setAvailabilityExpression(String availabilityExpression) {
		VARIABLES.availabilityExpression = arguments.availabilityExpression;
	}
}