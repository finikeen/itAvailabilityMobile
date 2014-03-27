component output="false" persistent="false" extends="AbstractEntity"
{
	/*
	 * Required method for auditable entities.
	 * Sets the id value that matches objectID in 
	 * the ObjectProperties table. 
	 * Implement in an interface.
	public string function getAuditIDField()
	{
		return this.auditIDField;
	}
	*/
	

	/*
	 * Used for the objectType field in the ObjectProperties table.
	 */
	public string function getAuditType()
	{
		return ListLast(getMetaData(this).fullName,'.'); //
	}
}