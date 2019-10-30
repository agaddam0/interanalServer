({
	doInit : function(component, event, helper) {
		helper.loadTaskBoard(component);
	},
	drag: function(component, event, helper) {
		var taskId = event.currentTarget.getAttribute("data-task-id");
		
		component.set("v.DraggedTaskId", taskId);
	},
	allowDrop: function(component, event, helper){
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
        console.log('eligible');
    },
    drop: function(component, event, helper){
    	var taskListElement = event.currentTarget;
    	var newTaskStatusId = taskListElement.getAttribute('data-status-id');
    	var taskId = component.get("v.DraggedTaskId");
    	
    	helper.updateTask(component, taskId, newTaskStatusId);
    },
    addNewTaskLocal: function(component, event, helper) {
    	var button = event.currentTarget;
    	var newTaskStatusId = button.getAttribute('data-status-id');
    	
    	var taskContainer = button.parentElement;
    	var taskInputArray = taskContainer.getElementsByTagName('input');
    	var taskInput = taskInputArray[0];
    	
    	var newTaskName = taskInput.value;
    	
    	helper.saveNewTask(component, newTaskName, newTaskStatusId);
    },
    taskSelected: function(component, event, helper) {
    	var taskBody = event.currentTarget;
    	var taskId = taskBody.getAttribute('data-task-id');
    	
    	helper.setSelectedTask(component, taskId);
    },
    taskSelectedForEditing: function(component, event, helper) {
    	var taskBody = event.currentTarget;
    	var taskId = taskBody.getAttribute('data-task-id');

    	helper.setSelectedTask(component, taskId);
    	helper.showEditTaskModal(component);
    },
    closeTaskDetail: function(component, event, helper) {
    	component.set("v.SelectedTask", null);
    },
    saveSelectedTask : function(component, event, helper) {
    	helper.saveSelectedTask(component);
    },
    addChecklistItem : function(component, event, helper) {
    	var selectedTask = component.get('v.SelectedTask');
    	var taskId = selectedTask.Task.Id;
    	var checklistItemLabel = component.get('v.NewChecklistItemName');
    
    	helper.addChecklistItem(component, taskId, checklistItemLabel);
    },
    taskChecklistItemClick : function(component, event, helper) {
    	var checklistItemCheckbox = event.currentTarget;
    	var checklistItemChecked = checklistItemCheckbox.checked;
    	var taskChecklistItemId = checklistItemCheckbox.getAttribute('data-checklist-item-id');
    	var checklistItemNameElement = checklistItemCheckbox.nextSibling;
    	
    	helper.updateTaskChecklistItemComplete(component, taskChecklistItemId, checklistItemChecked, checklistItemNameElement);
    },
    dropAndUploadFile : function(component, event, helper) {
    	event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        
        var files = event.dataTransfer.files;

        if (files.length>1) {
            return alert("You can only upload one file");
        }
        
        var selectedTask = component.get("v.SelectedTask");
        var taskId = selectedTask.Task.Id;

        helper.readFile(component, taskId, files[0]);
    },
    closeEditTaskModal : function(component, event, helper) {
    	helper.hideEditTaskModal(component);
    },
    deleteFileConfirmation : function(component, event, helper) {
    	var deleteButton = event.currentTarget;
    	var fileToDeleteId = deleteButton.value;
    
    	helper.showDeleteTaskFileModal(component);
    	component.set('v.TaskFileToDeleteId', fileToDeleteId);
    },
    closeDeleteFileModal : function(component, event, helper) {
    	helper.hideDeleteTaskFileModal(component);
    },
    deleteFile : function(component, event, helper) {
    	var fileToDeleteId = component.get('v.TaskFileToDeleteId');
    
    	helper.deleteTaskFile(component, fileToDeleteId);
    },
    completeTaskClicked : function(component, event, helper) {
        helper.setSelectedTaskToCompleted(component);
    },
    filterTasksByProjectFilter : function(component, event, helper) {
    	var projectFilter = component.get('v.ProjectFilter');
    	
    	helper.filterTaskBoardTasks(component, projectFilter, '');
    },
    filterTasks : function(component, event, helper) {
    	var menuItem = event.getSource();
    	var taskFilterName = menuItem.get('v.label');
    	var roleFilterName = component.get('v.RoleTaskFilter');
    
    	helper.filterTaskBoardTasks(component, taskFilterName, roleFilterName);
    },
    filterTasksByRole : function(component, event, helper) {
    	var menuItem = event.getSource();
    	var roleFilterName = menuItem.get('v.label');
    	var taskFilterName = component.get('v.TaskFilter');
    
    	helper.filterTaskBoardTasks(component, taskFilterName, roleFilterName);
    },
    onFieldSetFormLoaded : function(component, event, helper) {
    	var fieldSetFormCmp = event.getSource();
    	var fieldComponents = fieldSetFormCmp.get('v.body');
    	var taskToUpdate = component.get('v.TaskToUpdate');
    	
    	for (var i = 0; i < fieldComponents.length; ++i) {
    		var fieldComponent = fieldComponents[i];
    		var id = fieldComponent.getLocalId();
    		
    		if (id === 'Name' &&
    		    taskToUpdate &&
    		    taskToUpdate.Task_Template__c) {
    		    
    		    fieldComponents.splice(i, 1);
    		    component.set('v.body', fieldComponents);
    		    break;
    		}
    	}
    },
    loadProject : function(component, event, helper) {
    	helper.loadProject(component, event, helper);
    },
    sortByChanged : function(component, event, helper) {
    	helper.loadSortByFieldValue(component, helper);
    }
})