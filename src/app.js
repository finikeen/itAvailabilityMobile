/*
 This file is generated and updated by Sencha Cmd. You can edit this file as
 needed for your application, but these edits will have to be merged by
 Sencha Cmd when it performs code generation tasks such as generating new
 models, controllers or views and when running "sencha app upgrade".
 Ideally changes to this file would be limited and most work would be done
 in other places (such as Controllers). If Sencha Cmd cannot merge your
 changes and its generated code, it will produce a "merge conflict" that you
 will need to resolve manually.
 */
Ext.Loader.setConfig({
    enabled: true,
    paths: {
        'Adm': '/availabilityMobile/app', // The project_name should match the directory of your project and is case sensitive.
        'ContextName': 'adm',
        'Ext': 'touch/src',
        'Deft': 'packages/deft/src/js',
		'Ext.ux.touch': 'app/ux/touch'
    }
});
Ext.syncRequire(["Deft.mixin.Injectable", "Deft.mixin.Controllable"]);
Ext.require(['Adm.model.security.AuthenticatedUser']);
var apiUrls = [{
    name: '',
    url: ''
}, {
    name: 'usersecinfo',
    url: 'UserSecurityInfo'
}, {
    name: 'roletypes',
    url: 'RoleTypes'
}, {
    name: 'accesstypes',
    url: 'AccessTypes'
}, {
    name: 'assignments',
    url: 'UserAssignments'
}, {
    name: 'roles',
    url: 'UserRoles'
}, {
    name: 'searchusers',
    url: 'SearchUsers'
}, {
    name: 'contacts',
    url: 'Contacts'
}, {
    name: 'employees',
    url: 'Employees'
}, {
    name: 'depts',
    url: 'Depts'
}, {
    name: 'eventtypes',
    url: 'EventTypes'
}, {
    name: 'oncall',
    url: 'OnCall'
}, {
    name: 'oncalllist',
    url: 'OnCallList'
}, {
    name: 'userprefs',
    url: 'Preferences'
}, {
    name: 'outofoffice',
    url: 'OutOfOffice'
}, {
    name: 'late',
    url: 'Late.json'
}];


