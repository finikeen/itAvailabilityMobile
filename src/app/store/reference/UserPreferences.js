Ext.define('Adm.store.reference.UserPreferences', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.reference.UserPreference'
    },
    inject: {
        apiProperties: 'apiProperties',
        authUser: 'authenticatedUser'
    },
    
    constructor: function(){
        var me = this;
        var id = (me.authUser.get('TARTANID') * 4567);
        
        Ext.apply(me, {
            proxy: me.apiProperties.getProxy(me.apiProperties.getItemUrl('userprefs') + '/' + id),
            autoLoad: true
        });
        
        return this.callParent(arguments);
    }
});
