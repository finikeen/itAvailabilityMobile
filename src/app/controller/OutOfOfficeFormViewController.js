Ext.define('Adm.controller.OutOfOfficeFormViewController', {
    extend: 'Deft.mvc.ViewController',
    inject: {
        apiProperties: 'apiProperties',
        appEventsController: 'appEventsController',
        authUser: 'authenticatedUser',
        formUtils: 'formRendererUtils',
        overrides: 'overrides',
        store: 'eventTypesStore',
        contactsStore: 'contactsStore',
        outOfOfficeService: 'outOfOfficeService'
    },
    control: {
        allDayCheck: {
            selector: '#allDayCB',
            listeners: {
                change: 'onAllDayChanged'
            }
        },
        sendButton: {
            selector: '#sendBtn',
            listeners: {
                tap: 'onSendButtonTap'
            }
        },
        startDateText: '#startDateTxt',
        startTimeCombo: '#startTimeCB',
        endDateText: '#endDateTxt',
        endTimeCombo: '#endTimeCB'
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
        })
        
        Ext.Ajax.request({
            url: me.apiProperties.getProxy(me.apiProperties.getItemUrl('eventtypes')).url + '.json',
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            success: function(response, view){
                var r = Ext.decode(response.responseText);
                
                me.store.setData(r.rows);
                me.getView().setMasked(false);
                
                me.getView().down('selectfield').setStore(me.store);
            },
            failure: me.apiProperties.handleError
        }, me);
    },
    
    onAllDayChanged: function(checkbox, e, eOpts){
        var me = this;
        var date = new Date(), year = date.getFullYear(), month = date.getMonth(), day = date.getDate();
		
        Ext.ComponentQuery.query('#startDateTxt')[0].reset();
        Ext.ComponentQuery.query('#startTimeCB')[0].reset();
        Ext.ComponentQuery.query('#endDateTxt')[0].reset();
        Ext.ComponentQuery.query('#endTimeCB')[0].reset();
        
        if (checkbox.isChecked()) {
            var st = new Date(year, month, day, 8, 0);
            var et = new Date(year, month, day, 17, 0);
            Ext.ComponentQuery.query('#startDateTxt')[0].setValue(new Date());
            Ext.ComponentQuery.query('#startTimeCB')[0].setValue(st);
            Ext.ComponentQuery.query('#endDateTxt')[0].setValue(new Date());
            Ext.ComponentQuery.query('#endTimeCB')[0].setValue(et);
        }
    },
    
    onSendButtonTap: function(button){
        var me = this;
        var errorString = '', form = button.up('formpanel'), fields = form.query("field"), data = form.getValues();
		data.tartanId = me.authUser.get('TARTANID');
        // remove the style class from all fields
        for (var i = 0; i < fields.length; i++) {
            fields[i].removeCls('invalidField');
        }
        
        var model = Ext.create("Adm.model.reference.OutOfOffice", data);
        
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
            me.outOfOfficeService.save(data, {
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
