Ext.define('Adm.model.reference.Schedule', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'id',
			type: 'string'
		}, {
			name: 'tartanId',
			type: 'numeric'
		}, {
			name: 'orderId',
			type: 'numeric'
		}, {
			name: 'startTime',
			type: 'string'
		}, {
			name: 'endTime',
			type: 'string'
		}, {
			name: 'dayOfWeek',
			type: 'string'
		}]
	}
});