({
    customFieldSetCustomAttributes : {
        'Sales_Office__c' : { searchField: 'Name',
                              order: 'Name',
                              limit: '10',
                              'class': 'slds-m-top_small',
                              loadingMessage: "Loading...",
                              errorMessage: "Invalid user input",
                              filter: "Status__c = 'Open'"},
    },

    fireShoppingCartNavigationEvent : function(navigate, returnLocation) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : navigate,
            "ReturnLocation" : returnLocation
        });
        newEvent.fire();
    },
    
    validateCart : function(component, event){
        var fieldSets = component.find("CustomizedLineItemFields");
        var isValid = true;
        
        for(var i = 0; i < fieldSets.length; i++)
        {
            if(fieldSets[i].isRendered() && !fieldSets[i].validate()){
                isValid = false;
                break;
            }
        }
        
        return isValid;
    },
    
    saveCart : function(component, event) {
        if(this.validateCart(component, event)) {
            var orderLineItems = component.get("v.LineItems");
            var order = component.get("v.Order");
            var quantityValid = true;
            
            for(let orderLineItem of orderLineItems)
            {
                if(orderLineItem.Record.Quantity__c < orderLineItem.MarketingMaterial.Record.Quantity_Minimum__c 
                   || orderLineItem.Record.Quantity__c > orderLineItem.MarketingMaterial.Record.Quantity_Maximum__c)
                {
                    quantityValid = false;
                }
            }
            
            if(quantityValid)
            {
                var orderLineItemRecords = [];
                
                for (let orderLineItem of orderLineItems) {
                    orderLineItemRecords.push(orderLineItem.Record);
                }
                
                var saveAction = component.get("c.saveOrder");
                saveAction.setParams({
                    "lineItemsStringify" : JSON.stringify(orderLineItemRecords),
                    "order" : order
                });
                
                saveAction.setCallback(this, function(result){
                    var state = result.getState();
                    if(component.isValid() && state === "SUCCESS") {
                        this.fireShoppingCartNavigationEvent('CartCheckoutView');
                    }
                    else {
                        this.showErrorToast("There was a problem saving your order.");
                    }
                });
                $A.enqueueAction(saveAction);
            }
            else {
             	this.showErrorToast('Quantity ordered must fall within the Minimum and Maximum quantity.');   
            }            
        }
        else {
            this.showErrorToast("Please complete the required fields before checkout.");
        }
    },
    
    removeLineItem : function(component, event) {
        // remove the item from the list
        // send event to shopping cart with updated line items
        
        var lineItemId = event.currentTarget.getAttribute('data-recId');
        var orderLineItems = component.get("v.LineItems");
        var removeAction = component.get("c.removeLineItemFromOrder");
        removeAction.setParams({
            "lineItemId" : lineItemId
        });
        
        removeAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                
                // remove Item from line item array
                for(var i = 0; i < orderLineItems.length; i++)
                {
                    if(orderLineItems[i].Record.Id == lineItemId)
                    {
                        orderLineItems.splice(i, 1);
                    }
                }
                
                component.set("v.LineItems", orderLineItems);                
                
                // send event component to update line item count
                var event = $A.get("e.c:ShoppingCartOrderDetailsEvent");
                event.setParams({
                    "Order" : component.get("v.Order"),
                    "OrderLineItems" : orderLineItems
                });
                event.fire();
                
                // show toast that item was successfully added to cart
                this.showSuccessToast("Item successfully removed from cart.");
            }
            else
            {
                this.showErrorToast("There was a problem during your request.");
            }
        });
        $A.enqueueAction(removeAction);
    },
    
    duplicateItem : function(component, event) {
        var lineItemId = event.currentTarget.getAttribute('data-recId');
        var orderLineItems = component.get("v.LineItems");
        var orderLineItemRecords = [];
        var order = component.get("v.Order");
        var materialId;
        var quantity;
        
        for(var i = 0; i < orderLineItems.length; i++)
        {
            if(orderLineItems[i].Record.Id == lineItemId)
            {
                materialId = orderLineItems[i].Record.Marketing_Material__c;
                quantity = orderLineItems[i].Record.Quantity__c;
            }
            // Push all order line records to be updated
            orderLineItemRecords.push(orderLineItems[i].Record);
        }  
        
        var duplicateAction = component.get('c.duplicateLineItem');
        duplicateAction.setParams({
            "marketingMaterialId" : materialId,
            "quantity" : quantity,
            "orderId" : order.Id,
            "lineItemsStringify" : JSON.stringify(orderLineItemRecords)
        });
        
        duplicateAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var cartInformation = result.getReturnValue();
                
                component.set("v.LineItems", cartInformation.OrderLineItems);
                component.set("v.Order", cartInformation.Order);
                
                // send event component to update line item count
                var event = $A.get("e.c:ShoppingCartOrderDetailsEvent");
                event.setParams({
                    "Order" : cartInformation.Order,
                    "OrderLineItems" : cartInformation.OrderLineItems
                });
                event.fire();
                
                // show toast that item was successfully added to cart
                this.showSuccessToast("Added to the cart successfully!");
            }
            else {
                this.showErrorToast("There was a problem during your request.");
            }
        });
        $A.enqueueAction(duplicateAction);
    },
    
    saveCartOnExit : function(component, event) {
        var orderLineItems = component.get("v.LineItems");
        var order = component.get("v.Order");
        
        var orderLineItemRecords = [];
        
        for (let orderLineItem of orderLineItems) {
            orderLineItemRecords.push(orderLineItem.Record);
        }
        
        var saveAction = component.get("c.saveOrder");
        saveAction.setParams({
            "lineItemsStringify" : JSON.stringify(orderLineItemRecords),
            "order" : order
        });
        
        saveAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                // do nothing, just saving current progress
            }
            else {
                this.showErrorToast("There was a problem saving your order.");
            }
        });
        $A.enqueueAction(saveAction);
    },
    
    updateLineItemsInCart : function(component, materialId, isFavorite) {
        var lineItemsList = component.get("v.LineItems");
        for(let lil of lineItemsList)
        {
            if(lil.MarketingMaterial.Record.Id == materialId)
            {
                // set to the opposite of the current value
                lil.MarketingMaterial.IsFavorite = !isFavorite;
            }
        }
        
        component.set("v.LineItems", lineItemsList);
    },
    
    updateLineItems : function(component, event){
        var action = component.get("c.updateLineItemsFromLookUps");
        var orderLineItems = component.get("v.LineItems");
        
        var orderLineItemRecords = [];
        
        for (let orderLineItem of orderLineItems) {
            orderLineItemRecords.push(orderLineItem.Record);
        }
        
        action.setParams({
            "lineItemsStringify" : JSON.stringify(orderLineItemRecords)
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                this.reloadCart(component);
            }
            else {
                var fieldSets = component.find('CustomizedLineItemFields');
                // recordId of the field being updated
                var recordId = event.getParam('recordId');
                if(fieldSets.length)
                {
                    for(let fieldSet of fieldSets)
                    {
                        var record = fieldSet.get('v.record');
                        if(record.Id === recordId){
                            fieldSet.set('v.errorResponse', result);
                        }
                    }
                }
                else if(fieldSets)
                {
                    fieldSets.set('v.errorResponse', result);
                }
                else
                    this.showErrorToast("There was a problem saving your order.");
            }
        });
        $A.enqueueAction(action);
    },
    
    getObjectFields : function(component, event){
        var action = component.get("c.getObjectFields");
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var objectFields = JSON.parse(result.getReturnValue());
                component.set("v.objectFields", objectFields);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    reloadCart : function(component) {
		var reloadCartEvent = component.getEvent("reloadCart");
		reloadCartEvent.fire();
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