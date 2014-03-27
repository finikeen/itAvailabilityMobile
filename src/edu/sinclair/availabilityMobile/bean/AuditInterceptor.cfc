import edu.sinclair.availability.bean.*;

component output="false" implements="CFIDE.ORM.IEventHandler"
{
    public void function preInsert( any entity )
    {
    	entity = arguments.entity;
    	
    	// Handle Null ID values in Student Instances 
    	/*
    	if ( IsInstanceOf( entity, "Student" ) )
    	{
    		if (!len(trim( entity.getApplicationTypeID() ))) {
      			entity.setApplicationTypeID( javaCast( 'null', 0 ) );
		 	}
  
			if (!len(trim( arguments.entity.getApplicationGroupContactID() ))) {
	      		entity.setApplicationGroupContactID( javaCast( 'null', 0 ) );
			 }   		
    	}
    	*/
    }
     
    public void function preLoad( any entity )
    {
    }
     
    public void function postLoad( any entity )
    {   
    }
    
    public void function postInsert( any entity )
    { 
	     /*
	     if ( IsInstanceOf( entity, "AbstractAuditable" ) )
	     {
     	 	// Create Audit Record
     	 	objectProperties = EntityNew("ObjectProperties");
     	 	objectProperties.setObjectID( '6B9A2351-F476-42AE-B9B8-9EF753CAEB52' ); // entity.getAuditID()
     	 	objectProperties.setCreatedDate( Now() );
	     	objectProperties.setCreatedBy( "Testing a Record" );
			objectProperties.setObjectStatus(1);
			objectProperties.setObjectType( entity.getAuditType() );
			objectProperties.setSearchable( 1 ); 	 
	     	//EntitySave(objectProperties);	 
	     } 
		*/  
    }
     
    public void function preUpdate( any entity, Struct oldData )
    {
    }
     
    public void function postUpdate( any entity )
    {
	     /*
	     if ( IsInstanceOf( entity, "AbstractAuditable" ) )
	     {
	     	 var objectProperties = EntityLoadByPK( "ObjectProperties", entity.getAuditID() );
	     	 if ( !IsNull(objectProperites) )
	     	 {
	     	 	objectProperties.setModifiedDate( Now() );
		     	objectProperties.setModifiedBy( "shawn.gormley" );
	     	 }else{
	     	 	objectProperties = EntityNew("ObjectProperties");
	     	 	objectProperties.setObjectID( entity.getAuditID() );
	     	 	objectProperties.setCreatedDate( Now() );
		     	objectProperties.setCreatedBy( "shawn.gormley" );
		     	objectProperties.setModifiedDate( Now() );
		     	objectProperties.setModifiedBy( "shawn.gormley" );
		     	objectProperties.setObjectStatus(1);
		     	objectProperties.setObjectType( entity.getAuditType() );
		     	objectProperties.setSearchable( 1 );
	     	 }
	     	  
	     	 //EntitySave(objectProperties);
	     	 
	     }  
		 */   	
    }
     
    public void function preDelete( any entity )
    {
    }
     
    public void function postDelete( any entity )
    {
    	 /* 
    	 if ( IsInstanceOf( entity, "AbstractAuditable" ) )
	     {
	     	 var objectProperties = EntityLoadByPK( "ObjectProperties", entity.getAuditID() );
	     	 if ( !IsNull(objectProperites) )
	     	 {
	     	 	// EntityDelete(objectProperties);	 
	     	 }
	     }
		 */
    }
 
}