({
	fieldSetFormCustomAttributes: {
		Assignee__c: { filter: 'isActive = true', label: 'Assignee'},
		Name: { label: 'Name' }
	},
	
	fieldSetRecordDisplayCustomAttributes: {
		'Assignee__r.Name': { Label: 'Assignee' },
		'Status__r.Name': { Label: 'Status' }
	},
	
	loadTaskBoard : function(component, event, helper) {
		var taskDetailsFieldSetForms = component.find('taskDetailsFieldSetForm');
		
		for (let taskDetailsFSF of taskDetailsFieldSetForms) {
			taskDetailsFSF.set('v.customAttributes', this.fieldSetFormCustomAttributes);
		}
		
		var projectToLoadId = component.get('v.ProjectToLoadId');
		
		if (projectToLoadId) {
			this.loadProject(component, event, helper);
		}
		else {
			this.loadTaskBoardForRecord(component, event, helper);
		}
	},
	
	loadTaskBoardForRecord : function(component) {
		var helper = this;
		var recordId = component.get('v.recordId');
		var getTaskBoardForRecordAction = component.get('c.getTaskBoardForRecord');
		getTaskBoardForRecordAction.setParams({"recordId": recordId});
		
		getTaskBoardForRecordAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskBoardResponse = response.getReturnValue();
				component.set("v.TaskBoard", taskBoardResponse);
				helper.loadSortByFieldValue(component, helper);
			}
			else {
				console.log('Problem getting task board for record. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getTaskBoardForRecordAction);
	},
	
	updateTask : function(component, taskId, newTaskStatusId) {
    	var recordId = component.get("v.TaskBoard").RecordId;
    	var helper = this;
    	
		var updateTaskStatusAction = component.get('c.updateTaskStatus');
		updateTaskStatusAction.setParams({
			"taskId": taskId,
			"newTaskStatusId": newTaskStatusId,
			"recordId": recordId
		});
		
		updateTaskStatusAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskBoardResponse = response.getReturnValue();
				component.set("v.TaskBoard", taskBoardResponse);
				
				helper.updateSelectedTaskWithLatestTaskBoardTask(component);
			}
			else {
				console.log('Problem updating the task\'s status. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(updateTaskStatusAction);
	},
	saveNewTask : function(component, newTaskName, newTaskStatusId) {
		var recordId = component.get("v.TaskBoard").RecordId;
		var projectId = component.get("v.TaskBoard").ProjectId;
    	
		var addNewTaskAction = component.get('c.addNewTask');
		addNewTaskAction.setParams({
			"newTaskName": newTaskName,
			"newTaskStatusId": newTaskStatusId,
			"projectId": projectId,
			"recordId": recordId
		});
		
		addNewTaskAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskBoardResponse = response.getReturnValue();
				component.set("v.TaskBoard", taskBoardResponse);
			}
			else {
				console.log('Problem adding the new task. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(addNewTaskAction);
	},
	loadSelectedTask : function(component, selectedTaskId) {
		var helper = this;
		var getTaskAction = component.get('c.getTask');
		getTaskAction.setParams({
			"taskId": selectedTaskId
		});
		
		getTaskAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskResponse = response.getReturnValue();
				component.set('v.SelectedTask', taskResponse);
				
				helper.loadTaskForEditing(component);
			}
			else {
				console.log('Problem getting the selected task. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getTaskAction);
	},
	setSelectedTask : function(component, selectedTaskId) {
		var taskBoard = component.get("v.TaskBoard");
		var taskListLength = taskBoard.TaskLists.length;
		var helper = this;
		var currentSelectedTask = component.get('v.SelectedTask');
		
		if (currentSelectedTask) {
			var currentSelectedTaskElement = document.getElementById(currentSelectedTask.Task.Id);
			
			$A.util.removeClass(currentSelectedTaskElement , 'highlightedTask');
		}
				
		for (var taskListIndex = 0; taskListIndex < taskListLength; ++taskListIndex) {
			var taskList = taskBoard.TaskLists[taskListIndex];
			var tasksLength = taskList.Tasks.length;
		
			for (var taskIndex = 0; taskIndex < tasksLength; ++taskIndex) {
				var task = taskList.Tasks[taskIndex];
				
				if (task.Task.Id == selectedTaskId) {
					component.set("v.SelectedTask", task);
					var newSelectedTaskElement = document.getElementById(selectedTaskId);
					
					$A.util.addClass(newSelectedTaskElement , 'highlightedTask');
					
					var taskDetailsFieldSetFormCmps = component.find('taskDetailsFieldSetForm');
					
					for (let taskDetailsFieldSetFormCmp of taskDetailsFieldSetFormCmps) {
						taskDetailsFieldSetFormCmp.set('v.fieldSetName', task.Task.Edit_Field_Set__c);
						taskDetailsFieldSetFormCmp.loadComponent(task.Task);
					}

					return;
				}
			}
		}
	},
	saveSelectedTask : function(component) {
		var taskToUpdate = component.get('v.TaskToUpdate');
		var recordId = component.get('v.recordId');
		var helper = this;
		
		var updateTaskAction = component.get('c.updateTask');
		updateTaskAction.setParams({
			"taskToUpdate": taskToUpdate,
			"recordId": recordId
		});
		
		updateTaskAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var latestTaskBoard = response.getReturnValue();
				component.set('v.TaskBoard', latestTaskBoard);
				
				helper.updateSelectedTaskWithLatestTaskBoardTask(component);
				
				helper.hideEditTaskModal(component);
				
				helper.showSuccessToast('The task was saved successfully.');
			}
			else {
				console.log('Problem getting the selected task. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(updateTaskAction);
	},
	updateTaskChecklistItemComplete : function(component, taskChecklistItemId, isComplete, checklistItemNameElement) {
		var newStatus = isComplete ? 'Completed' : 'Not Started';
		var helper = this;
	
		var updateTaskChecklistItemStatusAction = component.get('c.updateTaskChecklistItemStatus');
		updateTaskChecklistItemStatusAction.setParams({
			"taskChecklistItemId": taskChecklistItemId,
			"newStatus": newStatus
		});
		
		updateTaskChecklistItemStatusAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var updatedTaskChecklistItem = response.getReturnValue();
				var selectedTask = component.get('v.SelectedTask');
				
				for (var i = 0; i < selectedTask.Task.Task_Checklist_Items__r.length; ++i) {
					var checklistItem = selectedTask.Task.Task_Checklist_Items__r[i];
					
					if (checklistItem.Id == updatedTaskChecklistItem.Id) {
						selectedTask.Task.Task_Checklist_Items__r[i].Status__c = updatedTaskChecklistItem.Status__c;
						
						break;
					}
				}
				
				isComplete ? ++selectedTask.TaskChecklistItemsCompletedCount : --selectedTask.TaskChecklistItemsCompletedCount;
				
				component.set('v.SelectedTask', selectedTask);
				
				helper.updateTaskBoardTaskWithLatestTask(component, selectedTask);
			}
			else {
				console.log('Problem updated the selected task checklist item\'s status. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(updateTaskChecklistItemStatusAction);
	},
	addChecklistItem : function(component, taskId, checklistItemLabel) {
		var helper = this;
	
		var addTaskChecklistItemAction = component.get('c.addTaskChecklistItem');
		addTaskChecklistItemAction.setParams({
			"taskId": taskId,
			"checklistItemName": checklistItemLabel
		});
		
		addTaskChecklistItemAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var latestTask = response.getReturnValue();
				component.set('v.SelectedTask', latestTask);
				
				helper.updateTaskBoardTaskWithLatestTask(component, latestTask);
				
				component.set('v.NewChecklistItemName', null);
			}
			else {
				console.log('Problem updated the selected task checklist item\'s status. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(addTaskChecklistItemAction);
	},
	rerenderAttribute : function(component, attribute) {
		var componentAttribute = component.get(attribute);
		component.set(attribute, componentAttribute);
	},
	updateTaskBoardTaskWithLatestTask : function(component, newTask) {
		var taskBoard = component.get("v.TaskBoard");
		var taskListLength = taskBoard.TaskLists.length;
		
		for (var taskListIndex = 0; taskListIndex < taskListLength; ++taskListIndex) {
			var taskList = taskBoard.TaskLists[taskListIndex];
			var tasksLength = taskList.Tasks.length;
		
			for (var taskIndex = 0; taskIndex < tasksLength; ++taskIndex) {
				var task = taskList.Tasks[taskIndex];
				
				if (task.Task.Id == newTask.Task.Id) {
					taskList.Tasks[taskIndex] = newTask;
					component.set("v.TaskBoard", taskBoard);
					
					return;
				}
			}
		}
	},
	
	updateSelectedTaskWithLatestTaskBoardTask : function(component) {
		var helper = this;
		var selectedTask = component.get('v.SelectedTask');
		var taskBoard = component.get('v.TaskBoard');

		if (!selectedTask ||
		    !taskBoard) {
			return;
		}

		var taskListLength = taskBoard.TaskLists.length;

		for (var taskListIndex = 0; taskListIndex < taskListLength; ++taskListIndex) {
			var taskList = taskBoard.TaskLists[taskListIndex];
			var tasksLength = taskList.Tasks.length;
		
			for (var taskIndex = 0; taskIndex < tasksLength; ++taskIndex) {
				var task = taskList.Tasks[taskIndex];
				
				if (task.Task.Id == selectedTask.Task.Id) {
					component.set("v.SelectedTask", task);
					
					helper.loadTaskForEditing(component);
					
					return;
				}
			}
		}
	},
	
	readFile: function(component, taskId, file) {
        if (!file) return;

        var reader = new FileReader();
        var helper = this;
        reader.onloadend = function() {
            var dataURL = reader.result;
            console.log(dataURL);
            //component.set("v.pictureSrc", dataURL);
            helper.attachFileToTask(component, taskId, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
	},
    
    attachFileToTask : function(component, taskId, file, base64Data) {
    	var helper = this;
        var uploadFileToTaskAsChatterFileAction = component.get("c.uploadFileToTaskAsChatterFile"); 
        uploadFileToTaskAsChatterFileAction.setParams({
            "taskId": taskId,
            "fileName": file.name,
            "base64Data": base64Data,
            "contentType": file.type
        });

        uploadFileToTaskAsChatterFileAction.setCallback(component, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var latestTask = response.getReturnValue();
				component.set('v.SelectedTask', latestTask);
				
				helper.updateTaskBoardTaskWithLatestTask(component, latestTask);
			}
			else {
				console.log('Problem uploading the file to the task. Response state: ' + state);
			}
        });

        $A.enqueueAction(uploadFileToTaskAsChatterFileAction); 
    },
    
    showEditTaskModal : function(component) {
    	var helper = this;
    	component.set('v.ShowEditTaskModal', true);
    	
    	helper.loadTaskForEditing(component);
    },
    
    loadTaskForEditing : function(component) {
    	var selectedTask = component.get('v.SelectedTask');
    	var taskToUpdate = component.get('v.TaskToUpdate');
    	taskToUpdate = { "sobjectType": 'Task__c' };
    	var taskSource = selectedTask.Task;
    	
    	Object.assign(taskToUpdate, taskSource);
    	
    	component.set('v.TaskToUpdate', taskToUpdate);
    },
    
    hideEditTaskModal : function(component) {
    	component.set('v.ShowEditTaskModal', false);
    },
    
    showDeleteTaskFileModal : function(component) {
    	component.set('v.ShowDeleteTaskFileModal', true);
    },
    
    hideDeleteTaskFileModal : function(component) {
    	component.set('v.ShowDeleteTaskFileModal', false);
    },
    
    deleteTaskFile : function(component, fileToDeleteId) {
    	var helper = this;
    	var selectedTask = component.get('v.SelectedTask');
    	var taskId = selectedTask.Task.Id;
    	
        var deleteTaskChatterFileAction = component.get("c.deleteTaskChatterFile"); 
        deleteTaskChatterFileAction.setParams({
            "taskId": taskId,
            "taskFileIdToDelete": fileToDeleteId
        });

        deleteTaskChatterFileAction.setCallback(component, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var latestTask = response.getReturnValue();
				component.set('v.SelectedTask', latestTask);
				
				helper.updateTaskBoardTaskWithLatestTask(component, latestTask);
				
				helper.hideDeleteTaskFileModal(component);
				helper.showSuccessToast('The file was deleted.');
			}
			else {
				console.log('Problem uploading the file to the task. Response state: ' + state);
			}
        });

        $A.enqueueAction(deleteTaskChatterFileAction);
    },
    
    showSuccessToast : function(successMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": successMessage,
	        "type": 'success'
	    });
	    toastEvent.fire();
	},
	
	setSelectedTaskToCompleted : function(component, taskId) {
		var helper = this;
    	var selectedTask = component.get('v.SelectedTask');
    	var taskId = selectedTask.Task.Id;
    	var recordId = component.get('v.recordId');
    	
        var completeTaskAction = component.get("c.completeTask"); 
        completeTaskAction.setParams({
            "taskId": taskId,
            "recordId": recordId
        });

        completeTaskAction.setCallback(component, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskBoard = response.getReturnValue();
				component.set('v.TaskBoard', taskBoard);
				
				helper.updateSelectedTaskWithLatestTaskBoardTask(component);
				
				helper.showSuccessToast('The task was completed.');
			}
			else {
				console.log('Problem uploading the file to the task. Response state: ' + state);
			}
        });

        $A.enqueueAction(completeTaskAction);
	},
	filterTaskBoardTasks : function(component, taskFilterName, roleFilterName) {
		var helper = this;
    	var recordId = component.get('v.recordId');
    	var projectId = component.get('v.ProjectToLoadId');

    	if (taskFilterName == 'All Tasks') {
    		taskFilterName = '';
    		roleFilterName = '';
    	}
    	
        var filterTaskBoardForRecordAction = component.get("c.filterTaskBoardForRecord"); 
        filterTaskBoardForRecordAction.setParams({
            "recordId": recordId,
            "projectId": projectId,
            "taskFilterName": taskFilterName,
            "roleFilterName": roleFilterName
        });

        filterTaskBoardForRecordAction.setCallback(component, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskBoard = response.getReturnValue();
				component.set('v.TaskBoard', taskBoard);
				component.set('v.RoleTaskFilter', roleFilterName);
				component.set('v.TaskFilter', taskFilterName);
				component.set('v.SelectedTask', null);
			}
			else {
				console.log('Problem filtering the tasks. Response state: ' + state);
			}
        });

        $A.enqueueAction(filterTaskBoardForRecordAction);
	},
	loadProject : function(component, event, helper) {
	    var myHelper = this;
		var projectToLoadId = component.get('v.ProjectToLoadId');
		
        var getTaskBoardByProjectIdAction = component.get("c.getTaskBoardByProjectId"); 
        getTaskBoardByProjectIdAction.setParams({
            "projectId": projectToLoadId
        });

        getTaskBoardByProjectIdAction.setCallback(component, function(response) {
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var taskBoard = response.getReturnValue();
				component.set('v.TaskBoard', taskBoard);
				
				var recordId = component.get('v.recordId');
				
				if (!recordId) {
					component.set('v.recordId', taskBoard.RecordId);
				}
				
				myHelper.loadSortByFieldValue(component, myHelper);
			}
			else {
				console.log('Problem uploading the file to the task. Response state: ' + state);
			}
        });

        $A.enqueueAction(getTaskBoardByProjectIdAction);
	},

	loadSortByFieldValue : function(component, helper) {
	    var sortByMenuItem = component.get('v.SortByMenuItem');
	    
	    if (!sortByMenuItem) {
	    	return;
	    }
	    
    	var taskBoard = component.get('v.TaskBoard');
    	
    	if (!taskBoard || !taskBoard.LinkedRecord) {
    		return;
    	}
    	
    	var linkedRecord = taskBoard.LinkedRecord;
    	
    	var fieldValue = linkedRecord ? linkedRecord[sortByMenuItem.ApiField] : "";

    	if (!fieldValue) {
    	    fieldValue = "";
    	}
    	else if (fieldValue.match(/\d\d\d\d-\d\d-\d\d/)) {
    	    fieldValue = helper.convertToFormattedDateString(fieldValue);
    	}
    	
    	component.set('v.SortByFieldValue', fieldValue);
	},
	
	convertToFormattedDateString : function (dateString) {
		var date = new Date(dateString);
		var userTimezoneOffset = date.getTimezoneOffset() * 60000;
		var d2 = new Date(date.getTime() + userTimezoneOffset);
		
		var options = { year: 'numeric', month: '2-digit', day: '2-digit' };
		var formattedDate = d2.toLocaleDateString("en-US", options);
	
		return formattedDate;
	}
})