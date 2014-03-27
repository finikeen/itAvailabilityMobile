component output="false" hint="UserInfo_Service"
{
	variables.dao = APPLICATION.security.objectFactory.getObjectByName("UserInfo","dao","security");
	variables.filterCollection = APPLICATION.security.objectFactory.getObjectByName("FilterCollection","bean","event");
	variables.dataTypeUtil = APPLICATION.beanFactory.getBean('dataTypeUtil');
	
	// save
	// data = The object to save
	public any function save( required any data )
	{
		return variables.dao.save( arguments.data );
	}

	// getByID
	// data.id property denotes object to retrieve
	public any function getById( required struct data )
	{
		return variables.dao.selectById( data.id );
	}

	// getAll
	// data - Structure with props denoting data and an optional Filter object.
	public any function getAll( required struct data )
	{
		data = arguments.data;
		// Filter collection is a filter expression object from the Flexicious Grids.
		if ( structkeyexists(data,'filterCollection') )
		{
			// Use the filter to get paged items from startIndex for numItems
			items = getPaged( data.filterCollection );
		}else{			
			// Return all items
			items = variables.dao.selectAll();
		}
		
		return items;	
	}

	// getPaged
	// filterData = struct with startIndex, numItems, sortOrder and filter props
	public array function getPaged( required any filterCollection )
	{
		// Get filter props from FilterCollection: As used in Flexicious Grid
		// Includes: startIndex, numItems, filter and sortOrder
		filterData = variables.filterCollection.translateFilter( arguments.filterCollection );

		// Read Records
		items = variables.dao.selectPaged( filterData.startIndex, filterData.numItems, filterData.sortOrder, filterData.filter );
		return items;
	}

	// delete
	// data.id property denotes object to delete
	public string function delete( required any data )
	{
		id = arguments.data.id;
		variables.dao.delete( id );
		return id;
	}

	// count - data is optional
	public numeric function count( any data )
	{
		return variables.dao.selectCount();
	}
}
