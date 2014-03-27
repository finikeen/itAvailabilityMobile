Ext.Loader.setConfig({
	enabled: true,
	paths: {
		'Adm': '/availabilityMobile/app', // The project_name should match the directory of your project and is case sensitive.
		'ContextName': 'adm',
		'Ext': 'touch/src'
	}
});

Ext.syncRequire(["Ext.Component","Ext.ComponentManager","Ext.ComponentQuery","Deft.mixin.InjectAble","Deft.mixin.Controllable"]);