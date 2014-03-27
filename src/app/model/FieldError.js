Ext.define('Adm.model.FieldError', {
    extend: 'Ext.data.Model',
    config: {
		fields: [{
			name: 'label',
			type: 'string'
		}, {
			name: 'errorMessage',
			type: 'string'
		}]
	}
});