/**
 * @author RWeneck
 *
 * Adapted from https://github.com/ghuntley/Ext.ux.touch.DateTimePicker
 *
 */
Ext.define('Adm.ux.picker.Time', {
    extend: 'Ext.Picker',
    xtype: 'timepicker',
    
    
    config: {
        /**
         * @cfg {String/Number} value The value to initialize the picker with
         * @accessor
         */
        value: "6:00 AM",
        /**
         * @cfg {String} hourText
         * The label to show for the hour column. Defaults to 'Hour'.
         */
        hourText: 'Hour',
        /**
         * @cfg {String} minuteText
         * The label to show for the minute column. Defaults to 'Minute'.
         */
        minuteText: 'Minute',
        /**
         * @cfg {String} minuteIncrement
         * The increment for the minute column. Defaults to 'Minute'.
         */
        minuteIncrement: 15,
        /**
         * @cfg {String} daynightText
         * The label to show for the daynight column. Defaults to 'AM/PM'.
         */
        daynightText: 'AM/PM',
        /**
         * @cfg {Array} slotOrder
         * An array of strings that specifies the order of the slots. Defaults to <tt>['hour', 'minute', 'daynight']</tt>.
         */
        slotOrder: ['hour', 'minute', 'daynight']
    
    
    },
    // @private
    initialize: function(){
        var me = this;
        
        var hours = [], minutes = [], daynight = [], i;
        
        for (i = 1; i <= 12; i++) {
            hours.push({
                text: i,
                value: i
            });
        }
        
        
        for (i = 0; i < 60; i += this.getMinuteIncrement()) {
            minutes.push({
                text: i < 10 ? '0' + i : i,
                value: i
            });
        }
        
        
        daynight.push({
            text: 'AM',
            value: 'AM'
        }, {
            text: 'PM',
            value: 'PM'
        });
        
        
        
        var newSlots = [];
        Ext.each(this.getSlotOrder(), function(item){
            newSlots.push(this.createSlot(item, hours, minutes, daynight));
        }, this);
        
        this.setSlots(newSlots);
        this.callParent(arguments);
    },
    createSlot: function(name, hours, minutes, daynight){
        switch (name) {
            case 'hour':
                return {
                    name: 'hour',
                    align: 'center',
                    data: hours,
                    title: this.getUseTitles() ? this.getHourText() : false,
                    flex: 2
                };
            case 'minute':
                return {
                    name: 'minute',
                    align: 'center',
                    data: minutes,
                    title: this.getUseTitles() ? this.getMinuteText() : false,
                    flex: 2
                };
            case 'daynight':
                return {
                    name: 'daynight',
                    align: 'center',
                    data: daynight,
                    title: this.getUseTitles() ? this.getDaynightText() : false,
                    flex: 2
                };
        }
    },
    
    
    /**
     * Takes a String or an object that represents time,
     * The object should contain the keys; hour, minute, daynight
     * or the string should be in the format of "11:00 AM"
     */
    setValue: function(value, animated){
        if (!value) {
            value = {
                hour: 05,
                minute: 00,
                daynight: "PM"
            }
        }
        if (typeof value == "string") {
            var hour, minute, daynight;
            value = value.trim();
            hour = value.substring(0, value.indexOf(":"));
            minute = value.substring(value.indexOf(":") + 1, value.indexOf(" "));
            daynight = value.substring(value.indexOf(" ") + 1);
            
            value = {
                hour: hour,
                minute: minute,
                daynight: daynight
            }
        }
        if (typeof value == "object") {
            if (Ext.isDate(value)) {
                value = {
                    hour: Ext.Date.format(value, 'h'),
                    minute: Ext.Date.format(value, 'i'),
                    daynight: Ext.Date.format(value, 'A')
                }
            }
            else {
                value = {
                    hour: value.hour,
                    minute: value.minute,
                    daynight: value.daynight
                }
            }
        }
        this.callParent(arguments);
        
        for (key in value) {
            slot = this.child('[name=' + key + ']');
            if (slot) {
                if (key === 'hour' && value[key] > 12) {
                    daynightVal = 'PM';
                    value[key] -= 12;
                }
                if (key === 'minute') {
                    var modulo = value[key] % this.getMinuteIncrement();
                    if (modulo > 0) {
                        value[key] = Math.round(value[key] / this.getMinuteIncrement()) * this.getMinuteIncrement();
                    }
                }
				if (key === 'hour') {
					value[key] = parseInt(value[key]);
				}
                
                slot.setValue(value[key], animated);
            }
        }
        return this;
    }
});
