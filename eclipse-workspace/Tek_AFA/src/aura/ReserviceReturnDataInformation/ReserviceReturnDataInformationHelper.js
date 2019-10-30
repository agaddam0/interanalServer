({
    setDefaults : function(component){
        var platformSetup = component.get("v.PlatformSetup");
        if(!platformSetup.Enroll_Info_Upload__c)
            platformSetup.Enroll_Info_Upload__c = 'No';
        
        if(platformSetup.Enroll_Info_Upload__c == 'Yes'){
            component.set("v.showPayrollDetails", true);
            this.checkPayrollRush(component, platformSetup.EnrollInfoUploadDueDate__c);
        }            
        else
            component.set("v.showPayrollDetails", false);
    },

    checkPayrollRush : function(component, payrollDueDate){
        var opportunity = component.get("v.Opportunity");
        if(!opportunity.Enrollment_End_Date__c){
            return;
        }

        if(!payrollDueDate){
            return;
        }

        var businessDays = this.calculateBusinessDays(payrollDueDate, opportunity.Enrollment_End_Date__c);
        var allowedDays = $A.get("$Label.c.Payroll_Due_Date_Threshold");

        component.set("v.showPayrollRushReason", businessDays <= allowedDays);
    },

    calculateBusinessDays : function(startDate, endDate){
        var start = new Date(startDate);
        var end = new Date(endDate);
        const MONDAY = 1;
        const FRIDAY = 5

        var totalBusinessDays = 0;

        start.setHours(0,0,0,0);
        end.setHours(0,0,0,0);

        var current = new Date(start);
        current.setDate(current.getDate() + 1);
        var dayOfWeek;
        // loop through each day, checking
        while (current <= end) {
            dayOfWeek = current.getDay();
            //business days are days during the work week
            if (dayOfWeek >= MONDAY && dayOfWeek <= FRIDAY) {
                ++totalBusinessDays;
            }
            current.setDate(current.getDate() + 1);
        }
        return totalBusinessDays;
    },
    
    validateFieldSets : function(component){
        
        var payrollMainValid = false;
        var payrollDetailsValid = true;
        var payrollRushValid = true;
        var payrollMain = component.find("payrollMain");
        var showPayrollDetails = component.get("v.showPayrollDetails");
        var showPayrollRush = component.get("v.showPayrollRushReason");
        
        if(payrollMain){
            payrollMain.clearValidationMessages();
            payrollMainValid = payrollMain.validate();
            payrollMain.showValidationMessages();
        }
        
        if(showPayrollDetails){
            var payrollDetails = component.find("payrollDetails");
            if(payrollDetails){
                payrollDetails.clearValidationMessages();
                payrollDetailsValid = payrollDetails.validate();
                payrollDetails.showValidationMessages();
            } 
        }

        if(showPayrollRush){
            var payrollRush = component.find("payrollRushForm");
            if(payrollRush){
                payrollRush.clearValidationMessages();
                payrollRushValid = payrollRush.validate();
                payrollRush.showValidationMessages();
            } 
        }
        
        if(payrollMainValid && payrollDetailsValid && payrollRushValid)
            return true;
        else
            return false;
    },
    
    disableForm : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        var formsToDisable = ['payrollMain', 'payrollDetails', 'payrollRushForm'];
        
        component.set("v.disableInputFields", disabled);

        for(let formName of formsToDisable){
            let form = component.find(formName);
            if(form) {
                form.disableForm(disabled);
            }
        }
    }
})