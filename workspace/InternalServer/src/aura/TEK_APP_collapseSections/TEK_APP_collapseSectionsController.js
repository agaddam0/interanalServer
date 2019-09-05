({
 // common reusable function for toggle sections
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        //alert(sectionAuraId);
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
       // alert(sectionDiv);
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    doInit :function(component,event,helper){
            var action= component.get("c.getcontactRecords");
            action.setCallback(this,function(a){
                var state = a.getState();
                if(state == "SUCCESS"){
                    component.set('v.contact',a.getReturnValue());
                }else{
                    alert('No records found');
                }
            })
            $A.enqueueAction(action);
           var action= component.get("c.getLeadRecords");
            action.setCallback(this,function(b){
                var state = b.getState();
                if(state == "SUCCESS"){
                    //alert(b.getReturnValue());
                    component.set('v.Lead',b.getReturnValue());
                }else{
                    alert('No records found');
                }
            })
            $A.enqueueAction(action);
        }
     
})