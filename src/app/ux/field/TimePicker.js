/**
 * TimePickerfield. Extends from datepickerfield
 */
Ext.define('Adm.ux.field.TimePicker', {
    extend: 'Ext.field.DatePicker',
    xtype: 'timepickerfield',
    requires: ['Adm.ux.picker.Time'],
    config: {
        dateFormat: 'g:i A', //Default format show time only
        picker: true
    },
    
    /**
     * @override
     * @param value
     * Source copied, small modification
     */
    applyValue: function(value){
        if (!Ext.isDate(value) && !Ext.isObject(value)) {
            value = null;
        }
        // Begin modified section
        if (Ext.isObject(value)) {
            var date = new Date(), year = value.year || date.getFullYear(), // Defaults to current year if year was not supplied etc..
 month = value.month || date.getMonth(), day = value.day || date.getDate();
            
            if (value.daynight === 'PM') {
                value.hour += 12;
            }
            
            value = new Date(year, month, day, value.hour, value.minute); //Added hour and minutes
        }
        // End modfied section!
        return value;
    },
    
    
    applyPicker: function(picker){
        picker = Ext.factory(picker, 'Adm.ux.picker.Time');
        picker.setHidden(true); // Do not show picker on creeation
        Ext.Viewport.add(picker);
        return picker;
    },
    
    
    updatePicker: function(picker){
        picker.on({
            scope: this,
            change: 'onPickerChange',
            hide: 'onPickerHide'
        });
        picker.setValue(this.getValue());
        return picker;
    }
});
