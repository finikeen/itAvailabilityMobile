Ext.define('Adm.util.Constants',{
	extend: 'Ext.Component',
	
    statics: {
    	/* 
    	 * id values referenced in the restrictedIds Array will be restricted
    	 * from administrative functionality through the use of a
    	 * test against a supplied id value. In general, these
    	 * items are critically linked to other operations in the UI,
    	 * such as a field value like 'Other' which displays a description
    	 * field to collect additional associated data.
    	 * 
    	 * For example:
    	 * This method can be used inside a function call from a button or other
    	 * interface item to determine if the item is restricted. 
    	 * Scm.util.Constants.isRestrictedAdminItemId( selection.get('id')  )
    	 * 
    	 */
    	isRestrictedAdminItemId: function( id ){
    		var restrictedIds = [
    		        	Adm.util.Constants.EDUCATION_GOAL_OTHER_ID
    		        ];
    		return ((Ext.Array.indexOf( restrictedIds, id ) != -1)? true : false);
    	},
    	
    	// APPLICATION ID - USED FOR SECURITY SANDBOX
		// MUST MATCH THE APPLICATION ID GENERATED BY THE APP.ADMIN TOOL
		APPLICATION_ID: 74,
        
        // CAN BE APPLIED TO THE LABEL OF A FIELD TO SHOW A RED REQUIRED ASTERISK
        REQUIRED_ASTERISK_DISPLAY: '<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>',
        
        // CONFIGURES THE MESSAGE DISPLAYED NEXT TO THE SAVE BUTTON FOR TOOLS WHERE A SAVE IS ON A SINGLE SCREEN
        // FOR EXAMPLE: THIS FUNCTIONALITY IS APPLIED TO THE STUDENT INTAKE TOOL, ACTION PLAN STRENGTHS AND CONFIDENTIALITY DISCLOSURE AGREEMENT
        DATA_SAVE_SUCCESS_MESSAGE_STYLE: "font-weight: 'bold'; color: rgb(0, 0, 0); padding-left: 2px;",
        DATA_SAVE_SUCCESS_MESSAGE: '&#10003 Data was successfully saved',
        DATA_SAVE_SUCCESS_MESSAGE_TIMEOUT: 3000
    },

	initialize: function() {
		return this.callParent( arguments );
    }
});