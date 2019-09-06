({
	doInit : function(component, event, helper) {
		var action = component.get('c.getaccList1');
        action.setCallback(this,function(results){
            //var state=results.getstate();
            component.set('v.AccountList',results.getReturnValue());
            
        });
        $A.enqueueAction(action);
	},
    
    handleClick : function(component, event, helper){
          var currentTab = component.get("v.selTabId");
        if(currentTab == '1'){
          component.set("v.selTabId" , '2');   
        }else if(currentTab == '2'){
          component.set("v.selTabId" , '3');     
        }else if(currentTab == '3'){
          component.set("v.selTabId" , '4');             
        }else if(currentTab == '4'){
             alert('Complete !');  
        } 
    },
    Back:function(component,event,helper){
        var currentTab = component.get("v.selTabId");
        if(currentTab == '2'){
          component.set("v.selTabId" , '1');   
        }else if(currentTab == '3'){
          component.set("v.selTabId" , '2');     
        }else if(currentTab == '4'){
          component.set("v.selTabId" , '3');             
        }
    },
    getcontacts:function(component,event,helper){
        var action = component.get('c.getconList1');
        action.setCallback(this,function(results){
            //var state=results.getstate();
            component.set('v.contactList',results.getReturnValue());
            
        });
        $A.enqueueAction(action);
        
    },
    getopps:function(component,event,helper){
        var action=component.get('c.getOppList');
        action.setCallback(this,function(results){
            component.set('v.OpportunityList',results.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    getleads:function(component,event,helper){
          var action=component.get('c.getLeadList');             
        action.setCallback(this,function(results){
            component.set('v.LeadList',results.getReturnValue());
            
        });
        $A.enqueueAction(action);
    }
})