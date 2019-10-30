({
    init : function (cmp) {
        var flow = cmp.find("flowData");
        flow.startFlow("Who_to_Contact");        
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
        }
    }     
})