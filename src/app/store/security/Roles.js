Ext.define('Adm.store.security.Roles', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.security.Role'
    },
    
    constructor: function(){
        Ext.apply(this, {
            autoLoad: false,
            autoSync: false
        });
        
        return this.callParent(arguments);
    }
});
