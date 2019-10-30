({
    doInit : function(component, event, helper) {
        var record = component.get("v.record");
        if(record){
            if(record.Material_Type__c){
                helper.showPrintIcon(component, record.Material_Type__c);
                helper.showDigitalIcon(component, record.Material_Type__c);
            }
            if(record.Processing_Type__c){
                helper.showDownloadIcon(component, record.Processing_Type__c);
            }
        }
    }
})