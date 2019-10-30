({
	init : function (cmp) {
var flow = cmp.find("flowData");
flow.startFlow("Custom_Marketing_Request");

},
  
handleStatusChange : function (component, event) {
   if(event.getParam("status") === "FINISHED") {
       $A.get("e.force:closeQuickAction").fire();
    }
} 

})