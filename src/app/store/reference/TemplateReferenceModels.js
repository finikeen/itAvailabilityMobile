Ext.define('Adm.store.reference.TemplateReferenceModels', {
    extend: 'Adm.store.reference.AbstractReferences',
    config: {
        model: 'Adm.model.reference.TemplateReferenceModel'
    },
    constructor: function(){
        this.callParent(arguments);
        Ext.apply(this.getProxy(), {
            url: this.getProxy().url + this.apiProperties.getItemUrl('url')
        });
    }
});
