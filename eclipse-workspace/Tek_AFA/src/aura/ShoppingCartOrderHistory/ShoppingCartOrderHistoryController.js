({
	loadOrderHistory : function(component, event, helper) {
		helper.loadOrderHistory(component, helper);
	},
	
	onCategoryHomeClick : function(component, event, helper) {
		var navigateEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        navigateEvent.setParams({
            "navigate" : 'HomePageView'
        });
        navigateEvent.fire();
	},

	handleGridRowAction : function(component, event, helper) {
		var eventSourceGrid = event.getSource();
		var gridId = eventSourceGrid.getLocalId();
		var actionName = event.getParam("actionName");
		var record = event.getParam("record");
		
		if (gridId == "myOrderHistoryGrid") {
		    if (actionName == "Reorder") {
		        helper.reorder(component, record);
		    }
		    
		    if (actionName == "ViewConfirmation") {
		    	helper.viewConfirmation(component, record);
		    }
		}
	},
	
	openOrderDetails : function(component, event, helper) {
		var link = event.currentTarget;
		var orderId = link.getAttribute("data-recId");
		
		helper.loadOrderDetails(component, orderId);
	},
	
	backToOrderHistory : function(component, event, helper) {
		helper.hideOrderDetails(component);
	}
})