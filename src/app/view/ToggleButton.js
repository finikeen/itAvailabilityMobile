Ext.define('Adm.view.ToggleButton', {
	extend: 'Ext.Button',
	xtype: 'togglebtn',
	config: {
		isPressed: false
	},
	
	initialize: function() {
		var me = this;
		
		me.callParent(arguments);
		me.on('tap', me.onButtonPress, me);
		me.getIsPressed() ? me.addCls(me.getPressedCls()) : me.removeCls(me.getPressedCls());
		me.getIsPressed() ? me.setUi('confirm') : me.setUi('normal');
	},
	
	onButtonPress: function() {
		var me = this;
		
		me.setIsPressed(!me.getIsPressed());
		me.getIsPressed() ? me.addCls(me.getPressedCls()) : me.removeCls(me.getPressedCls());
		me.getIsPressed() ? me.setUi('confirm') : me.setUi('normal');
	}
});
