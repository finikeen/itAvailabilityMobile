component output="false" persistent="false"
{
	string function createNewID()
	{
		newID = insert('-', createUUID(), 23);
		return newID;
	}
	
	any function init()
    {
    }
}