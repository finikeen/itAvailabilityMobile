Ext.define('Adm.store.reference.YesNo', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.AbstractReference'
    },
    constructor: function(){
        var items = [{
            id: "Y",
            name: "Yes"
        }, {
            id: "N",
            name: "No"
        }];
        
        Ext.apply(this, {
            items: items
        });
        Ext.apply(this, {
            autoLoad: false
        });
        this.callParent(arguments);
    }
});
