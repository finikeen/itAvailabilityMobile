Ext.define('Adm.model.reference.OutOfOffice', {
    extend: 'Adm.model.AbstractBase',
    config: {
        fields: [{
            name: 'id',
            type: 'string'
        }, {
            name: 'tartanId',
            type: 'numeric'
        }, {
            name: 'isAllDay',
            type: 'boolean'
        }, {
            name: 'startDate',
            type: 'date'
        }, {
            name: 'startTime',
            type: 'time'
        }, {
            name: 'endDate',
            type: 'date'
        }, {
            name: 'endTime',
            type: 'time'
        }, {
            name: 'eventType',
            type: 'string'
        }, {
            name: 'display',
            type: 'boolean'
        }],
        validations: [{
            type: 'presence',
            field: 'eventType'
        }, {
			type: 'presence',
			field: 'startDate'
		}, {
			type: 'presence',
			field: 'startTime'
		}, {
			type: 'presence',
			field: 'endDate'
		}, {
			type: 'presence',
			field: 'endTime'
		}]
    }
});