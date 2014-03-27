Ext.define('Adm.model.reference.Department', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'departmentAbbr',
			type: 'string'
		}, {
			name: 'departmentName',
			type: 'string'
		}, {
			name: 'departmentPhone',
			type: 'string'
		}, {
			name: 'departmentEmail',
			type: 'string'
		}, {
			name: 'departmentID',
			type: 'numeric'
		}, {
			name: 'parentID',
			type: 'numeric'
		}, {
			name: 'departmentLocation',
			type: 'string'
		}, {
			name: 'departmentFax',
			type: 'string'
		}, {
			name: 'colleagueID',
			type: 'numeric'
		}, {
			name: 'isActive',
			type: 'string'
		}]
	}
});