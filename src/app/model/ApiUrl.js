Ext.define('Adm.model.ApiUrl', {
    extend: 'Ext.data.Model',
    config: {
		fields: [{
			name: 'name',
			type: 'string'
		}, {
			name: 'url',
			type: 'string'
		}]
	}
});