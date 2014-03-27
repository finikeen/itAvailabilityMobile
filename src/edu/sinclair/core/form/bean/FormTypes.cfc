component output="false" persistent="false"
{
	// Form Types
	property type="string" name="FORM_TYPE_AGREEMENT";
	property type="string" name="FORM_TYPE_CHECKLIST";
	property type="string" name="FORM_TYPE_LABEL";
	property type="string" name="FORM_TYPE_RADIOLIST";
	property type="string" name="FORM_TYPE_SELECT";
	property type="string" name="FORM_TYPE_TEXTAREA";
	property type="string" name="FORM_TYPE_TEXTINPUT";

	VARIABLES.FORM_TYPE_AGREEMENT = "agreement";
	VARIABLES.FORM_TYPE_CHECKLIST = "checklist";
	VARIABLES.FORM_TYPE_LABEL = "label";
	VARIABLES.FORM_TYPE_RADIOLIST = "radiolist";
	VARIABLES.FORM_TYPE_SELECT = "select";
	VARIABLES.FORM_TYPE_TEXTAREA = "textarea";
	VARIABLES.FORM_TYPE_TEXTINPUT = "textinput";
     	
	public string function getFormTypeAgreement()
	{
		return VARIABLES.FORM_TYPE_AGREEMENT;
	}

	public string function getFormTypeChecklist()
	{
		return VARIABLES.FORM_TYPE_CHECKLIST;
	}	

	public string function getFormTypeLabel()
	{
		return VARIABLES.FORM_TYPE_LABEL;
	}
	
	public string function getFormTypeRadioList()
	{
		return VARIABLES.FORM_TYPE_RADIOLIST;
	}

	public string function getFormTypeSelect()
	{
		return VARIABLES.FORM_TYPE_SELECT;
	}	
	
	public string function getFormTypeTextArea()
	{
		return VARIABLES.FORM_TYPE_TEXTAREA;
	}
	
	public string function getFormTypeTextInput()
	{
		return VARIABLES.FORM_TYPE_TEXTINPUT;
	}
	
}