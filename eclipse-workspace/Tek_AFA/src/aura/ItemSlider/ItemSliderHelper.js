({
	showItems : function(component, event, slideIndex, displayNum) {
        var x = component.find("mySlides"); // number of items in the array
        //debugger;
        if (slideIndex + displayNum > x.length) {slideIndex = 0} 
        if (slideIndex + displayNum < displayNum) {slideIndex = x.length - displayNum};
        
        var displayArray = [];
        for (var a = slideIndex; displayArray.length < displayNum; a++) {
            displayArray.push(a);
        }
        
        for (var i = 0; i < x.length; i++) {
            if(displayArray.includes(i)) {
                $A.util.removeClass(x[i], "slds-hide");
                $A.util.addClass(x[i], "slide-left");
            }
            else {
                $A.util.addClass(x[i], "slds-hide"); 
            }
        }
        
        component.set("v.slideIndex", slideIndex);
        
	}
})