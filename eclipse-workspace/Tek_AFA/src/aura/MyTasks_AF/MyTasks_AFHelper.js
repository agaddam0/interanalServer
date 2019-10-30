({
	showSpinner: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component, event) {
    	var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    loadTasks : function(component, event, helper) {
    	helper.showSpinner(component, event);
    
    	var getMyTasksAction = component.get('c.getMyTasks');
		var filter = component.get('v.Filter');
		
		getMyTasksAction.setParams({
			"filterName": filter
		});

		getMyTasksAction.setCallback(component, function(response){
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var getMyTasksActionResponse = response.getReturnValue();
				component.set('v.MyTasks', getMyTasksActionResponse);
				
				helper.renderPage(component, event, helper);
			}
			else {
				console.log('Problem getting my tasks. Response state: ' + state);
			}
			
			helper.hideSpinner(component, event);
		});
		
		$A.enqueueAction(getMyTasksAction);
    },
    
    editStandardTask : function(component, event, helper, standardTaskId) {
	    var editRecordEvent = $A.get("e.force:editRecord");
	    editRecordEvent.setParams({
	         "recordId": standardTaskId
	    });
	    editRecordEvent.fire();
    },
    
    editCustomTask : function(component, event, helper, taskRecord) {
    	helper.showEditTaskModal(component);
    	
    	component.set('v.TaskToEdit', taskRecord);
    	
    	var taskEditFieldSetForm = component.find('taskEditFieldSetForm');
    	taskEditFieldSetForm.loadComponent(taskRecord.Task);
    },
    
    saveEditedCustomTask : function(component, event, helper) {
    	var editedTask = component.get('v.TaskToEdit');
    	var customTask = editedTask.Task;
    	var filter = component.get('v.Filter');
    	
		var updateTaskAction = component.get('c.updateTask');
		updateTaskAction.setParams({
			"taskToUpdate": customTask,
			"filter": filter
		});
		
		updateTaskAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var myTasks = response.getReturnValue();
				component.set('v.MyTasks', myTasks);

				helper.renderPage(component, event, helper);

				helper.hideEditTaskModal(component);
				
				helper.showSuccessToast('The task "' + editedTask.Name + '" was saved.');
			}
			else {
				console.log('Problem updating the task. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(updateTaskAction);
    },
    
	completeThisTask : function(component, event, helper) {
		var completeButton = event.getSource();
		var taskToComplete = completeButton.get('v.value');
    	var filter = component.get('v.Filter');
		
		var completeTaskAction = component.get('c.completeTask');
		completeTaskAction.setParams({
			"taskIdToComplete": taskToComplete.Task.Id,
			"filter": filter
		});
		
		completeTaskAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var myTasks = response.getReturnValue();
				component.set('v.MyTasks', myTasks);

				helper.renderPage(component, event, helper);

				helper.showSuccessToast('The task "' + taskToComplete.Name + '" was completed.');
			}
			else {
				console.log('Problem completing the task. Response state: ' + state);
			}

		});

		$A.enqueueAction(completeTaskAction);
	},

    renderPage: function(component, event, helper) {
		var paginator = component.find('paginator');
		paginator.reload();
    },

    showEditTaskModal : function(component) {
    	component.set('v.ShowEditTaskModal', true);
    },

    hideEditTaskModal : function(component) {
    	component.set('v.ShowEditTaskModal', false);
    },

    showSuccessToast : function(successMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": successMessage,
	        "type": 'success'
	    });
	    toastEvent.fire();
	}
})