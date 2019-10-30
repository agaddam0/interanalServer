({
    addMaterialToCart : function(component, event) {
        var material = component.get("v.material");
        var quantity = component.get("v.quantity");
        
        if(quantity < material.Record.Quantity_Minimum__c || quantity > material.Record.Quantity_Maximum__c)
        {
            this.showErrorToast('Quantity ordered must fall within the Minimum and Maximum quantity.');
        }
        else
        {
            var action = component.get('c.addMarketingMaterialToCart');
            action.setParams({
                "marketingMaterial" : material.Record,
                "quantity" : quantity
            });
            
            action.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS") {
                    
                    // send event component to update line item count
                    var cartInformation = result.getReturnValue();
                    var event = $A.get("e.c:ShoppingCartOrderDetailsEvent");
                    event.setParams({
                        "Order" : cartInformation.Order,
                        "OrderLineItems" : cartInformation.OrderLineItems
                    });
                    event.fire();
                    
                    // show toast that item was successfully added to cart
                    this.showSuccessToast("Added to the cart successfully!")
                }
                else if (component.isValid() && state !== "SUCCESS") {
                    var errors = result.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0)
                    {
                        let errorData = JSON.parse(errors[0].message);
                        this.showErrorToast(errorData.message);
                    }
                }
            });
            $A.enqueueAction(action);
        }          
    },
    
    updateFavorite : function(component, event) {
        var isFavoriteString = event.currentTarget.getAttribute('data-favorite');        
        var isFavorite = (isFavoriteString == 'true');
        if(isFavorite)
            this.removeFavorite(component, event, isFavorite);
        else
            this.addFavorite(component, event, isFavorite);
    },
    
    removeFavorite : function(component, event, isFavorite) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var action = component.get("c.removeUserFavorite");
        
        action.setParams({
            "materialId" : materialId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                // after we update the favorite, we need to update the master list?
                this.updateWithFavorite(component, materialId, isFavorite);
            }
        });
        $A.enqueueAction(action);
    },
    
    addFavorite : function(component, event, isFavorite) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var action = component.get("c.addUserFavorite");
        
        action.setParams({
            "materialId" : materialId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                // after we update the favorite, we need to update the master list?
                this.updateWithFavorite(component, materialId, isFavorite);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateWithFavorite : function(component, materialId, isFavorite){
        var material = component.get("v.material");
        material.IsFavorite = !isFavorite;
        
        component.set("v.material", material);
       
        // send event back to search results with new favorite update
        var event = $A.get("e.c:ShoppingCartUpdateFavoritesList");
        event.setParams({
            "materialId" : materialId,
            "isFavorite" : isFavorite
        });
        event.fire();
    },
    
    showSuccessToast : function(successMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": successMessage,
	        "type": 'success'
	    });
	    toastEvent.fire();
	},
    
    showErrorToast : function(errorMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": errorMessage,
	        "type": 'error'
	    });
	    toastEvent.fire();
	},
})