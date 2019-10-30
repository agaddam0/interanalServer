({
	doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
		var flow = component.find("flow");
        var inputVariables =[
            {
                name : 'recordId',
                type : 'String',
                value : recordId
            }
        ];
        flow.startFlow("Submit_Copay_Flow", inputVariables);
	},
    
    statusChange : function(component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            component.set("v.showFinalScreen" , true);
            var documents;
            var copayIds = [];
            var outputVariables = event.getParam("outputVariables");
            
            for(var key in outputVariables) {
                console.log(outputVariables[key].name);
                if(outputVariables[key].name === 'DocumentIds') {
                    if(outputVariables[key].value) {
                     	documents = outputVariables[key].value;
                    }
                }
                
                if(outputVariables[key].name === 'NoCopayId' || outputVariables[key].name === 'SameCopayID') {
                    if(outputVariables[key].value) {
                        copayIds.push(outputVariables[key].value);
                    }
                }
            }
            
            if(documents) {
                helper.getAffectedRecords(component, documents);
            }
            
            if(copayIds) {
                helper.getUpdatedCopays(component, copayIds);
            }
        }
    }, 
    
    closeAction : function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire()
    }
})