Ext.define('Adm.store.reference.Schedules', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.Schedule'
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
