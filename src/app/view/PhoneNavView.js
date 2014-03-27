Ext.define('Adm.view.PhoneNavView', {
    extend: 'Ext.navigation.View',
    xtype: 'phonenavview',
    alias: 'widget.phonenavview',
    controller: 'Adm.controller.PhoneNavViewController',
	
    config: {
        title: 'Phone List',
        iconCls: 'home',
		items: [{
			xtype: 'phonelist'
		}],
		navigationBar: {
			hidden: true
		}
	}
});
