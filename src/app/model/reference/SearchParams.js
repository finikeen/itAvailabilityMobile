Ext.define('Adm.model.reference.SearchParams', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'keyword',
			type: 'string'
		}, {
			name: 'deptName',
			type: 'string'
		}, {
			name: 'availableNow',
			type: 'boolean'
		}, {
			name: 'onCall',
			type: 'boolean'
		}, {
			name: 'outOfOffice',
			type: 'boolean'
		}, {
			name: 'firstShift',
			type: 'boolean'
		}, {
			name: 'secondShift',
			type: 'boolean'
		}, {
			name: 'thirdShift',
			type: 'boolean'
		}]
	}
});