({
	doInit : function(component, event, helper) {
        helper.getchildRecrods(component,event);
		
	},
    addSelected:function(component,event,helper){
            // create array[list] type temp. variable for store child record's id's from selected checkboxes.  
        var tempIDs = [];
        var getAllId = component.find("checkBox");
        for (var i=0;i<getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                   tempIDs.push(getAllId[i].get("v.text"));
                    
                }
        }
 
        // call the helper function and pass all selected record id's.   
        helper.addSelectedHelper(component, event, tempIDs);
    }
})