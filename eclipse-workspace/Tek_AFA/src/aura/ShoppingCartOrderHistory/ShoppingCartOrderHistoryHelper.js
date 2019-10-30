({
    orderHistoryGridRowActions : [
        {Label: "Reorder", ActionName: "Reorder", Type: "Button", Class: "af-reorder-button"}
        //{Label: "View Confirmation", ActionName: "ViewConfirmation", Type: "Link", Class: "slds-p-left_medium"}
    ],
    
    loadOrderHistory : function(component, helper) {
        helper.hideOrderDetails(component);
        helper.loadMyOrderHistory(component, helper);
        helper.loadOnMyBehalfOrderHistory(component, helper);
    },
    
    loadMyOrderHistory : function(component, helper) {
        var myOrderHistoryGrid = component.find('myOrderHistoryGrid');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        var whereClause = "CreatedById ='" + userId + "'";
        whereClause += " AND Status__c != 'In Progress'";
        
        myOrderHistoryGrid.set('v.whereClause', whereClause);
        myOrderHistoryGrid.set('v.rowActions', this.orderHistoryGridRowActions);
        
        myOrderHistoryGrid.reloadRecords();
    },
    
    loadOnMyBehalfOrderHistory : function(component, helper) {
        var onMyBehalfOrderHistoryGrid = component.find('onMyBehalfOrderHistoryGrid');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        var whereClause = "Colleague__c ='" + userId + "' AND CreatedById != '" + userId + "'";
        whereClause += " AND Status__c != 'In Progress'";
        
        onMyBehalfOrderHistoryGrid.set('v.whereClause', whereClause);
        onMyBehalfOrderHistoryGrid.set('v.rowActions', this.orderHistoryGridRowActions);
        
        onMyBehalfOrderHistoryGrid.reloadRecords();	
    },
    
    reorder : function(component, orderRecord) {
		var reOrderAction = component.get("c.ReOrderFromHistory");
		
		reOrderAction.setParams({
			"orderHistoryOrderId": orderRecord.Id
		});
        
        reOrderAction.setCallback(this, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
                var allItemsAdded = result.getReturnValue();
                this.reloadCart(component);
                
                if(allItemsAdded)
                    this.showToast('success', 'Your cart has been updated');
                else
                    this.showToast('warning', $A.get("$Label.Shopping_Cart_Reorder_Not_All_Items_Added")); 
            	
                this.navigateToCart(component);
                
            }
            else if (component.isValid() && state !== "SUCCESS") {
            	var errors = result.getError();
                if (errors && Array.isArray(errors) && errors.length > 0)
                {
                    let errorData = JSON.parse(errors[0].message);
                    this.showToast('error', errorData.message);
                }
            }
        });
        $A.enqueueAction(reOrderAction);
    },
    
    viewConfirmation : function(component, record) {
        var navigateEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        navigateEvent.setParams({
            "navigate" : 'OrderConfirmationView',
            "OrderId" : record.Id
        });
        navigateEvent.fire();
    },
    
    navigateToCart : function(component) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : 'CartReviewView'
        });
        newEvent.fire();
    },
    
    loadOrderDetails : function(component, orderId) {
        component.set('v.showOrderDetails', true);
        component.set('v.orderId', orderId);
    },
    
    hideOrderDetails : function(component) {
        component.set('v.showOrderDetails', false);
        component.set('v.orderId', null);
    },
    
    reloadCart : function(component) {
		var reloadCartEvent = component.getEvent("reloadCart");
		reloadCartEvent.fire();
	},
    
    showToast : function(type, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": Message,
            "type": type
        });
        toastEvent.fire();
    },
})