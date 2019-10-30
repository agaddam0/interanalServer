({
	doInit : function(component, event, helper) {
		helper.getSignatures(component, event);
	},
    
    goToPDF : function(component, event, handler) {
        var sObjectEvent = $A.get("e.force:navigateToURL");
        var selectedFormName = event.currentTarget.getAttribute("data-recordType");
        var selectedId = event.currentTarget.getAttribute("data-recId");
        var pageURL = '';
        
        if(selectedFormName == 'Subscription Agreement')
            pageURL = 'Disability_Subscription_Form_PDF';
        else if(selectedFormName == 'Service Exchange Agreement')
            pageURL = 'ServiceExchangePDF';
        
        sObjectEvent.setParams({
            "url" : '/apex/' + pageURL + '?id=' + selectedId
        });
        
        sObjectEvent.fire();
    },
})