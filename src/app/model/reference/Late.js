Ext.define('Adm.model.reference.Late', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'id',
			type: 'string'
		}, {
			name: 'tartanId',
			type: 'numeric'
		}, {
			name: 'dateSubmitted',
			type: 'date'
		}, {
			name: 'lateBy',
			type: 'numeric'
		}, {
			name: 'lateReason',
			type: 'string'
		}],
        validations: [{
            type: 'presence',
            field: 'lateBy'
        }]
	}
});