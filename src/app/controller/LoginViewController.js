Ext.define('Adm.controller.LoginViewController', {
    extend: 'Deft.mvc.ViewController',
    inject: {
        apiProperties: 'apiProperties',
        appEventsController: 'appEventsController',
        authUser: 'authenticatedUser',
        formUtils: 'formRendererUtils',
        overrides: 'overrides',
        accessTypesStore: 'accessTypesStore',
        rolesStore: 'rolesStore',
        securityService: 'securityService'
    },
    requires: ['Ext.util.DelayedTask'],
    control: {
        signInFailedLabel: '#signInFailedLbl',
        usernameText: '#usernameTxt',
        passwordText: '#passwordTxt',
        
        loginButton: {
            selector: '#loginBtn',
            listeners: {
                tap: 'onLoginButtonTap'
            }
        }
    },
    config: {
        refs: {
            mainView: 'main'
        }
    },
    
    init: function(){
        var me = this;
		
		me.securityService.checkCookies({
            success: me.checkCookiesSuccess,
            failure: me.checkCookiesFailure,
            scope: me
        });
        
        return me.callParent(arguments);
    },
    
    checkCookiesSuccess: function(response, scope){
        var me = scope;
        
        if (response != "na") {
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
        
        me.authUser.populateFromGenericObject(response);
        me.rolesStore.setData(response.AVAILABLEROLES);
        // if no roles, deny user?
        /* if (me.rolesStore.count == 0) {
         me.getErrorField().setText('You do not have access to this application.');
         } else
         */
        // roles don't matter, so assign it to current and load the dashboard
        // if (me.rolesStore.count() == 1) {
            me.authUser.set('CURRENTROLE', me.rolesStore.first().get('ROLE'));
            me.authUser.set('CURRENTACCESSTYPES', me.rolesStore.first().get('_ACCESS'));
            // console.log(me.authenticatedUser.get('CURRENTROLE'));
            
            Ext.Viewport.animateActiveItem(1, {
				type: 'slide',
				direction: 'left'
			});
        // }
        // if more then one role, load the role selection screen
        /* else {
            me.loadRoleScreen();
        } */
		me.appEventsController.getApplication().fireEvent('updateStatus');
    },
    
    verifyLoginCookiesFailure: function(response, scope){
        var me = scope;
        
        console.log('VerifyLoginCookies failure:');
        console.log(response);
    },
    
    onLoginButtonTap: function(button){
        var me = this;
        
        me.getSignInFailedLabel().hide();
        
        var task = Ext.create('Ext.util.DelayedTask', function(){
            me.getSignInFailedLabel().setHtml('');
            
            me.doLogin();
        });
        
        task.delay(500);
        
    },
    
    doLogin: function(){
        var me = this;
        var username = me.getUsernameText().getValue();
        var password = me.getPasswordText().getValue();
        
        if (username.length === 0 || password.length === 0) {
            me.getSignInFailedLabel().setHtml('Please enter your Username and Password');
            me.getSignInFailedLabel().show();
            return;
        }
        
        me.getView().setMasked({
            xtype: 'loadmask',
            message: 'Signing In...'
        });
        
        me.securityService.doLogin({
            username: username,
            password: password
        }, {
            success: me.loginSuccess,
            failure: me.loginFailure,
            scope: me
        });
        
        // me.getUsernameText().setValue('');
        // me.getPasswordText().setValue('');
    },
    
    loginSuccess: function(response, scope){
        var me = scope;
        
        me.getView().setMasked(false);
        
        if (response.ERROR) {
            /**
             * display an eror message, if it exists
             */
            me.getSignInFailedLabel().setHtml('Error: ' + response.DETAIL);
            me.getSignInFailedLabel().show();
        }
        else {
            /**
             * populate the auth user object and available roles store
             */
            me.authUser.populateFromGenericObject(response);
            me.rolesStore.setData(response.AVAILABLEROLES);
            
            /**
             * uncomment below to deny user if no roles
             */
            /* if (me.rolesStore.count == 0) {
             me.getErrorField().setText('You do not have access to this application.');
             } else
             */
            /**
             * roles don't matter, so assign the first one to current and load the dashboard
             */
            // if (me.rolesStore.count() == 1) {
            me.authUser.set('CURRENTROLE', me.rolesStore.first().get('ROLE'));
            me.authUser.set('CURRENTACCESSTYPES', me.rolesStore.first().get('_ACCESS'));
            // console.log(me.authUser.get('TARTANID'));
            // console.log(me.authUser.getTartanId());
            Ext.Viewport.animateActiveItem(1, {
				type: 'slide',
				direction: 'left'
			});
            //}
            /**
             * if more then one role, load the role selection screen
             */
            /* else {
             me.loadRoleScreen();
             } */
        }
    },
    
    loginFailure: function(response, scope){
        var me = scope;
        
        console.log("Error: ");
        console.log(response);
    }
});
