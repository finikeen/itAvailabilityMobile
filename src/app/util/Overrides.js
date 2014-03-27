Ext.define('Adm.util.Overrides', {
    Extend: 'Ext.Component',
    config: {
        inited: false
    },
    initComponent: function(){
        var me = this;
        return me.callParent(arguments);
    },
    getInited: function(){
        return this.inited
    },
    applyOverrides: function(){
        var me = this;
        if (me.inited == false) {
            me.inited = true;
            
            Ext.Ajax.defaultHeaders = {
                'Accept': 'application/json',
                'Content-Type': 'application/json; charset=utf-8'
            };
            
            // Date patterns for formatting by a description
            // rather than a date format
            Ext.Date.patterns = {
                ISO8601Long: "Y-m-d H:i:s",
                ISO8601Short: "Y-m-d",
                ShortDate: "n/j/Y",
                LongDate: "l, F d, Y",
                FullDateTime: "l, F d, Y g:i:s A",
                MonthDay: "F d",
                ShortTime: "g:i A",
                LongTime: "g:i:s A",
                SortableDateTime: "Y-m-d\\TH:i:s",
                UniversalSortableDateTime: "Y-m-d H:i:sO",
                YearMonth: "F, Y"
            };
            
            /*
             * Provide global asterisks next to required fields
             */
            Ext.Function.interceptAfter(Ext.form.Field.prototype, 'initComponent', function(){
                var fl = this.fieldLabel, ab = this.allowBlank;
                if (fl) {
                    this.labelStyle = Adm.util.Constants.APP_LABEL_STYLE;
                    ;
                }
                if (ab === false && fl) {
                    this.fieldLabel += Adm.util.Constants.REQUIRED_ASTERISK_DISPLAY;
                }
            });
            
            /*
             * Provide global asterisks next to required field containers
             */
            Ext.Function.interceptAfter(Ext.form.FieldContainer.prototype, 'initComponent', function(){
                var fl = this.fieldLabel, ab = this.allowBlank;
                if (fl) {
                    this.labelStyle = Adm.util.Constants.APP_LABEL_STYLE;
                }
                if (ab === false && fl) {
                    this.fieldLabel += Adm.util.Constants.REQUIRED_ASTERISK_DISPLAY;
                }
            });
            
            /*
             * Per Animal, http://www.extjs.com/forum/showthread.php?p=450116#post450116
             * Override to provide a function to determine the invalid
             * fields in a form.
             */
            Ext.override(Ext.form.BasicForm, {
                findInvalid: function(){
                    var result = [], it = this.getFields().items, l = it.length, i, f;
                    for (i = 0; i < l; i++) {
                        if (!(f = it[i]).disabled && f.isValid()) {
                            result.push(f);
                        }
                    }
                    return result;
                }
            });
            
            /*
             * Per Animal, http://www.extjs.com/forum/showthread.php?p=450116#post450116
             * Override component so that the first invalid field
             * will be displayed for the user when a form is invalid.
             */
            Ext.override(Ext.Component, {
                ensureVisible: function(stopAt){
                    var p;
                    this.parent.bubble(function(c){
                        if (p = c.parent) {
                            if (p instanceof Ext.TabPanel) {
                                p.setActiveTab(c);
                            }
                            else 
                                if (p.layout.setActiveItem) {
                                    p.layout.setActiveItem(c);
                                }
                                else 
                                    if (p.layout.type == 'accordion') {
                                        c.expand();
                                    }
                        }
                        return (c !== stopAt);
                    });
                    //this.el.scrollIntoView(this.el.up(':scrollable'));
                    return this;
                }
            });
        }
    }
});
