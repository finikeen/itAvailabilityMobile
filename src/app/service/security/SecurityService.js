Ext.define('Adm.service.security.SecurityService', {
    extend: 'Adm.service.AbstractService',
    inject: {
        apiProperties: 'apiProperties'
    },
    
	initialize: function(){
        return this.callParent(arguments);
    },
    
    getBaseUrl: function(){
        var me = this;
        var baseUrl = me.apiProperties.createUrl(me.apiProperties.getItemUrl(''));
        return baseUrl;
    },
    /**
     * function to check to see if user has logged in from another
     * Sinclair web site and has the appropriate cookies already
     *
     * @param {success,failure,scope} callbacks
     */
    checkCookies: function(callbacks){
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
            url: me.getBaseUrl() + 'checkCookies',
            method: 'GET',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    
    /**
     * sends the username for authentication
     * assumes SCC Cookies already exist (user logged in elsewhere)
     *
     * @param {username} jsonData
     * @param {success,failure,scope} callbacks
     */
    verifyLoginCookies: function(jsonData, callbacks){
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
            url: me.getBaseUrl() + 'verifyLoginCookies',
            method: 'POST',
            jsonData: jsonData,
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    
    /**
     * sends the username and password for authentication
     *
     * @param {username,password} jsonData
     * @param {success,failure,scope} callbacks
     */
    doLogin: function(jsonData, callbacks){
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
            url: me.getBaseUrl() + 'login',
            method: 'POST',
            jsonData: jsonData,
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    /**
     * calls the security logout function
     *
     * @param {success,failure,scope} callbacks
     */
    doLogout: function(callbacks){
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
            url: me.getBaseUrl() + 'logout',
            method: 'GET',
            successFunc: success,
            failureFunc: failure,
            scope: me
        });
    },
    /**
     * unused???
     * @param {Object} jsonData
     * @param {Object} callbacks
     */
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
