({
	init : function (cmp) {
var flow = cmp.find("flowData");
flow.startFlow("Prospect_Contact_Opportunity_Create");

},
  
handleStatusChange : function (component, event) {
   if(event.getParam("status") === "FINISHED") {
       $A.get("e.force:closeQuickAction").fire();
    }
} 

})