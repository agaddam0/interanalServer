({
	getchildRecrods : function(component,event) {
		var action=component.get('c.getContacts');
        action.setCallback(this,function(a){
            var state=a.getState();
            
            if(state=='SUCCESS'){
                
                component.set('v.ChildRecordList',a.getReturnValue());
            }else{}
        });$A.enqueueAction(action);
	},
    addSelectedHelper:function(component,event,childRecordsIds){
        var action=component.get('c.addParentAccount');
        alert(childRecordsIds);
        action.setParams({
            "ParentId": '0010K000025YL2qQAG', 
            "lstOfContactIds": childRecordsIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state =="SUCCESS") {
                 alert('inside');
                 var toastEvent = $A.get("e.force:showToast");
          			toastEvent.setParams({
        				"title": "Success!",
        				"message": "The Child record's has been added successfully."
    				});
                    toastEvent.fire();
              
                // refresh/reload the page view
                $A.get('e.force:refreshView').fire();
                
                // call init function again [clear selected checkboxes]
                this.getChildRecors(component,event);
                  
            }$A.enqueueAction(action);
        });
    }
})