Ext.define('Adm.controller.LateFormViewController', {
    extend: 'Deft.mvc.ViewController',
    inject: {
        apiProperties: 'apiProperties',
        appEventsController: 'appEventsController',
        authUser: 'authenticatedUser',
        formUtils: 'formRendererUtils',
        overrides: 'overrides',
        contactsStore: 'contactsStore',
        lateService: 'lateService'
    },
    control: {
        lateByCombo: '#lateBy',
		
        sendButton: {
            selector: '#sendBtn',
            listeners: {
                tap: 'onSendButtonTap'
            }
        },
    },
    
    init: function(){
        var me = this;
        
        me.loadData();
        
        return me.callParent(arguments);
    },
    
    loadData: function(){
        var me = this;
        
        me.getView().setMasked({
            xtype: 'loadmask'
        });
		
		var lateByStore = Ext.create('Ext.data.Store', {
			model: 'Adm.model.reference.SimpleReferenceData',
			data: [
				{id: '15', name: '15 minutes'},
				{id: '30', name: '30 minutes'},
				{id: '45', name: '45 minutes'},
				{id: '60', name: '1 hour'},
				{id: '90', name: '1.5 hours'},
				{id: '120', name: '2 hours'},
				{id: '180', name: '3 hours'},
				{id: '240', name: '4 hours'}
			]
		});
		me.getLateByCombo().setStore(lateByStore);
		me.getView().setMasked(false);
    },
    
    onSendButtonTap: function(button){
        var me = this;
        var errorString = '', form = button.up('formpanel'), fields = form.query("field"), data = form.getValues();
		data.tartanId = me.authUser.get('TARTANID');
        // remove the style class from all fields
        for (var i = 0; i < fields.length; i++) {
            fields[i].removeCls('invalidField');
        }
        
        var model = Ext.create("Adm.model.reference.Late", data);
        
        var errors = model.validate();
        
        if (!errors.isValid()) {
            errors.each(function(errorObj){
                errorString += errorObj.getField() + " " + errorObj.getMessage() + "";
                
                // build a string to select the appropriate field
                var s = Ext.String.format('field[name={0}]', errorObj.getField());
                
                // apply the style class
                form.down(s).addCls('invalidField');
            });
            Ext.Msg.alert('Errors in your input', errorString);
        }
        else {
            // send the request
            me.lateService.save(data, {
                success: me.saveSuccess,
                failure: me.saveFailure,
                scope: me
            });
        }
    },
    
    saveSuccess: function(response, scope){
        var me = scope;
        
        // me.appEventsController.getApplication().fireEvent('updateStatus');
        
        me.contactsStore.load();
        
        Ext.Msg.alert('Notice Sent', 'Thank You');
    },
    
    saveFailure: function(response, scope){
        var me = scope;
        
        console.log("saveFailure: ");
        console.log(response);
    }
});
