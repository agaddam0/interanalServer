({
	init : function(component, event, helper) {
		helper.init(component, event, helper);
	},
	
	onStatusFilterChanged : function(component, event, helper) {
		helper.getEnrollmentOpps(component, event, helper);
	},
	
	onOppOwnerIdFilterChanged : function(component, event, helper) {
		helper.getEnrollmentOpps(component, event, helper);
	},
	
	onEnrollmentOpportunityClicked : function(component, event, helper) {
		var enrollmentOppId = event.currentTarget.getAttribute('data-enrollment-opp-id');
	
	    var navEvt = $A.get("e.force:navigateToSObject");

	    navEvt.setParams({
	      "recordId": enrollmentOppId
	    });

	    navEvt.fire();
	},
	
    loadMore: function(component, event, helper) {
        component.set("v.sliceNo", component.get("v.sliceNo") + 1);
        component.set("v.showLess", true);
        helper.renderPage(component);
    },
    
    showLess: function(component, event, helper) {
        component.set("v.sliceNo", component.get("v.sliceNo") - 1);
        helper.renderPage(component);
    },
})