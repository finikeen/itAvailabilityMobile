Ext.define('Adm.service.ContactService', {
    extend: 'Adm.service.AbstractService',
    inject: {
        apiProperties: 'apiProperties',
		authUser: 'authenticatedUser'
    },
    initialize: function(){
        return this.callParent(arguments);
    },
    
    getBaseUrl: function(){
        var me = this;
        var baseUrl = me.apiProperties.createUrl(me.apiProperties.getItemUrl(''));
        return baseUrl;
    },
    
    getCurrentUserData: function(callbacks){
        var me = this;
		
		var id = (me.authUser.get('TARTANID') * 4567);
		
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            if (response.responseText != "") {
                r = Ext.decode(response.responseText);
            }
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // load
		if (!isNaN(id)) {
			me.apiProperties.makeRequest({
				url: me.getBaseUrl() + 'Contacts/' + id,
				method: 'Get',
				successFunc: success,
				failureFunc: failure,
				scope: me
			});
		}
    },
    
    getContacts: function(callbacks){
        var me = this;
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            if (response.responseText != "") {
                r = Ext.decode(response.responseText);
            }
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // load
        me.apiProperties.makeRequest({
            url: me.getBaseUrl() + 'Contacts',
            method: 'Get',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    
    getContactsTree: function(callbacks){
        var me = this;
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            if (response.responseText != "") {
                r = Ext.decode(response.responseText);
            }
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // load
        me.apiProperties.makeRequest({
            url: me.getBaseUrl() + 'ContactsTree',
            method: 'Get',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    
    getOnCall: function(callbacks){
        var me = this;
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            if (response.responseText != "") {
                r = Ext.decode(response.responseText);
            }
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // load
        me.apiProperties.makeRequest({
            url: me.getBaseUrl() + 'ContactsOnCall',
            method: 'Get',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    
    getOutOfOffice: function(callbacks){
        var me = this;
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            if (response.responseText != "") {
                r = Ext.decode(response.responseText);
            }
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // load
        me.apiProperties.makeRequest({
            url: me.getBaseUrl() + 'ContactsOutOfOffice',
            method: 'Get',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    
    getDepartments: function(callbacks){
        var me = this;
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            if (response.responseText != "") {
                r = Ext.decode(response.responseText);
            }
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // load
        me.apiProperties.makeRequest({
            url: me.getBaseUrl() + 'Departments',
            method: 'Get',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    save: function(jsonData, callbacks){
        var me = this;
        var id = jsonData.id;
        var url = me.getBaseUrl();
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        // save
        if (id == "") {
            // create
            me.apiProperties.makeRequest({
                url: url,
                method: 'POST',
                jsonData: jsonData,
                successFunc: success,
                failureFunc: failure,
                scope: me
            });
        }
        else {
            // update
            me.apiProperties.makeRequest({
                url: url + "/" + id,
                method: 'PUT',
                jsonData: jsonData,
                successFunc: success,
                failureFunc: failure,
                scope: me
            });
        }
    },
    
    destroy: function(id, callbacks){
        var me = this;
        var success = function(response, view){
            var r = Ext.decode(response.responseText);
            callbacks.success(r, callbacks.scope);
        };
        
        var failure = function(response){
            me.apiProperties.handleError(response);
            callbacks.failure(response, callbacks.scope);
        };
        
        me.apiProperties.makeRequest({
            url: me.getBaseUrl() + "/" + id,
            method: 'DELETE',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    }
});
