({    
    setupComponentsToCreate : function(component, opportunity, platform){
        // based on simple setup choices, create applicable component
        
        // get latest values from the opportunity to show and build components off of.
        var getOpportunityAction = component.get('c.getOpportunity');
        
        getOpportunityAction.setParams({
            "opportunityId" : component.get("v.Opportunity.Id")
        });
        
        getOpportunityAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var opportunity = result.getReturnValue();
                var platform = component.get("v.PlatformSetup");
                var enrollmentForm = component.get("v.EnrollmentForm");
                var noChanges = 'true';
                
                if(opportunity.Change_Flex_Amount__c){
                    var container = component.find("flexAmountContainer");
                    this.createFieldSetForm(component, 'Quick_Setup_Health_FSA_Amounts', platform, container, 'Platform_Setup__c', 'flexAmountForm');
                    component.set("v.showFlexAmounts", true);
                    noChanges = false;
                }
                else
                    component.set("v.showFlexAmounts", false);
                
                if(opportunity.Change_Administrative_Contact__c){
                    var container = component.find("adminContactContainer");
                    this.createFieldSetForm(component, 'Quick_Setup_Admin_Contact', opportunity, container, 'Opportunity', 'adminContactForm');
                    component.set("v.showAdminContact", true);
                    noChanges = false;
                }
                else
                    component.set("v.showAdminContact", false);
                
                if(opportunity.Change_AFenroll_Frequencies__c){
                    var container = component.find("deductionFrequenciesContainer");
                    this.createFieldSetForm(component, 'Quick_Setup_Deduction_Frequencies', opportunity, container, 'Opportunity', 'afEnrollForm');
                    component.set("v.showFrequencies", true);
                    noChanges = false;
                }
                else
                    component.set("v.showFrequencies", false);
                
                if(opportunity.Add_Import_Plan_s__c){
                    var container = component.find("importPlansContainer");
                    this.createImportProductsComponent(component, container, enrollmentForm);
                    component.set("v.showImportPlans", true);
                    noChanges = false;
                }
                else
                    component.set("v.showImportPlans", false);
                
                if(opportunity.Add_Individual_Plan_s__c){
                    var container = component.find("individualPlansContainer");
                    this.createIndividualProductsComponent(component, container, enrollmentForm);
                    component.set("v.showIndividualPlans", true);
                    noChanges = false;
                }
                else
                    component.set("v.showIndividualPlans", false);
                
                if(opportunity.Add_a_DVR__c){
                    var container = component.find("dvrContainer");
                    this.createFieldSetForm(component, 'DVR_Setup', platform, container, 'Platform_Setup__c', 'dvrForm');
                    component.set("v.showDVR", true);
                    noChanges = false;
                }
                else
                    component.set("v.showDVR", false);
                
                if(opportunity.Add_Texas_Life__c){
                    var container = component.find("texasLifeContainer");
                    this.createFieldSetForm(component, 'Texas_Life_Setup', platform, container, 'Platform_Setup__c', 'texasLifeForm');
                    component.set("v.showTexasLife", true);
                    noChanges = false;
                }
                else
                    component.set("v.showTexasLife", false);
                
                component.set("v.NoChanges", noChanges);
            }
        });
        
        $A.enqueueAction(getOpportunityAction);
    },
    
    createFieldSetForm : function(component, fieldSetName, record, container, objectName, auraName) {
        $A.createComponent("c:FieldSetForm",
                           {"record" : record,
                            "fieldSetName" : fieldSetName,
                            "objectName" : objectName,
                            "aura:id" : auraName,
                            "disableInputFields" : component.get("v.disableInputFields"),
                            "useStrikePicklist" : true},
                           function(cmp){
                               container.set("v.body", [cmp]);
                           });
    },
    
    createImportProductsComponent : function(component, container, record){
        $A.createComponent("c:ReserviceImportProducts",
                           {"EnrollmentForm" : record,
                            "aura:id" : 'importProducts',
                            "disableButtons" : component.get("v.disableInputFields")},
                           function(cmp){
                               container.set("v.body", [cmp]);
                           });
    },
    
    createIndividualProductsComponent : function(component, container, record){
        $A.createComponent("c:ReserviceIndividualProducts",
                           {"EnrollmentForm" : record,
                            "aura:id" : 'individualProducts',
                            "disableButtons" : component.get("v.disableInputFields")},
                           function(cmp){
                               container.set("v.body", [cmp]);
                           });
    },
    
    validateVisibleForms : function(component, event) {
        
        var opportunity = component.get("v.Opportunity");
        var validForm = true;
        if(opportunity.Change_Flex_Amount__c){
            var flexAmountForm = component.find("flexAmountForm");
            flexAmountForm.clearValidationMessages();
            var isFlexValid = flexAmountForm.validate();
            if(!isFlexValid){
                validForm = false;
                flexAmountForm.showValidationMessages();
            }
        }
        
        if(opportunity.Change_Administrative_Contact__c){
            var adminContactForm = component.find("adminContactForm");
            adminContactForm.clearValidationMessages();
            var isAdminValid = adminContactForm.validate();
            if(!isAdminValid){
                validForm = false;
                adminContactForm.showValidationMessages();
            } 
        }	
        
        if(opportunity.Change_AFenroll_Frequencies__c){
            var afEnrollForm = component.find("afEnrollForm");
            afEnrollForm.clearValidationMessages();
            var isAFEnrollValid = afEnrollForm.validate();
            if(!isAFEnrollValid){
                validForm = false;
                afEnrollForm.showValidationMessages();
            }
        }
        
        if(opportunity.Add_a_DVR__c){
            var dvrForm = component.find('dvrForm');
            dvrForm.clearValidationMessages();
            var isDVRValid = dvrForm.validate();
            if(!isDVRValid){
                validForm = false;
                dvrForm.showValidationMessages();
            }
        }
        
        if(opportunity.Add_Texas_Life__c){
            var texasLifeForm = component.find('texasLifeForm');
            texasLifeForm.clearValidationMessages();
            var isTLFValid = texasLifeForm.validate();
            if(!isTLFValid){
                validForm = false;
                texasLifeForm.showValidationMessages();
            }
        }
        
        component.set("v.formsValid", validForm);
        return validForm;
    },
    
    disableForm : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableInputFields", disabled);
        
        var formsToDisable = ['flexAmountForm', 'adminContactForm', 'afEnrollForm', 'importProducts', 'individualProducts', 'dvrForm', 'texasLifeForm'];
        
        for(let formName of formsToDisable){
            let form = component.find(formName);
            if(form)
                form.disableForm(disabled);
        }
    }
})