({
	doInit : function(component, event, helper) {
        var displayNum = component.get("v.displayNum");
		helper.showItems(component, event, 0, displayNum);
	},
    
    slideForward : function(component, event, helper) {
        var slideIndex = component.get("v.slideIndex");
        var displayNum = component.get("v.displayNum");
        
        slideIndex += 1;
    	helper.showItems(component, event, slideIndex, displayNum);
    },
    
    slideBackward : function(component, event, helper) {
        var slideIndex = component.get("v.slideIndex");
        var displayNum = component.get("v.displayNum");
        
        slideIndex -= 1;
    	helper.showItems(component, event, slideIndex, displayNum);
    }
})