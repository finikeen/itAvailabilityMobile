Ext.define('Adm.store.reference.Statuses', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.Status'
    },
    inject: {
        apiProperties: 'apiProperties'
    },
    constructor: function(){
        var me = this;
        
        Ext.apply(this, {
            autoLoad: false,
            autoSync: false
        });
        
        return this.callParent(arguments);
    }
});
