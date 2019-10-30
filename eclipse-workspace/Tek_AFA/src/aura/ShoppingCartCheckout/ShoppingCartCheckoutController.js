({
	cancelOrderClicked : function(component, event, helper) {
		component.set('v.showCancelOrderConfirmation', true);
	},
    
    navigateToCart : function(component, event, helper) {
		helper.fireShoppingCartNavigationEvent('CartReviewView');
	},

	onSubmitOrder : function(component, event, helper) {
		helper.submitOrder(component);
	},
	
	onModalButtonClick : function(component, event, helper) {
		var modal = event.getSource();
		var modalAuraId = modal.getLocalId();
		
		if (modalAuraId == "cancelOrderConfirmationModal") {
			helper.cancelOrder(component);
		}
        
        if (modalAuraId == 'rushOrderModal') {
            component.set('v.showRushOrderModal', false);
        }
	},
	
	onOrderChanged : function(component, event, helper) {
		helper.saveChangedOrder(component);
	},
	
	handleColleagueChange : function(component, event, helper) {
		var oldValue = event.getParam("oldValue");
		var newValue = event.getParam("value");
		
		/* When lookup value changes the old or new value is the record id and a string.
           When this component is first loaded, the old or new value's are proxy object so ignore those. */
		if (((oldValue && typeof oldValue === "string") ||
		    (newValue && typeof newValue === "string")) &&
		    oldValue != newValue) {

			helper.saveChangedOrder(component);
		}
	},
	
	onPicklistChange : function(component, event, helper) {
		var fieldName = event.getParam("fieldName");
		var values = event.getParam("values");
        
        if (fieldName === "Ship_To__c") {
        	helper.onShipToChanged(component, values);
        }
        
        // This is actually for the Shipping_State__c on the Order object
        // I chose a picklist field that populates the picklist component
        // with all of the states, but then we are saving the actual value
        // to an open form field Shipping_State__c
        if ( fieldName === "AnnBeforeTaxState__c") {
            helper.saveShippingAddress(component);
        }
        
        if (fieldName === "Shipping_Method__c") {
        	helper.saveShippingMethod(component, event);
        }
	},
	
	saveShippingAddress : function(component, event, helper) {
		helper.saveShippingAddress(component);
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
            "ReturnLocation": "CartReviewView"
        });
        newEvent.fire();
        
    },
})