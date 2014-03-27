Ext.define('Adm.view.PhoneList', {
    extend: 'Ext.dataview.List',
    xtype: 'phonelist',
    alias: 'widget.phonelist',
    controller: 'Adm.controller.PhoneListViewController',
    inject: {
        store: 'contactsStore'
    },
	requires: [
		'Ext.ux.touch.PullRefreshFn',
		'Adm.view.ToggleButton',
		'Ext.field.Toggle',
		'Ext.field.Search'
	],
    config: {
        fullscreen: true,
        grouped: true,
        store: this.store,
        onItemDisclosure: true,
		navigationBar: false,
		cls: 'phone-list',
		itemHeight: 26,
		itemTpl: new Ext.XTemplate(
			'<span class="phone-list-phone-item"><a style="text-decoration:none;" href="tel:{phoneSCC}">{phoneSCC}</a></span>',
			'<tpl if="outOfOffice">',
				'<span class="icon-out">&nbsp;&nbsp;&nbsp;&nbsp;</span>',
			'</tpl>',
			'<tpl if="isOnCall">',
				'<span class="icon-oncall">&nbsp;&nbsp;&nbsp;&nbsp;</span>',
			'</tpl>',
			'<span class="phone-list-item">{fullname}</span>'),
		items: [{
			xtype: 'titlebar',
			docked: 'top',
			layout: {
				pack: 'center',
				type: 'hbox'
			},
			title: 'IT Phone List',
			padding: '4 0 4 0',
			ui: 'SCCToolbar',
			items: [{
				xtype: 'button',
				iconCls: 'search',
				iconMask: true,
				itemId: 'searchBtn',
				align: 'left',
				hidden: !Ext.os.deviceType == 'Phone'
			},{
				xtype: 'togglebtn',
				ui: 'default',
				iconCls: 'out_of_office',
				iconMask: true,
				itemId: 'toggleOutBtn',
				align: 'left'
			}, {
				xtype: 'togglebtn',
				ui: 'default',
				iconCls: 'on_call',
				iconMask: true,
				itemId: 'toggleOnCallBtn',
				align: 'left'
			}, {
				xtype: 'togglefield',
				cls: 'in-out',
				itemId: 'statusBtn',
				label: ' ',
				labelWidth: 0,
				labelCls: 'in-out-label',
				align: 'left'
			}]
		}, {
			xtype: 'toolbar',
			docked: 'top',
			layout: {
				pack: 'center',
				type: 'hbox'
			},
			hidden: true,
			itemId: 'searchTB',
			padding: '4 0 4 0',
			ui: 'light',
			items: [{
				xtype: 'searchfield',
				itemId: 'searchFld',
				flex: 1
			}, {
				xtype: 'spacer',
				flex: 2
			}]
		}],
		plugins: [{
			xclass: 'Ext.ux.touch.PullRefreshFn',
			pullText: 'Pull down to update the list...',
			refreshFn: function(plugin) {
				this.up('list').getController().loadData();
			},
			releaseText: 'Release to update...',
			hidden: true
			
		}]
    }
});
