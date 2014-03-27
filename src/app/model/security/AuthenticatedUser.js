Ext.define('Adm.model.security.AuthenticatedUser', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'USER',
			type: 'string'
		}, {
			name: 'FNAME',
			type: 'string'
		}, {
			name: 'LNAME',
			type: 'string'
		}, {
			name: 'TARTANID',
			type: 'numeric'
		}, {
			name: 'DEPTID',
			type: 'numeric'
		}, {
			name: 'EMAIL',
			type: 'string'
		}, {
			name: 'PASS',
			type: 'string'
		}, {
			name: 'ROLES',
			type: 'string'
		}, {
			name: 'AVAILABLEROLES',
			type: 'array'
		}, {
			name: 'CURRENTROLE',
			type: 'string'
		}, {
			name: 'CURRENTACCESSTYPES',
			type: 'array'
		}	/*
	 // this is how to use "type: object"
	 {name: 'CURRENTROLE',
	 convert: function(value, record){
	 return Ext.create('Adm.model.security.Role', {});
	 }
	 } */
		]
	},
			
	isDev: function() {
		return (this.get('CURRENTROLE') == 'Developer');
	},
	
	getFullname: function() {
		return this.get('FNAME') + ' ' + this.get('LNAME');
	},
	
	getTartanId: function() {
		return this.TARTANID;
	}
});