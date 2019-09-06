({
	addRow : function(component, event, helper) {
		helper.addAccountRecord(component, event);
	},
    removeRow : function(component,event,helper){
        var accountlist = component.get('v.accountlist');
        var selectedItem= event.currentTarget;
        
        var index = selectedItem.dataset.record;
       
        accountlist.splice(index, 1);
        component.set("v.accountlist", accountlist);
    },
    save : function(component,event,helper){
        if (helper.validateAccountList(component, event)) {
            helper.saveAccountList(component, event);
        }
    }
})