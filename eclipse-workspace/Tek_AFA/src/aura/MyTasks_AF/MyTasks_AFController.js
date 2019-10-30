({
	doInit : function(component, event, helper) {
		helper.loadTasks(component, event, helper);
	},
	
	onFilterChange : function(component, event, helper) {
		helper.loadTasks(component, event, helper);
	},
	
	editTask : function(component, event, helper) {
		var editButton = event.getSource();
		var myTaskToEdit = editButton.get('v.value');
		
		if (myTaskToEdit.IsCustom == false) {
			helper.editStandardTask(component, event, helper, myTaskToEdit.Task.Id);
		}
		else {
			helper.editCustomTask(component, event, helper, myTaskToEdit);
		}
	},
	
	newTask : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            'entityApiName' : 'Task'
        });
        createRecordEvent.fire();
	},
	
	reloadOnTaskSaveSuccess : function(component, event, helper) {
		var toastMessageParams = event.getParams();
		var message = toastMessageParams.message;
		
		if (message.includes('Task') && message.includes('was saved')) {
			helper.loadTasks(component, event, helper);
		}

		/*if (message.includes('Task') && message.includes('was created')) {
			var urlEvent = $A.get("e.force:navigateToURL");
		    urlEvent.setParams({
		      "url": "/one/one.app?source=aloha#/home"
		    });
		    urlEvent.fire();
		}*/
	},
	
	closeEditTaskModal : function(component, event, helper) {
		helper.hideEditTaskModal(component);
	},
	
	saveEditedCustomTask : function(component, event, helper) {
		helper.saveEditedCustomTask(component, event, helper);
	},
	
	completeThisTask : function(component, event, helper) {
		helper.completeThisTask(component, event, helper);
	},

    onFieldSetFormLoaded : function(component, event, helper) {
    	var fieldSetFormCmp = event.getSource();
    	var fieldComponents = fieldSetFormCmp.get('v.body');
    	var taskToEdit = component.get('v.TaskToEdit');
    	
    	for (var i = 0; i < fieldComponents.length; ++i) {
    		var fieldComponent = fieldComponents[i];
    		var id = fieldComponent.getLocalId();
    		
    		if (id === 'Name' &&
    		    taskToEdit &&
    		    taskToEdit.Task.Task_Template__c) {
    		    
    		    fieldComponents.splice(i, 1);
    		    component.set('v.body', fieldComponents);
    		    break;
    		}
    	}
    },
})