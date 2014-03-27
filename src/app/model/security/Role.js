Ext.define('Adm.model.security.Role', {
    extend: 'Adm.model.AbstractBase',
    config: {
		fields: [{
			name: 'ROLEID',
			type: 'numeric'
		}, {
			name: 'ROLE',
			type: 'string'
		}, {
			name: '_ACCESS',
			type: 'auto'
		}]
	}
});