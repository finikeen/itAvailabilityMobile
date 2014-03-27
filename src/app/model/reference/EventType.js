Ext.define('Adm.model.reference.EventType', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'id',
			type: 'number'
		}, {
			name: 'eventType',
			type: 'string'
		}]
	}
});