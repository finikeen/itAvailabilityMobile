import availability.edu.sinclair.core.form.bean.FormOptionTO;
import availability.edu.sinclair.core.form.bean.FormQuestionTO;
import availability.edu.sinclair.core.form.bean.FormSectionTO;
import availability.edu.sinclair.core.form.bean.FormTO;

Component 
{
	public String function createNewID()
	{
		newID = insert('-', createUUID(), 23);
		return newID;
	}

	public Array function buildFormOptions(array values)
	{
		var questionOptions = ArrayNew(1);
		for (var i=1; i lte ArrayLen(values); i=i+1)
		{
			option = new FormOptionTO();
			option.populate(createNewID(), values[i].value, values[i].label);
			ArrayAppend(questionOptions, option.getMemento() );
		}		
		
		return questionOptions;
	}
	
	public FormSectionTO function getFormSectionById(String formSectionId, any formTO) 
	{
		var result = "";
		var aSections = arguments.formTO.getSections();
		for (x=1; x lte ArrayLen(aSections); x=x+1)
		{
			var formSectionTO = aSections[x];
			if (UCase(formSectionTO.getId()) eq UCase(arguments.formSectionId))
			{
				result = formSectionTO;
			}
		}
		
		return result;
	}
	
	public FormQuestionTO function getFormQuestionById(String formQuestionId, any formSectionTO)
	{
		var result = "";
		var aQuestions = arguments.formSectionTO.getQuestions();
		for (x=1; x lte ArrayLen(aQuestions); x=x+1)	
		{
			var formQuestionTO = aQuestions[x];
			if (UCase(formQuestionTO.getId()) eq UCase(arguments.formQuestionId))
			{
				result = formQuestionTO;
			}
		}

		return result;
	}
	
	public FormOptionTO function getFormOptionById(String formOptionId, any formQuestionTO) 
	{
		var result = "";
		var aOptions = arguments.formQuestionTO.getOptions();
		for (x=1; x lte ArrayLen(aOptions); x=x+1)
		{	
			var formOptionTO = aOptions[x];		
			if (UCase(formOptionTO.getId()) eq Ucase(arguments.formOptionId))
			{
				result=formOptionTO;
			}
		}
		
		return result;		
	}
	
	public FormOptionTO function getFormOptionByValue(String value, any formQuestionTO) 
	{
		var result = "";
		var aOptions = arguments.formQuestionTO.getOptions();
		for (x=1; x lte ArrayLen(aOptions); x=x+1)
		{
			var formOptionTO = aOptions[x];
			if (UCase(formOptionTO.getValue()) eq Ucase(arguments.value))
			{
				result=formOptionTO;
			}
		}
		
		return result;		
	}
}