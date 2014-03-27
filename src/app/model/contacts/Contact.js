Ext.define('Adm.model.contacts.Contact', {
    extend: 'Adm.model.AbstractBase',
	config: {
		fields: [{
			name: 'fullname',
			type: 'string'
		}, {
			name: 'tartanId',
			type: 'string'
		}, {
			name: 'title',
			type: 'string'
		}, {
			name: 'deptId',
			type: 'numeric'
		}, {
			name: 'isDepartmentHead',
			type: 'boolean'
		}, {
			name: 'departmentName',
			type: 'string'
		}, {
			name: 'parentDeptId',
			type: 'numeric'
		}, {
			name: 'location',
			type: 'string'
		}, {
			name: 'supervisorUserId',
			type: 'string'
		}, {
			name: 'supervisorName',
			type: 'string'
		}, {
			name: 'phoneSCC',
			type: 'string'
		}, {
			name: 'phoneSCCMobile',
			type: 'string'
		}, {
			name: 'phonePersonalMobile',
			type: 'string'
		}, {
			name: 'phoneHome',
			type: 'string'
		}, {
			name: 'email',
			type: 'string'
		}, {
			name: 'isOnCall',
			type: 'boolean'
		}, {
			name: 'outOfOffice',
			type: 'boolean'
		}, {
			name: 'outOfOfficeId',
			type: 'string'
		}, {
			name: 'startTime',
			type: 'date'
		}, {
			name: 'endTime',
			type: 'date'
		}, {
			name: 'eventType',
			type: 'string'
		}, {
			name: 'following',
			type: 'string'
		}, {
			name: 'schedule',
			convert: function(v, record){
				if (v) {
					return JSON.parse(v);
				}
				else {
					return '';
				}
			}
		}, {
			name: 'imgLink',
			type: 'string'
		}]
	}
});