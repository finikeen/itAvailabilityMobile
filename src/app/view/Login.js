Ext.define('Adm.view.Login', {
	extend: 'Ext.form.Panel',
	xtype: 'loginview',
	alias: 'widget.loginview',
	controller: 'Adm.controller.LoginViewController',
	requires: [
		'Ext.form.FieldSet',
		'Ext.form.Password',
		'Ext.Label',
		'Ext.Img'
	],
	config: {
		title: 'Login',
		items: [{
			xtype: 'image',
			src: Ext.Viewport.getOrientation() == 'portrait' ? 'resources/images/lock.png' : 'resources/images/lock-small.png',
			style: Ext.Viewport.getOrientation() == 'portrait' ? 'width:80px;height:80px;margin:auto;' : 'width:40px;height:40px;margin:auto'
		}, {
			xtype: 'label',
			html:'Login failure: please check your username/password',
			itemId: 'signInFailedLbl',
			hidden: true,
			hideAnimation: 'fadeOut',
			showAnimation: 'fadeIn',
			style: 'color:#990000;margin:5px 0px;'
		}, {
			xtype: 'fieldset',
			title: 'Please login to continue',
			items: [{
				xtype: 'textfield',
				placeHolder: 'Network User ID',
				itemId: 'usernameTxt',
				name: 'username',
				required: true,
				value: 'brian.cooney'
			}, {
				xtype: 'passwordfield',
				placeHolder: 'Password',
				itemId: 'passwordTxt',
				name: 'password',
				required: true,
				value: 'fqL8VTUD'
			}]
		}, {
			xtype: 'button',
			itemId: 'loginBtn',
			ui: 'action',
			padding: '10px',
			text: 'Log In'
		}]
	}
})
