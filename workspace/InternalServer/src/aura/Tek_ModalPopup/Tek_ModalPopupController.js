({
	openModel : function(component, event, helper) {
		component.set("v.isOpen", true);
	},
    likenClose:function(component, event, helper) {
		component.set("v.isOpen", false);
	},
    closeModel:function(component, event, helper) {
		component.set("v.isOpen", false);
	},
})