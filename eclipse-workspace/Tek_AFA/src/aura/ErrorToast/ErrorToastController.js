({
	doInit : function(component, event, helper) {
		var timeDelay = component.get("v.CloseAfter");
        setTimeout(function(){component.destroy();}, timeDelay);
	},
    
    destroyToast : function(component, event, helper) {
        component.destroy();
    }
})