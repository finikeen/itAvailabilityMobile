Ext.define('Adm.model.reference.Status', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'id',
			type: 'string'
		}, {
			name: 'tartanId',
			type: 'numeric'
		}, {
			name: 'outOfOffice',
			type: 'boolean'
		}, {
			name: 'dateAdded',
			type: 'date',
			dateFormat: 'timestamp'
		}]
	}
});