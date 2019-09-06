({
	doInit : function(component, event, helper) {
        var action = component.get('c.getconList');
        action.setParams({
            accountId:component.get('v.recordId'),
            
        });
        action.setCallback(this,function(results){
            
            component.set('v.contactList',results.getReturnValue());
        });
        $A.enqueueAction(action,false);
	}
})