Ext.define('Adm.view.Main', {
    extend: 'Ext.tab.Panel',
    xtype: 'main',
    inject: {
        applicationName: 'applicationName'
    },
	requires: [
		'Adm.view.PhoneNavView',
		'Adm.view.OutOfOfficeForm',
		'Adm.view.LateForm'
	],
    config: {
        tabBarPosition: 'bottom',
		itemId: 'main',
        ui: 'light',
        items: [{
            xtype: 'phonenavview'
        }, {
			xtype: 'outofofficeform'
		}, {
			xtype: 'lateform'
		}]
    }
});
