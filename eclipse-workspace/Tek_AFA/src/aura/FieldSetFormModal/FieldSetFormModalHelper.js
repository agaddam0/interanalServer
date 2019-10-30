({
	showModal : function(component, event, helper, loadUsingQuery) {
		var fieldSetName = component.get('v.fieldSetName');
        var objectName = component.get('v.objectName');
        var customFieldInputs = component.get('v.customFieldInputs');
        
        $A.createComponents([
            ["c:FieldSetForm",{ fieldSetName: fieldSetName,
                                objectName: objectName,
                                record: component.getReference('v.record'),
                                loadOnInit: loadUsingQuery == false,
                                "aura:id": "myFieldSetForm",
                                errorResponse: component.getReference('v.errorResponse'),
                                customFieldInputs: customFieldInputs }],
            ["c:FieldSetFormModalFooter", {cancelHandler: component.get('c.hideFieldSetFormOverlayLibrary'),
                                           saveHandler: component.getReference('v.saveHandler'),
                                           saveAndNewHandler: component.getReference('v.saveAndNewHandler'),
                                           showSaveAndNewButton: component.getReference('v.showSaveAndNewHandlerButton')}]
        ],
	        function(components, status){
	            if (status === "SUCCESS") {
	                var fieldSetForm = components[0];
	                if (loadUsingQuery) {
	                	var methodArgs = event.getParam('arguments');
	                	var recordId = methodArgs.Id;
	                	fieldSetForm.loadComponentUsingQueriedRecord(recordId);
	                }
	                
	                var modalFooter = components[1];
	                
	                var overlayPromise = component.find('fieldSetFormOverlayLibrary').showCustomModal({
	                   header: component.get('v.header'),
	                   body: fieldSetForm, 
	                   footer: modalFooter
	                });
	                
	                // Save the modal's promise so we can close it later.
	                component.set("v.overlayPromise", overlayPromise);
	            }
	        }
        );
	},
	
	hideModal : function(component) {
		component.get('v.overlayPromise').then(
		    function (modal) {
		        modal.close();
		    }
		);
	},
	
	validate : function(component) {
		var fieldSetForm = this.getFieldSetForm(component);
		return fieldSetForm.validate();
	},
	
	showValidationMessages : function(component) {
		var fieldSetForm = this.getFieldSetForm(component);
		fieldSetForm.showValidationMessages();
	},
	
	clearValidationMessages : function(component) {
		var fieldSetForm = this.getFieldSetForm(component);
		fieldSetForm.clearValidationMessages();
	},
	
	getFieldSetForm : function(component) {
		var fieldSetForm = component.find('myFieldSetForm');
		
		if (Array.isArray(fieldSetForm)) {
			fieldSetForm = fieldSetForm[0];
		}
		
		return fieldSetForm;
	}
})