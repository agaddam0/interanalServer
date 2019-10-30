({
	loadOrderDetail : function(component) {
		var helper = this;
		var orderId = component.get('v.orderId');
		
		var getOrderForHistoryDetailAction = component.get("c.getOrderForHistoryDetail");
		
		getOrderForHistoryDetailAction.setParams({
			"orderId": orderId
		});
        
        getOrderForHistoryDetailAction.setCallback(this, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
            	var detail = result.getReturnValue();
            
            	component.set('v.order', detail.Order);
            	component.set('v.lineItems', detail.OrderLineItems);
            	component.set('v.salesOffice', detail.SalesOffice);
            }
            else if (component.isValid() && state !== "SUCCESS") {
            	var error = result.getError();
            	component.set('v.exception', error);
            }
        });
        $A.enqueueAction(getOrderForHistoryDetailAction);
	},
    
    reorderLineItems : function(component) {
        var orderId = component.get('v.orderId');        
        var reOrderAction = component.get("c.ReOrderFromHistory");
		
		reOrderAction.setParams({
			"orderHistoryOrderId": orderId
		});
        
        reOrderAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
            	var allItemsAdded = result.getReturnValue();
                this.reloadCart(component);
                
                if(allItemsAdded)
                    this.showToast('success', 'Your cart has been updated');
                else
                    this.showToast('warning', $A.get("$Label.c.Shopping_Cart_Reorder_Not_All_Items_Added")); 
            	
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
    
    openEmailBuilderFromButton : function(component, event) {
	    var emailBuilderBtn = event.getSource();
		var orderLine = emailBuilderBtn.get('v.value');
		var navService = component.find('navService');
		
		var emailBuilderPageReference = {
		    type: 'standard__navItemPage',
		    attributes: {
		        apiName: "Email_Builder",
		    },
		    state: {
		        "c__OpportunityId": orderLine.Opportunity__c,
		        "c__EmailTemplate": orderLine.Marketing_Material__r.Email_To_Build__c
		    }
		};
		
		navService.generateUrl(emailBuilderPageReference)
        .then($A.getCallback(function(url) {
            window.open(url, '_blank');
        }));
	},
	
	openAppointmentSchedulerFromButton : function(component, event) {
	    var apptSchedulerBtn = event.getSource();
		var orderLine = apptSchedulerBtn.get('v.value');
		var navService = component.find('navService');
		
		var apptSchedulerPageReference = {
		    type: 'standard__navItemPage',
		    attributes: {
		        apiName: "Appointment_Scheduler",
		    },
		    state: {
		        "c__AccountId": orderLine.Opportunity__r.AccountId
		    }
		};
		
		navService.generateUrl(apptSchedulerPageReference)
        .then($A.getCallback(function(url) {
            window.open(url, '_blank');
        }));
	},
    
    reloadCart : function(component) {
		var reloadCartEvent = component.getEvent("reloadCart");
		reloadCartEvent.fire();
	},
    
    navigateToCart : function(component) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : 'CartReviewView'
        });
        newEvent.fire();
    },
    
    showToast : function(type, Message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": Message,
            "type": type
        });
        toastEvent.fire();
    }
})