Ext.define('Adm.store.security.AccessTypes', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.security.AccessType'
    },
    
    constructor: function(){
        Ext.apply(this, {
            autoLoad: false,
            autoSync: false
        });
        
        return this.callParent(arguments);
    }
});
