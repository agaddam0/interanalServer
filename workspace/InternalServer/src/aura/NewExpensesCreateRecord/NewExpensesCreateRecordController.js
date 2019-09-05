({
	create : function(component, event, helper) {
        var newExpense=component.get("v.newExpense");
        /*if($A.util.isEmpty(newExpense.name)){
            alert('Please enter name of expenses');
            return;
            
        }
        
		if($A.util.isEmpty(newExpense.client__c)){
            alert('Please enter name of cleint');
            return;
            
        }if($A.util.isEmpty(newExpense.date__c)){
            alert('Please enter date of expenses');
            return;
            
        }*/
        //calling apex method
        var action=component.get("c.createRecord1");
        action.setParams({
            newExpense : newExpense
        });
         action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
              if (state === "SUCCESS") {
                
                var newExpense = {'sobjectType': 'Expense__c',
                                    'name': '',
                                    'amount__c': '',
                                    'client__c': '',
                                    'Reimbursed__c': '',
                                    'date__c': ''
                                   };
                //resetting the Values in the form
                component.set("v.newExpense",newExpense);
                alert('Record is Created Successfully'+a.getReturnValue());
            } else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
         });
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
	}
})