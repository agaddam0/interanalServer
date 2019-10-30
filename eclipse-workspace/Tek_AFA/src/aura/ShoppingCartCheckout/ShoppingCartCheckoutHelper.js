({
	fireShoppingCartNavigationEvent : function(navigate) {
		var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : navigate
        });
        newEvent.fire();
	},
	
	submitOrder : function(component) {
		var helper = this;
		var cart = component.get('v.cart');
        
		component.set('v.submitException', null);
		
		var submitOrderAction = component.get("c.submitOrder");
		
		submitOrderAction.setParams({
			"orderId": cart.Id
		});
        
        submitOrderAction.setCallback(this, function(result){
            var state = result.getState();
            var submitResult = result.getReturnValue();

            if(component.isValid() && state === "SUCCESS") {
            	helper.reloadCart(component);
            	helper.viewOrderConfirmation(component, cart.Id);
            }
            else if (component.isValid() && state !== "SUCCESS") {
            	var error = result.getError();
            	component.set('v.exception', error);
            	helper.showFieldErrors(component, error);
            }
        });
        $A.enqueueAction(submitOrderAction);
	},
	
	reloadCart : function(component) {
		var reloadCartEvent = component.getEvent("reloadCart");
		reloadCartEvent.fire();
	},
	
	viewOrderConfirmation : function(component, orderId) {
        var navigateEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        navigateEvent.setParams({
            "navigate" : 'OrderConfirmationView',
            "OrderId" : orderId
        });
        navigateEvent.fire();
    },
    
    cancelOrder : function(component) {
    	var helper = this;
    	var cart = component.get('v.cart');
    	
    	var deleteOrderAction = component.get("c.deleteOrder");
		
		deleteOrderAction.setParams({
			"orderId": cart.Id
		});
        
        deleteOrderAction.setCallback(this, function(result){
            var state = result.getState();
            var submitResult = result.getReturnValue();

            if(component.isValid() && state === "SUCCESS") {
            	helper.reloadCart(component);
            	helper.fireShoppingCartNavigationEvent('HomePageView');
            	helper.showSuccessToast("The order was cancelled.");
            }
            else if (component.isValid() && state !== "SUCCESS") {
            	var error = result.getError();
            	component.set('v.exception', error);
            }
        });
        $A.enqueueAction(deleteOrderAction);
    },
    
    saveChangedOrder : function(component) {
    	var helper = this;
    	helper.saveOrder(component, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
            	helper.reloadCart(component);
            }
            else if (component.isValid() && state !== "SUCCESS") {
            	var error = result.getError();
            	component.set('v.exception', error);
            }
        });
    },
    
    saveShippingAddress : function(component) {
    	var helper = this;
    	helper.saveOrderWithoutReloading(component);
    },
    
    saveShippingMethod : function(component, event) {
    	var helper = this;
    	helper.saveOrderWithoutReloading(component);
        
        var picklistValue = event.getParam("values");
        
        if(picklistValue == 'UPS 3-Day') {
            component.set('v.showRushOrderModal', true);
        }
        
    },
    
    saveOrder : function(component, actionCallback) {
    	var helper = this;
    	var cart = component.get('v.cart');
    	
    	var saveOrderOnChangeAction = component.get("c.saveOrderOnChange");
		
		saveOrderOnChangeAction.setParams({
			"order": cart
		});
        
        saveOrderOnChangeAction.setCallback(this, actionCallback);
        $A.enqueueAction(saveOrderOnChangeAction);
    },
    
    saveOrderWithoutReloading : function(component) {
    	var helper = this;
    	helper.saveOrder(component, function(result){
    		var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
            	// Don't reload component
            }
            else if (component.isValid() && state !== "SUCCESS") {
            	var error = result.getError();
            	component.set('v.exception', error);
            }
    	
    	});
    },
    
    onShipToChanged : function(component, shipTo) {        
    	var helper = this;
    	helper.saveChangedOrder(component);
    },

    showFieldErrors : function(component, error) {
    	var helper = this;
    	
    	if (!error || !error.length || !error[0].fieldErrors) {
    		return;
    	}
    	
    	var fieldErrors = error[0].fieldErrors;
    	
    	for (let field in fieldErrors) {
        	let errors = fieldErrors[field];
        	
        	let fieldComponent = component.find(field);
        	
        	if (fieldComponent) {
        		fieldComponent.set('v.errors', errors);
        		
        		if (typeof fieldComponent.showError === "function") {
        			fieldComponent.showError(errors[0].message);
        		}
        	}
        }
    },

	showSuccessToast : function(successMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": successMessage,
	        "type": 'success'
	    });
	    toastEvent.fire();
	}
})