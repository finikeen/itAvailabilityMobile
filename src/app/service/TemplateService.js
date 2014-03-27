Ext.define('Adm.service.TemplateService', {  
    extend: 'Adm.service.AbstractService',   		
    mixins: [ 'Deft.mixin.Injectable'],
    inject: {
    	apiProperties: 'apiProperties'
    },
    initComponent: function() {
		return this.callParent( arguments );
    },
    
    getBaseUrl: function( id ){
		var me=this;
		var baseUrl = me.apiProperties.createUrl( me.apiProperties.getItemUrl('url') );
    	return baseUrl;
    },

    get: function( id, callbacks ){
    	var me=this;
	    var success = function( response, view ){
	    	var r = Ext.decode(response.responseText);
	    	if (response.responseText != "")
	    	{
		    	r = Ext.decode(response.responseText);	    		
	    	}
	    	callbacks.success( r, callbacks.scope );
	    };

	    var failure = function( response ){
	    	me.apiProperties.handleError( response );	    	
	    	callbacks.failure( response, callbacks.scope );
	    };
	    
		// load
		me.apiProperties.makeRequest({
			url: me.getBaseUrl()+'/'+id,
			method: 'GET',
			successFunc: success,
			failureFunc: failure,
			scope: me
		});
    },
    
    save: function( jsonData, callbacks ){
    	var me=this;
    	var id=jsonData.id;
        var url = me.getBaseUrl();
	    var success = function( response, view ){
	    	var r = Ext.decode(response.responseText);
			callbacks.success( r, callbacks.scope );
	    };

	    var failure = function( response ){
	    	me.apiProperties.handleError( response );
	    	callbacks.failure( response, callbacks.scope );	
	    };
        
    	// save
		if (id=="")
		{
			// create
			me.apiProperties.makeRequest({
    			url: url,
    			method: 'POST',
    			jsonData: jsonData,
    			successFunc: success,
    			failureFunc: failure,
    			scope: me
    		});				
		}else{
			// update
    		me.apiProperties.makeRequest({
    			url: url+"/"+id,
    			method: 'PUT',
    			jsonData: jsonData,
    			successFunc: success,
    			failureFunc: failure,
    			scope: me
    		});	
		}   	
    },
    
    destroy: function( id, callbacks ){
    	var me=this;
	    var success = function( response, view ){
	    	var r = Ext.decode(response.responseText);
			callbacks.success( r, callbacks.scope );
	    };

	    var failure = function( response ){
	    	me.apiProperties.handleError( response );	    	
	    	callbacks.failure( response, callbacks.scope );
	    };
	    
    	me.apiProperties.makeRequest({
   		   url: me.getBaseUrl()+"/"+id,
   		   method: 'DELETE',
   		   successFunc: success,
   		   failureFunc: failure,
   		   scope: me
   	    }); 
    }
});