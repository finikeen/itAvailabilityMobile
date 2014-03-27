Ext.define('Adm.util.Util', {  
    extend: 'Ext.Component',   		
	
    initComponent: function() {
		return this.callParent( arguments );
    }, 
    
    loaderXTemplateRenderer: function(loader, response, active) {
        var tpl = new Ext.XTemplate(response.responseText);
        var targetComponent = loader.getTarget();
        var cleanArr = Ext.create( 'Adm.util.TemplateDataUtil' ).prepareTemplateData( targetComponent.store );
        targetComponent.update( tpl.apply( cleanArr ) );
        return true;
    }
});