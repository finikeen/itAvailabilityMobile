Ext.define('Adm.model.reference.UserPreference', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'userid',
			type: 'number'
		}, {
			name: 'name',
			type: 'string'
		}, {
			name: 'value',
			type: 'string'
		}]
	}
});