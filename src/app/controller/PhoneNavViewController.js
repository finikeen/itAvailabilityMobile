Ext.define('Adm.controller.PhoneNavViewController', {
    extend: 'Deft.mvc.ViewController',
    
    control: {
        view: {
            back: 'onBackButtonTap'
        }
    },
    
    init: function(){
        var me = this;
        
        return me.callParent(arguments);
    },
	
	onBackButtonTap: function(button, eOpts) {
		var me = this;
		
		me.getView().setNavigationBar({
			hidden: true
		});
	}
});
