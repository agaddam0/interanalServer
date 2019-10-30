({  
	navigateToPage : function(component, event, pageName) {
        var newEvent = $A.get("e.c:ReserviceNavigationEvent");
        newEvent.setParams({
            "navigate" : pageName
        });
        newEvent.fire();
    },
    
    save : function(component, event, objectData) {
        var saveAction = component.get('c.SaveObject');
        
        saveAction.setParams({
            "objectData" : objectData
        });
        
        saveAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                console.log('Save Success');
            }
        });
        
        $A.enqueueAction(saveAction);
    },
    
})