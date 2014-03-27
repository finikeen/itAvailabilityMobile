Ext.define('Adm.store.TemplateModels', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.TemplateModel'
    },
    inject: {
        apiProperties: 'apiProperties'
    },
    constructor: function(){
        Ext.apply(this, {
            proxy: this.apiProperties.getProxy(this.apiProperties.getItemUrl('url')),
            autoLoad: false
        });
        return this.callParent(arguments);
    }
});
