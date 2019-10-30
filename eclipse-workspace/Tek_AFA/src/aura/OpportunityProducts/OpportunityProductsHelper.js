({
	loadLineItems : function(component) {
        var getOppProducts = component.get("c.retrieveOpportunityProducts");
        getOppProducts.setParams({
            "opportunityId" : component.get("v.recordId")
        });
        getOppProducts.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.OpportunityProducts", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(getOppProducts);    
	},
    
    loadCatalog : function(component) {
        var getCatalog = component.get("c.getPricebookEntries");
        getCatalog.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.ProductCatalog", result.getReturnValue());
                component.set("v.searchResults", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(getCatalog);
    },
    
    addProductsToOpportunity : function(component, event) {
        var selected = component.get("v.SelectedProducts");
        var allProducts = component.get("v.ProductCatalog");
        var productsToAdd = [];
        
        for(var i = 0; i < allProducts.length; i++)
        {
            for(var s = 0; s < selected.length; s++)
            {
                if(allProducts[i].Product2.Name == selected[s])
                {
                    productsToAdd.push(allProducts[i]);
                }
            }
        }
        
        if(productsToAdd.length > 0)
        {
            var addLineItems = component.get("c.insertOpportunityLineItems");
            addLineItems.setParams({
                "opportunityId" : component.get("v.recordId"),
                "products" : productsToAdd
            });
            addLineItems.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS") {
                    component.set("v.OpportunityProducts", result.getReturnValue());
                    var lineItemChangedEvent = component.getEvent('updateLineItem');
                    lineItemChangedEvent.fire();
                }
            });
            
            $A.enqueueAction(addLineItems);
        }
    },
    
    removeOpportunityLineItem : function(component, event){
        var deleteLineItems = component.get("c.removeOpportunityLineItem");
        deleteLineItems.setParams({
            "lineItemId" : event.target.getAttribute("data-recId"),
            "opportunityId" : component.get("v.recordId")
        });
        deleteLineItems.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.OpportunityProducts", result.getReturnValue());
                var lineItemChangedEvent = component.getEvent('updateLineItem');
                lineItemChangedEvent.fire();
            }
        });
        
        $A.enqueueAction(deleteLineItems);
    }
})