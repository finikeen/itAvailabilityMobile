Ext.define('Adm.view.LateForm', {
    extend: 'Ext.form.Panel',
    xtype: 'lateform',
    alias: 'widget.lateform',
    controller: 'Adm.controller.LateFormViewController',
    inject: {
        appEventsController: 'appEventsController',
        authUser: 'authenticatedUser'
    },
    requires: ['Ext.field.Hidden', 'Ext.field.Select', 'Ext.field.TextArea'],
    
    config: {
        title: 'Late',
        iconCls: 'time',
        items: [{
            xtype: 'hiddenfield',
            name: 'tartanId'
        }, {
            xtype: 'fieldset',
            title: 'Send Late Notice',
            instructions: '(* - required field)',
            items: [{
                xtype: 'selectfield',
                label: 'Late By',
                name: 'lateBy',
				itemId: 'lateBy',
                required: true,
                displayField: 'name',
                valueField: 'id',
                placeHolder: 'Please Select...'
            }, {
				xtype: 'textareafield',
				label: 'Reason',
				name: 'lateReason'
			}]
        }, {
            xtype: 'container',
            layout: {
                type: 'hbox',
                pack: 'center'
            },
            items: [{
                xtype: 'button',
                text: 'Send',
                ui: 'confirm',
                itemId: 'sendBtn',
                margin: '10 10 10 10'
            }, {
                xtype: 'button',
                text: 'Clear',
                ui: 'decline',
                handler: function(){
                    this.up('formpanel').reset();
                },
                margin: '10 10 10 10'
            }]
        }]
    }
});
