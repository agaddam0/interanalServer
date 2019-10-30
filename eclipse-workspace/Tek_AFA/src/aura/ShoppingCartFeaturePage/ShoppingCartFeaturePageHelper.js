({
	loadFeaturedItems : function(component, event) {
        var action = component.get("c.getFeaturedMaterials");
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
            	var featuredItems = result.getReturnValue();
            	
            	if (featuredItems.length > 0) {
            		featuredItems[0].ShowInCarousel = true;
            	}
                
                var event = $A.get("e.c:TaskCompleteEvent");
                event.setParams({
                    "PageLoaded" : "FeaturedItems"
                });
                event.fire();

                component.set("v.featuredItems", featuredItems);
            }
        });
        
        $A.enqueueAction(action);
	},
	
	navigateToCarouselItem : function(component, desiredIndex) {
    	var transformToUse = 'transform:translateX(-' + desiredIndex + '00%)';
    	
    	var carouselPanels = component.find('carouselPanels');
    	var carouselPanelsElement = carouselPanels.getElement();
    	carouselPanelsElement.style = transformToUse;
    	
    	var featuredItems = component.get('v.featuredItems');
    	
    	for (let featuredItem of featuredItems) {
    		featuredItem.ShowInCarousel = false;
    	}
    	
    	var featuredItemToShow = featuredItems[desiredIndex];
    	featuredItemToShow.ShowInCarousel = true;
    	
    	component.set('v.featuredItems', featuredItems);
	},
	
	getCurrentFeaturedItem : function(featuredItems) {
		return featuredItems.findIndex(function(featuredItem) { 
			return featuredItem.ShowInCarousel;
		});
	},
    
    addMaterialToCart : function(component, event) {
        var materialId = event.getSource().get('v.name');
        var material;
        var featuredItems = component.get("v.featuredItems");
        
        for(var i = 0; i < featuredItems.length; i++)
        {
            if(featuredItems[i].Record.Id == materialId)
            {
                material = featuredItems[i].Record;
                break;
            }                
        }
        
        var action = component.get('c.addMarketingMaterialToCart');
        action.setParams({
            "marketingMaterial" : material,
            "quantity" : 1
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
                
                this.updateWithFavorite(component, materialId, isFavorite);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateWithFavorite : function(component, materialId, isFavorite){
        var itemList = component.get("v.featuredItems");
        for(let mm of itemList)
        {
            if(mm.Record.Id == materialId)
            {
                // set to the opposite of the current value
                mm.IsFavorite = !isFavorite;
                break;
            }
        }
        
        component.set("v.featuredItems", itemList);
       
        // send event back to search results with new favorite update
        var event = $A.get("e.c:ShoppingCartUpdateFavoritesList");
        event.setParams({
            "materialId" : materialId,
            "isFavorite" : isFavorite,
            "rerender" : false
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
	}
})