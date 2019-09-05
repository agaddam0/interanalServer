({
 createTrail : function(component, event, helper) {
        var newTrail=component.get("v.newTrail");// getting label of attribute expenses object
         //calling apex method
        var action=component.get("c.createRecord");
        action.setParams({
            newTrail : newTrail
        });// passing patameters to methods.

         action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
              if (state === "SUCCESS") {
                
                var newTrail = {'sobjectType': 'Trail__c',
                                    'name': '',
                                    'Description__c': '',
                                    'Distance__c': '',
                                    'Last_Inspection_Date__c': ''
                                    
                                   };
                //resetting the Values in the form
                component.set("v.newTrail",newTrail);
                alert('Record is Created Successfully'+a.getReturnValue());
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
         });
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
 }
    })