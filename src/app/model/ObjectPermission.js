Ext.define('Adm.model.ObjectPermission', {
    extend: 'Ext.data.Model',
    config: {
		fields: [{
			name: 'name',
			type: 'string'
		}, {
			name: 'hasAccess',
			type: 'boolean'
		}]
	}
});