Ext.define('Adm.model.AbstractBase', {
    extend: 'Ext.data.Model',
    inject: {
        constants: 'constants'
    },
    config: {
        fields: []
    },
    
    populateFromGenericObject: function(record){
        if (record != null) {
            for (fieldName in this.data) {
                if (record[fieldName]) {
                    this.set(fieldName, record[fieldName]);
                }
            }
        }
    },
    
    getApplicationId: function(){
        return this.constants.APPLICATION_ID;
    }
    
});
