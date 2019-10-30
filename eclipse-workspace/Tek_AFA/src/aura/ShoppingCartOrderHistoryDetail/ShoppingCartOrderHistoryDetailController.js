({
	init : function(component, event, helper) {
		helper.loadOrderDetail(component);
	},
    
    goToDetails : function(component, event, helper) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var material;
        var lineItems = component.get("v.lineItems");
        
        for(var i = 0; i < lineItems.length; i++)
        {
            if(lineItems[i].Record.Marketing_Material__r.Id == materialId)
            {
                material = lineItems[i].MarketingMaterial;
                break;
            }
                
        }
        
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "MaterialDetailsView",
            "MarketingMaterial" : material,
            "ReturnLocation": "OrderHistoryView"
        });
        newEvent.fire();
        
    },
    
    reorderLineItems : function(component, event, helper) {
        helper.reorderLineItems(component);
    },
    
    onOpenEmailBuilderClick : function(component, event, helper) {
        helper.openEmailBuilderFromButton(component, event);
    },
    
    onOpenAppointmentSchedulerClick : function(component, event, helper) {
        helper.openAppointmentSchedulerFromButton(component, event);
    }
})