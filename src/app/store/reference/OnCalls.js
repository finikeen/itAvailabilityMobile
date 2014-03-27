Ext.define('Adm.store.reference.OnCalls', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.OnCall',
        groupField: 'departmentName'
    },
    inject: {
        apiProperties: 'apiProperties'
    },
    
    constructor: function(){
        var me = this;
        
        Ext.apply(me, {
            proxy: me.apiProperties.getProxy(me.apiProperties.getItemUrl('oncall')),
            autoLoad: true,
            pageSize: 20,
            params: {
                page: 0,
                start: 0,
                limit: 100
            }
        });
        
        return this.callParent(arguments);
    }
});
