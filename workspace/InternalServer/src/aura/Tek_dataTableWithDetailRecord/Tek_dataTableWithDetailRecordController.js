({
	doInit : function(component, event, helper) {
         var action =component.get("c.getAccList");
        action.setCallback(this,function(acts){
            component.set("v.accounts",acts.getReturnValue());
        });
		 $A.enqueueAction(action);
	},
    
    detailRec:function(component,event,helper){
        var account=component.get("v.accounts");
        var selectedItem= event.currentTarget;
        var index = selectedItem.dataset.record;
        component.set("v.show",'true');
        component.set("v.account1", account[index]);
    }
})