Ext.application({
    name: 'Adm',
    appFolder: Ext.Loader.getPath('Adm'),
	
    
    requires: ['Ext.MessageBox', 'Ext.form.Panel', 'Ext.form.FieldSet', 'Ext.dataview.List', 'Adm.mixin.ApiProperties', 'Adm.util.Constants', 'Adm.store.reference.AbstractReferences', 'Adm.store.TemplateModels', 'Adm.store.reference.TemplateReferenceModels', 'Adm.store.reference.YesNo', 'Adm.store.reference.EventTypes', 'Adm.store.reference.OnCalls', 'Adm.store.reference.UserPreferences', 'Adm.store.contacts.Contacts', 'Adm.store.reference.Departments', 'Adm.store.reference.Schedules', 'Adm.store.reference.Statuses', 'Adm.store.MyOutOfOffices', 'Adm.store.security.Roles', 'Adm.store.security.AccessTypes', 'Adm.controller.ApplicationEventsController', 'Adm.util.FormRendererUtils', 'Adm.util.Overrides', 'Adm.view.ToggleButton', 'Adm.service.ContactService', 'Adm.service.LateService', 'Adm.service.OutOfOfficeService', 'Adm.service.security.SecurityService'],
    
    views: ['Login', 'Main', 'PhoneNavView', 'PhoneList', 'PhoneDetail', 'OutOfOfficeForm', 'LateForm'],
    
    models: ['AbstractBase', 'ApiUrl', 'SimpleItemDisplay', 'ObjectPermission', 'AuthenticatedPerson', 'FieldError', 'util.TreeRequest', 'Configuration', 'TemplateModel', 'reference.AbstractReference', 'reference.SimpleReferenceData', 'reference.TemplateReferenceModel', 'reference.Department', 'reference.EventType', 'reference.Late', 'reference.OnCall', 'reference.OutOfOffice', 'reference.Status', 'reference.Schedule', 'reference.SearchParams', 'contacts.Contact', 'security.AuthenticatedUser', 'security.Role', 'security.AccessType'],
    
    icon: {
        '57': 'resources/icons/Icon.png',
        '72': 'resources/icons/Icon~ipad.png',
        '114': 'resources/icons/Icon@2x.png',
        '144': 'resources/icons/Icon~ipad@2x.png'
    },
    
    isIconPrecomposed: true,
    
    startupImage: {
        '320x460': 'resources/startup/320x460.png',
        '640x920': 'resources/startup/640x920.png',
        '768x1004': 'resources/startup/768x1004.png',
        '748x1024': 'resources/startup/748x1024.png',
        '1536x2008': 'resources/startup/1536x2008.png',
        '1496x2048': 'resources/startup/1496x2048.png'
    },
    
    launch: function(){
        var me = this;
		
        Deft.Injector.configure({
            overrides: {
                fn: function(){
                    return new Adm.util.Overrides({});
                },
                singleton: true
            },
            applicationName: {
                value: 'IT Employee Availability'
            },
            apiProperties: {
                fn: function(){
                    return new Adm.mixin.ApiProperties({});
                },
                singleton: true
            },
            apiUrlStore: {
                fn: function(){
                    var urlStore = Ext.create('Ext.data.Store', {
                        model: 'Adm.model.ApiUrl',
                        storeId: 'apiUrlStore'
                    });
                    
                    urlStore.setData(apiUrls);
                    
                    return urlStore;
                },
                singleton: true
            },
            constants: {
                fn: function(){
                    return new Adm.util.Constants({});
                },
                singleton: true
            },
            appEventsController: {
                fn: function(){
                    return new Adm.controller.ApplicationEventsController({app:me});
                },
                singleton: true
            },
            formRendererUtils: {
                fn: function(){
                    return new Adm.util.FormRendererUtils({});
                },
                singleton: true
            },
            errorsStore: {
                fn: function(){
                    return Ext.create('Ext.data.Store', {
                        model: 'Adm.model.FieldError'
                    });
                },
                singleton: true
            },
            
            abstractReferencesStore: 'Adm.store.reference.AbstractReferences',
            templateModelsStore: 'Adm.store.TemplateModels',
            templateReferenceModelsStore: 'Adm.store.reference.TemplateReferenceModels',
            yesNoStore: 'Adm.store.reference.YesNo',
            eventTypesStore: 'Adm.store.reference.EventTypes',
            onCallsStore: 'Adm.store.reference.OnCalls',
            userPreferencesStore: 'Adm.store.reference.UserPreferences',
            contactsStore: 'Adm.store.contacts.Contacts',
            deptStore: 'Adm.store.reference.Departments',
            scheduleStore: 'Adm.store.reference.Schedules',
            statusStore: 'Adm.store.reference.Statuses',
            myOutOfOfficeStore: 'Adm.store.MyOutOfOffices',
            
            lateService: 'Adm.service.LateService',
            outOfOfficeService: 'Adm.service.OutOfOfficeService',
            contactService: 'Adm.service.ContactService',
            
            ///////////////////////////////
            // SECURITY OBJECTS
            authenticatedUser: {
                fn: function(){
                    return new Adm.model.security.AuthenticatedUser();
                },
                singleton: true
            },
            
            // SECURITY STORES
            rolesStore: 'Adm.store.security.Roles',
            accessTypesStore: 'Adm.store.security.AccessTypes',
            
            // SECURTY SERVICES
            securityService: 'Adm.service.security.SecurityService'
            ////////////////////////////////
        });
        // Destroy the #appLoadingIndicator element
        Ext.fly('appLoadingIndicator').destroy();
        
        // Initialize the main view
        Ext.Viewport.add({
            xtype: 'loginview'
        }, {
            xtype: 'main'
        });
    },
    
    onUpdated: function(){
        Ext.Msg.confirm("Application Update", "This application has just successfully been updated to the latest version. Reload now?", function(buttonId){
            if (buttonId === 'yes') {
                window.location.reload();
            }
        });
    }
});
