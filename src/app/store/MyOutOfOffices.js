Ext.define('Adm.store.MyOutOfOffices', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.OutOfOffice'
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
