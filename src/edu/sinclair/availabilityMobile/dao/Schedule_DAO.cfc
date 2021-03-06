component output="false" hint="Schedule_DAO"
{
	// The name of the relevant entity/bean for this dao
    variables.entityName = "Schedule";
    
    // Property mapping for the primary key field name. 
    // This should match the bean's property name for the primary key field.
    // See primaryKeysMap in selectById and delete methods
    variables.primaryKeyFieldName = "tartanId";
	
	// save 
	public any function save( required any item )
	{
		entitysave(item);
		
		return item;
	}

	// selectByID 
	public any function selectById( required any id )
	{
		var primaryKeysMap = { #variables.primaryKeyFieldName# = arguments.id };
		
		return entityload(variables.entityName,primaryKeysMap,false);
	}

	// selectAll 
	public array function selectAll()
	{
		return entityload(variables.entityName);
	}

	// selectPaged 
	public array function selectPaged( required numeric startIndex, required numeric numItems, string sortOrder, struct filter=StructNew() )
	{
		return entityload(variables.entityName,arguments.filter,arguments.sortOrder,{offset=arguments.startIndex,maxresults=arguments.numItems});
	}

	// delete 
	public void function delete( required any id )
	{
		var primaryKeysMap = { #variables.primaryKeyFieldName# = arguments.id };
		var item=entityload(variables.entityName,primaryKeysMap,false);
		if (isnull(item) eq false)
		{
			for (i in item )
			{
				entitydelete(i);
			}
		}
		
		return;
	}

	// selectCount
	public numeric function selectCount()
	{
		return ormexecutequery("select count(*) from Schedule",true);
	}
}
