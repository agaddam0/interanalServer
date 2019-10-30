({
    fireShoppingCartNavigationEvent : function(navigate) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : navigate
        });
        newEvent.fire();
    },
    
    loadOrderConfirmation : function(component, orderId) {
        var action = component.get("c.getOrderForConfirmation");
        var helper = this;
        
        action.setParams({
            "orderId": orderId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var orderConfirmation = result.getReturnValue();
            
                component.set("v.order", orderConfirmation);
                
                helper.segmentOrderLines(component, orderConfirmation.Order.Order_Line_Items__r);
            }
        });

        $A.enqueueAction(action);
    },
    
    openDownloadURLFromDownloadButton : function(component, event) {
        var downloadBtn = event.getSource();
        var downloadURL = downloadBtn.get('v.value');
    
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": downloadURL
        });
        urlEvent.fire();
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
    
    segmentOrderLines : function(component, orderLines) {
        var otherActionsNeededOrderLines = [];
        component.set('v.otherActionsNeededOrderLines', otherActionsNeededOrderLines);

        if (!orderLines) {
            return;
        }

        for (let orderLine of orderLines) {
            if (orderLine.Marketing_Material__r.Material_Type__c == 'Build Your Own Email' ||
                (orderLine.Marketing_Material__r.Material_Type__c == 'Website' &&
                 orderLine.Marketing_Material__r.Website_Type__c == 'Appointment Scheduler')) {
                orderLine.isBuildYourOwnEmail = orderLine.Marketing_Material__r.Material_Type__c == 'Build Your Own Email';
                otherActionsNeededOrderLines.push(orderLine);
            }
        }

        component.set('v.otherActionsNeededOrderLines', otherActionsNeededOrderLines);
    }
})