Ext.define('Adm.store.contacts.Contacts', {
    extend: 'Ext.data.Store',
    config: {
        model: 'Adm.model.contacts.Contact',
        sorters: [{
            property: 'departmentName',
            direction: 'asc'
        }, {
            property: 'isDepartmentHead',
            direction: 'desc'
        }, {
            property: 'fullname',
            direction: 'asc'
        }],
        groupField: 'departmentName',
        autoLoad: true
    },
    inject: {
        apiProperties: 'apiProperties',
        authUser: 'authenticatedUser'
    },
    
    constructor: function(){
        var me = this;
        // var myId = (me.authUser.get('TARTANID') * 4567);
        var myId = (521272 * 4567);
        
        Ext.apply(me, {
            proxy: me.apiProperties.getProxy(me.apiProperties.getItemUrl('contacts') + '?myid=' + myId),
            autoLoad: true,
            autoSync: false,
            pageSize: 200,
            params: {
                page: 0,
                start: 0,
                limit: 200
            }
        });
        
        return me.callParent(arguments);
    }
});
