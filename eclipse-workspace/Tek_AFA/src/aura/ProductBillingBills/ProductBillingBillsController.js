({
    doInit : function(component, event, helper) {
    	helper.reset(component);
        helper.loadBills(component);
    },

    onBillFilterChange : function(component, event, helper) {
    	helper.reset(component);
        helper.loadBills(component);
    },

    closeQuickAction : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})