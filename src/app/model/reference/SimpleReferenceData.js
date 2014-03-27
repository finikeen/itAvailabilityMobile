Ext.define('Adm.model.reference.SimpleReferenceData',{
    extend:'Adm.model.reference.AbstractReference',
    config: {
		fields: [{
			name: 'id',
			type: 'string'
		}, {
			name: 'name',
			type: 'string'
		}]
	}
});