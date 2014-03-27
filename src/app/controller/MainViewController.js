Ext.define('Adm.controller.MainViewController', {
    extend: 'Deft.mvc.ViewController',
    mixins: ['Deft.mixin.Injectable'],
    inject: {
        appEventsController: 'appEventsController',
        formUtils: 'formRendererUtils',
        overrides: 'overrides',
        securityService: 'securityService',
        rolesStore: 'rolesStore',
        authenticatedUser: 'authenticatedUser'
    },
    
    init: function(){
        var me = this;
        
        me.overrides.applyOverrides();
        
        me.securityService.checkCookies({
            success: me.checkCookiesSuccess,
            failure: me.checkCookiesFailure,
            scope: me
        });
        
        return me.callParent(arguments);
    },
    
    checkCookiesSuccess: function(response, scope){
        var me = scope;
        
        if (response == "na") {
            // show the login screen
            me.loadLoginScreen();
        }
        else {
            // fetch user credentials
            me.securityService.verifyLoginCookies({
                username: response
            },{
                success: me.verifyLoginCookiesSuccess,
                failure: me.verifyLoginCookiesFailure,
                scope: me
            });
        }
    },
    
    checkCookiesFailure: function(response, scope){
        var me = scope;
        
        console.log('CheckCookies failure: ');
        console.log(response);
    },
    
    verifyLoginCookiesSuccess: function(response, scope){
        var me = scope;
        // console.log(response);
        me.authenticatedUser.populateFromGenericObject(response);
        me.rolesStore.loadData(response.AVAILABLEROLES);
		// console.log(response.AVAILABLEROLES);
        // console.log(me.rolesStore);
        // console.log(me.authenticatedUser.data);
        
        // if no roles, deny user?
        /* if (me.rolesStore.count == 0) {
         me.getErrorField().setText('You do not have access to this application.');
         } else
         */
        // if one role, assign it to current and load the dashboard
        // if (me.rolesStore.count() == 1) {
            me.authenticatedUser.set('CURRENTROLE', me.rolesStore.first().get('ROLE'));
            me.authenticatedUser.set('CURRENTACCESSTYPES', me.rolesStore.first().get('_ACCESS'));
            // console.log(me.authenticatedUser.get('CURRENTROLE'));
            
            me.loadDashboard();
        /* }
        // if more then one role, load the role selection screen
        else {
            me.loadRoleScreen();
        } */
    },
    
    verifyLoginCookiesFailure: function(response, scope){
        var me = scope;
        
        console.log('VerifyLoginCookies failure:');
        console.log(response);
    },
    
    // loadDisplay (componentToLoadInto, componentToLoad, passParameters(true/false), parameters)
    loadLoginScreen: function(){
        var comp = this.formUtils.loadDisplay('mainview', 'loginform', true, {});
    },
    
    loadDashboard: function(){
        var comp = this.formUtils.loadDisplay('mainview', 'dashboard', true, {
            height: '100%',
            flex: 1
        });
    },
    
    loadRoleScreen: function(){
        var comp = this.formUtils.loadDisplay('mainview', 'roleform', true, {});
    }
    
    /* displayLoginView: function(){
     var me=this;
     var mainView = Ext.ComponentQuery.query('mainview')[0];
     var arrViewItems;
     
     if (mainView.items.length > 0)
     {
     mainView.removeAll();
     }
     
     arrViewItems = [{xtype:'loginform',
     layout: {
     type: 'vbox',
     align: 'middle',
     pack: 'center'
     }}];
     
     mainView.add( arrViewItems );
     } */
});
