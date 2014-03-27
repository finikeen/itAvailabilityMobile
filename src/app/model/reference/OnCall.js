Ext.define('Adm.model.reference.OnCall', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'id',
			type: 'number'
		}, {
			name: 'fullName',
			type: 'string'
		}, {
			name: 'departmentName',
			type: 'string'
		}, {
			name: 'onCallWeek0',
			type: 'boolean'
		}, {
			name: 'onCallWeek1',
			type: 'boolean'
		}, {
			name: 'onCallWeek2',
			type: 'boolean'
		}, {
			name: 'onCallWeek3',
			type: 'boolean'
		}, {
			name: 'onCallWeek4',
			type: 'boolean'
		}, {
			name: 'onCallWeek5',
			type: 'boolean'
		}]
	}
});