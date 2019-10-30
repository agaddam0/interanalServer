({
	onCategoryHomeClick : function(component, event, helper) {
		helper.fireShoppingCartNavigationEvent('HomePageView');
	},

	onOrderHistoryClick : function(component, event, helper) {
		helper.fireShoppingCartNavigationEvent('OrderHistoryView');
	},
	
	onOrderIdChanged : function(component, event, helper) {
		var newOrderId = event.getParam("value");
		
		if (newOrderId) {
			helper.loadOrderConfirmation(component, newOrderId);
		}
	},

	onDownloadAllClick : function(component, event, helper) {
		helper.openDownloadURLFromDownloadButton(component, event);
	},

	onDownloadClick : function(component, event, helper) {
		helper.openDownloadURLFromDownloadButton(component, event);
	},
	
	onOpenEmailBuilderClick : function(component, event, helper) {
	    helper.openEmailBuilderFromButton(component, event);
	},
	
	onOpenApptSchedulerClick : function(component, event, helper) {
	    helper.openAppointmentSchedulerFromButton(component, event);
	}
})