({
	renderPage: function(component, event, helper) {
		var allItems = component.get('v.AllItems');
        var displayedItems = component.get('v.DisplayedItems');
        var recordsToDisplay = component.get("v.PageSize");
        
        if (!allItems || !displayedItems) {
        	return;
        }
        
        if(!recordsToDisplay){
            recordsToDisplay = 10;
        }
        
        var sliceNumber = component.get("v.sliceNo");
        var maxSlice;
        var pageItems = allItems.slice(0, sliceNumber * recordsToDisplay);
        
        if(Number.isInteger(allItems.length / recordsToDisplay)) {
            maxSlice = allItems.length/recordsToDisplay;
        }
        else {
            maxSlice = Math.trunc(allItems.length/recordsToDisplay)+1;
        }
        
		if(pageItems.length <= recordsToDisplay && allItems.length <= maxSlice * recordsToDisplay) {
            component.set("v.showLess", false);
        }
        
        console.log(maxSlice);
        component.set("v.maxSlice", maxSlice);
        component.set("v.DisplayedItems", pageItems);
    }
})