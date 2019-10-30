({
    init : function (cmp) {
        var recordId = cmp.get('v.recordId');
        var flow = cmp.find("flowData");
        var inputVariables =[
            {
                name : 'recordId',
                type : 'String',
                value : recordId
            }
        ];
        flow.startFlow("GA_Rate_Pass", inputVariables);        
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
        }
    }     
})