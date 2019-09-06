({
	doInit : function(component, event, helper) {
        var action = component.get("c.getAccRecrods");
         action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
               
                component.set("v.Account",a.getReturnValue());
                alert('Record is Created Successfully');
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        });
        

          
        $A.enqueueAction(action);
		
	}
})