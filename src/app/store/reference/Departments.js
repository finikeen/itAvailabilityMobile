Ext.define('Adm.store.reference.Departments', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.Department'
    },
    inject: {
        apiProperties: 'apiProperties'
    },
    constructor: function(){
        var me = this;
        
        Ext.apply(me, {
            proxy: me.apiProperties.getProxy(me.apiProperties.getItemUrl('depts')),
            autoLoad: true,
            autoSync: true,
            pageSize: 200,
            params: {
                page: 0,
                start: 0,
                limit: 200
            }
        });
        
        return this.callParent(arguments);
    }
});
