Ext.define('Adm.controller.PhoneListViewController', {
    extend: 'Deft.mvc.ViewController',
    inject: {
        apiProperties: 'apiProperties',
		authUser: 'authenticatedUser',
        appEventsController: 'appEventsController',
        formUtils: 'formRendererUtils',
        overrides: 'overrides',
        contactService: 'contactService',
        outOfOfficeService: 'outOfOfficeService',
        store: 'contactsStore'
    },
	config: {
		filters: [],
		userData: null
	},
    control: {
        view: {
            disclose: 'onDisclose'
        },
		'toggleOutBtn': {
			tap: 'onToggleOutTap'
		},
		'toggleOnCallBtn': {
			tap: 'onToggleOnCallTap'
		},
		'searchBtn': {
			tap: 'onSearchTap'
		},
		statusButton: {
			selector: '#statusBtn',
			listeners: {
				change: 'onStatusChange'
			}
		},
		searchField: {
			selector: '#searchFld',
			listeners: {
				keyup: 'onSearchKeyUp',
				clearicontap: 'onSearchClear'
			}
		},
		searchToolbar: '#searchTB'
    },
    
    init: function(){
        var me = this;
        var search;
        me.overrides.applyOverrides();
        me.loadData();
        
        me.appEventsController.assignEvent({
            eventName: 'updateStatus',
            callBackFunc: me.onUpdateStatus,
            scope: me
        });
        
		if (Ext.os.deviceType != 'Phone') {
			me.getSearchBtn().hide();
			search = new Ext.field.Search({
				listeners: {
					keyup: me.onSearchKeyUp,
					clearicontap: me.onSearchClear
				},
				align: 'right'
			});
			me.getView().down('titlebar').add(search);
		}
        
        return me.callParent(arguments);
    },
	
	loadData: function() {
		var me = this;
        var myId = (521272 * 4567);
		if (me.authUser.get('TARTANID')) {
			myId = (me.authUser.get('TARTANID') * 4567);
		}
		
		me.getView().setMasked({
			xtype: 'loadmask'
		})
		
        Ext.Ajax.request({
            url: me.apiProperties.getProxy(me.apiProperties.getItemUrl('contacts')).url + '.json?myid=' + myId,
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            },
            success: function(response, view){
                var r = Ext.decode(response.responseText);
				
                me.store.setData(r.rows);
				
				me.getView().setMasked(false);
            },
            failure: me.apiProperties.handleError
        }, me);
	},
    
    onDisclose: function(list, record){
    	var me = this;
    	
        // fix some variables for display
		// out of office display
		var oooDisplay = '';
		if (record.get('startTime')) {
			oooDisplay = Ext.Date.format(record.get('startTime'), 'm/d/y g:iA');
			if (record.get('')) {
				oooDisplay += ' - ' + Ext.Date.format(record.get('endTime'), 'm/d/y g:iA');
			}
		}
		record.set('oooDisplay', oooDisplay);
		
		// create the details display template
		var template = new Ext.XTemplate(
			'<tpl if="outOfOffice == true">' +
				'<div style="color:red; text-align:center;">Out of Office</div>' +
				'<div style="text-align:center;">{oooDisplay}</div>' +
				'<div style="text-align:center;">{eventType}</div>' +
			'<tpl else>' +
				'<div style="color:blue;text-align:center;">In Office</div>' +
			'</tpl>' +
			'<div style="text-align:center;">' +
				'<img src="{imgLink}" height="140" alt="{fullname}"><br/>' +
				'<b>{title}</b>' +
			'</div>' +
			'<div style="width: 270px; margin: 0 auto; text-align: left;">' +
				'Supervisor: <b>{supervisorName}</b><br/>' +
				'Phone: <b><a style="text-decoration:none;" href="tel:{phoneSCC}">{phoneSCC}</a></b><br/>' +
				'Location: <b>{location}</b>' +
			'</div>' +
			'<div style="text-align: center;"><b>Emergency Contact Info</b></div>' +
			'<div style="width: 270px; margin: 0 auto;">'  +
				'SCC Phone: <b><a style="text-decoration:none;" href="tel:{phoneSCCMobile}">{phoneSCCMobile}</a></b><br/>' +
				'Mobile: <b><a style="text-decoration:none;" href="tel:{phonePersonalMobile}">{phonePersonalMobile}</a></b><br/>' +
				'Home: <b><a style="text-decoration:none;" href="tel:{phoneHome}">{phoneHome}</a></b>' +
			'</div>' +
			'<div style="text-align: center;"><b>Current Schedule</b></div>' +
			'<div style="width: 270px; margin: 0 auto;">'  +
				'<table width="100%" cellpadding="1" cellspacing="0" border="1">' +
				'<tpl for="schedule">' +
				'<tr>' +
					'<td>{dayOfWeek}</td>' +
					'<tpl if="startTime">' +
						'<td>{startTime} to {endTime}</td>' +
					'<tpl else>' +
						'<td>&nbsp;</td>' +
					'</tpl>' +
				'</tr>' +
				'</tpl>' +
				'</table>' +
			'</div>'
		);
		this.getView().up('phonenavview').setNavigationBar({
			hidden: false,
			ui: 'light'
		});
        this.getView().up('phonenavview').push({
            xtype: 'phonedetail',
			title: record.get('fullname'),
			html: template.apply(record.data)
        })
    },
	
	onToggleOutTap: function(button) {
		var me = this;
		if (button.getIsPressed()) {
			var outFilter = new Ext.util.Filter({
				filterFn: function(item){
					return item.get('outOfOffice') == true;
				},
				id: 1
			});
			
			me.getFilters().push(outFilter);
		} else {
			Ext.Array.each(me.getFilters(), function(item,index,count) {
				if (item.getId() === 1) {
					Ext.Array.remove(me.getFilters(),item);
				}
			});
		}
		
		me.filterStore();
	},
	
	onToggleOnCallTap: function(button) {
		var me = this;
		if (button.getIsPressed()) {
			var outFilter = new Ext.util.Filter({
				filterFn: function(item){
					return item.get('isOnCall') == true;
				},
				id: 2
			});
			
			me.getFilters().push(outFilter);
		} else {
			Ext.Array.each(me.getFilters(), function(item,index,count) {
				if (item.getId() === 2) {
					Ext.Array.remove(me.getFilters(),item);
				}
			});
		}
		
		me.filterStore();
	},
	
	filterStore: function() {
		var me = this;
		me.store.clearFilter();
		
		me.store.filter(me.getFilters());
		
		me.getView().refresh();
	},
	
	onSearchTap: function(button, e, eOpts) {
		var me = button.up('list').getController();
		
		if (me.getSearchToolbar().isHidden()) {
			me.getSearchToolbar().show();
		} else {
			me.getSearchToolbar().hide();
		}
	},
	
	onSearchKeyUp: function(searchfield, e, eOpts) {
		var me = searchfield.up('list').getController();
		var val = searchfield.getValue();
		
		if (val.length) {
			Ext.Array.each(me.getFilters(), function(item,index,count) {
				if (item.getId() === 3) {
					Ext.Array.remove(me.getFilters(),item);
				}
			});
			var qry = new RegExp(val, 'i');
			var nameFilter = new Ext.util.Filter({
				filterFn: function(item){
					return item.get('fullname').match(qry);
				},
				id: 3
			});
			
			me.getFilters().push(nameFilter);
		
			me.filterStore();
		}
	},
	
	onSearchClear: function(searchfield, e, eOpts) {
		var me = searchfield.up('list').getController();;
		
		Ext.Array.each(me.getFilters(), function(item,index,count) {
			if (item.getId() === 3) {
				Ext.Array.remove(me.getFilters(),item);
			}
		});
		
		me.filterStore();
	},
    
    onStatusChange: function(toggle, newValue, oldValue){
        var me = this;
		var data = {};
		
		if (newValue === 0) {
			// add new ooo record
			data.tartanId = me.getUserData().tartanId;
			data.startDate = Ext.Date.format(new Date(), 'm/d/Y');
			data.startTime = Ext.Date.format(new Date(), 'H:i:s');
			data.eventType = 'Private';
			data.isAllDay = 0;
			
			me.outOfOfficeService.save(data, {
                success: me.saveSuccess,
                failure: me.saveFailure,
                scope: me
            });/*  */
		} else {
			// update current ooo record
			data.id = me.getUserData().outOfOfficeId;
			data.endDate = Ext.Date.format(new Date(), 'm/d/Y');
			data.endTime = Ext.Date.format(new Date(), 'H:i:s');
			
			me.outOfOfficeService.updateData(data, {
                success: me.saveSuccess,
                failure: me.saveFailure,
                scope: me
            });/*  */
		}
    },
    
    saveSuccess: function(response, scope){
        var me = scope;
        
		me.updateStatus();
		
		me.loadData();
    },
    
    saveFailure: function(response, scope){
        var me = scope;
        
        console.log("saveFailure: ");
        console.log(response);
    },
    
    onUpdateStatus: function(scope){
        var me = this;
        
        this.updateStatus();
    },
    
    updateStatus: function(){
        var me = this;
        
        me.contactService.getCurrentUserData({
            success: me.getCurrentUserDataSuccess,
            failure: me.getCurrentUserDataFailure,
            scope: me
        });
    },
    
    getCurrentUserDataSuccess: function(response, scope){
        var me = scope;
        var data = response.rows[0];
        
        me.setUserData(data);
		
		me.getStatusButton().suspendEvents();
        me.getStatusButton().setValue(!data.outOfOffice);
		me.getStatusButton().resumeEvents(true);
		
    },
    
    getCurrentUserDataFailure: function(response, scope){
        var me = scope;
        
        console.log("logoutFailure:");
        console.log(response);
    }
});
