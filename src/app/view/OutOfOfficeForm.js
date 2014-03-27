Ext.define('Adm.view.OutOfOfficeForm', {
    extend: 'Ext.form.Panel',
    xtype: 'outofofficeform',
    alias: 'widget.outofofficeform',
    controller: 'Adm.controller.OutOfOfficeFormViewController',
    inject: {
        appEventsController: 'appEventsController',
        authUser: 'authenticatedUser',
        eventTypesStore: 'eventTypesStore'
    },
    requires: [
		'Ext.field.Hidden',
		'Ext.field.Select',
		'Ext.field.DatePicker',
		'Adm.ux.field.TimePicker'
	],
    
    config: {
        title: 'Out Of Office',
        iconCls: 'out_of_office',
        items: [{
			xtype: 'hiddenfield',
			name: 'tartanId'
		}, {
            xtype: 'fieldset',
            title: 'Send Out Of Office Notice',
            instructions: '(* - required field)',
            items: [{
                xtype: 'selectfield',
                label: 'Reason',
				name: 'eventType',
                required: true,
                store: this.eventTypesStore,
                displayField: 'eventType',
                valueField: 'eventType',
				placeHolder: 'Please Select...'
            }, {
                xtype: 'checkboxfield',
                label: 'All Day Event',
				name: 'isAllDay',
				itemId: 'allDayCB',
				labelAlign: 'left',
				value: 1,
				padding: '0 95% 0 0'
            }, {
				xtype: 'datepickerfield',
				label: 'Start Date',
				name: 'startDate',
				itemId: 'startDateTxt',
				destroyPickerOnHide: true,
				value: new Date(),
				picker: {
					yearFrom: 2014,
					yearTo: 2020
				},
				required: true
			}, {
				xtype: 'timepickerfield',
				label: 'Start Time',
				name: 'startTime',
				itemId: 'startTimeCB',
				value: new Date(),
				picker: {
					value: Ext.Date.format(new Date(), 'h:i A')
				},
				required: true
			}, {
				xtype: 'datepickerfield',
				label: 'End Date',
				name: 'endDate',
				itemId: 'endDateTxt',
				destroyPickerOnHide: true,
				picker: {
					value: new Date(),
					yearFrom: 2014,
					yearTo: 2020
				},
				required: true
			}, {
				xtype: 'timepickerfield',
				label: 'End Time',
				itemId: 'endTimeCB',
				name: 'endTime',
				required: true
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
