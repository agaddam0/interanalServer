({
	sortByMenuItems: [
        {"Label": "Enrollment Start Date - Ascending", "FieldLabel": "Enrollment Start Date", "ApiField": "Enrollment_Start_Date__c", "sortDirection": "asc"},
        {"Label": "Enrollment Start Date - Descending", "FieldLabel": "Enrollment Start Date", "ApiField": "Enrollment_Start_Date__c", "sortDirection": "desc"},
        {"Label": "Enrollment End Date - Ascending", "FieldLabel": "Enrollment End Date", "ApiField": "Enrollment_End_Date__c", "sortDirection": "asc"},
        {"Label": "Enrollment End Date - Descending", "FieldLabel": "Enrollment End Date", "ApiField": "Enrollment_End_Date__c", "sortDirection": "desc"},
        {"Label": "Effective Date - Ascending", "FieldLabel": "Effective Date", "ApiField": "Effective_Date_of_AFA_Products__c", "sortDirection": "asc"},
        {"Label": "Effective Date - Descending", "FieldLabel": "Effective Date", "ApiField": "Effective_Date_of_AFA_Products__c", "sortDirection": "desc"}
    ],

	loadProjectBoard : function(component, helper) {
		component.set('v.SortByMenuItems', helper.sortByMenuItems);
	
		var getProjectBoardAction = component.get('c.getProjectBoard');

		getProjectBoardAction.setCallback(component, function(response){
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var getProjectBoardActionResponse = response.getReturnValue();
				
				if (getProjectBoardActionResponse.MyPinnedProjects &&
				    getProjectBoardActionResponse.MyPinnedProjects.length > 0) {
				    component.set('v.SelectedMenu', 'My Pinned Projects');
				    component.set('v.Projects', getProjectBoardActionResponse.MyPinnedProjects);
			    }
			    else {
			    	component.set('v.SelectedMenu', 'Recent Projects');
			    	component.set('v.Projects', getProjectBoardActionResponse.RecentlyViewedProjects);
			    }
			}
			else {
				console.log('Problem getting the project board. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getProjectBoardAction);
	},
	
	loadMyRecentlyViewedProjects : function(component, helper) {
		var getMyRecentlyViewedProjectsAction = component.get('c.getMyRecentlyViewedProjects');
		
		getMyRecentlyViewedProjectsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var getTaskBoardForRecordActionResponse = response.getReturnValue();
				component.set("v.Projects", getTaskBoardForRecordActionResponse);
				component.set('v.SelectedMenu', 'Recent Projects');
			}
			else {
				console.log('Problem getting my recently viewed projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getMyRecentlyViewedProjectsAction);
	},
	
	loadMyPinnedProjects : function(component, helper) {
		var getMyPinnedProjectsAction = component.get('c.getMyPinnedProjects');
		
		getMyPinnedProjectsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var getMyPinnedProjectsActionResponse = response.getReturnValue();
				component.set("v.Projects", getMyPinnedProjectsActionResponse);
				component.set('v.SelectedMenu', 'My Pinned Projects');
			}
			else {
				console.log('Problem getting my pinned projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getMyPinnedProjectsAction);
	},
	
	loadAllOpenProjects : function(component, event, helper) {
		var getAllOpenProjectsAction = component.get('c.getAllOpenProjects');
		
		getAllOpenProjectsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var getAllOpenProjectsActionResponse = response.getReturnValue();
				component.set('v.Projects', getAllOpenProjectsActionResponse);
				component.set('v.SelectedMenu', 'All Open Projects');
			}
			else {
				console.log('Problem getting all open projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getAllOpenProjectsAction);
	},
	
	loadMyOpenProjects : function(component, event, helper) {
		var getMyOpenProjectsAction = component.get('c.getMyOpenProjects');
		
		getMyOpenProjectsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var getMyOpenProjectsActionResponse = response.getReturnValue();
				component.set('v.Projects', getMyOpenProjectsActionResponse);
				component.set('v.SelectedMenu', 'My Open Projects');
			}
			else {
				console.log('Problem getting my open projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getMyOpenProjectsAction);
	},
	
	loadMyAssignedProjects : function(component, event, helper) {
		var getMyAssignedProjectsAction = component.get('c.getMyAssignedProjects');
		
		getMyAssignedProjectsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var getMyAssignedProjectsActionResponse = response.getReturnValue();
				component.set('v.Projects', getMyAssignedProjectsActionResponse);
				component.set('v.SelectedMenu', 'My Assigned Projects');
			}
			else {
				console.log('Problem getting my open projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getMyAssignedProjectsAction);
	},
	
	loadAccountProjects : function(component, accountId, event, helper) {
		var getAccountProjectsAction = component.get('c.getAccountProjects');
		
		getAccountProjectsAction.setParams({
			"accountId": accountId
		});
		
		getAccountProjectsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var getAccountProjectsActionResponse = response.getReturnValue();
				var selectedProjectIds = [];
				
				for (accountProject of getAccountProjectsActionResponse) {
					selectedProjectIds.push(accountProject.Record.Id);
				}
				
				component.set('v.SelectedProjectIds', selectedProjectIds);
				component.set('v.SelectedAccountId', accountId);
				
				var accounts = component.get('v.Accounts');
				
				for (account of accounts) {
					if (account.Id == accountId) {
						component.set('v.SelectedAccountName', account.Name);
						break;
					}
				}
				
				component.set('v.Accounts', accounts);
			}
			else {
				console.log('Problem getting account projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(getAccountProjectsAction);
	},
	
	onFavoriteClicked : function(component, event, helper) {
		var favoriteIcon = event.currentTarget;
		var projectId = favoriteIcon.getAttribute('data-project-id');
		var selectedMenu = component.get('v.SelectedMenu');
		
		var projects = component.get('v.Projects');
		
		var clickedProject = helper.findProjectById(projects, projectId);
		
		clickedProject.Pinned = !clickedProject.Pinned;
		
		if (selectedMenu == 'My Pinned Projects' && !clickedProject.Pinned) {
			var myPinnedProjIndexToRemove = projects.indexOf(clickedProject);
			projects.splice(myPinnedProjIndexToRemove, 1);
		}
		
		component.set('v.Projects', projects);
		
		helper.toggleProjectPin(component, projectId, helper);
	},
	
	findProjectById : function(projects, projectId) {
		var foundProject = {};
	
		if (projects) {
			foundProject = projects.find(function(project) {
				return project.Record.Id == projectId;
			});
		}
		
		return foundProject;
	},
	
	toggleProjectPin : function(component, projectId, helper) {
		var toggleProjectPinnednessAction = component.get('c.toggleProjectPinnedness');
		toggleProjectPinnednessAction.setParams({
			"projectId": projectId
		});
		
		toggleProjectPinnednessAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var toggleProjectPinnednessResponse = response.getReturnValue();
			}
			else {
				console.log('Problem toggling project pinnedness. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(toggleProjectPinnednessAction);
	},
	
	setProjectToSelected : function(component, projectId, selected, helper) {
		var projects = component.get('v.Projects');
		var selectedProject = helper.findProjectById(projects, projectId);
		selectedProject.Selected = selected;
		component.set('v.Projects', projects);
	},
	
	searchRecords : function(component, searchText, helper) {
		var searchForRecordsAction = component.get('c.searchForRecords');
		searchForRecordsAction.setParams({
			"searchText": searchText
		});
		
		searchForRecordsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
				var searchForRecordsActionResponse = response.getReturnValue();
				//component.set('v.SearchResult', searchForRecordsActionResponse);
				component.set('v.Projects', searchForRecordsActionResponse.Projects);
				component.set('v.Accounts', searchForRecordsActionResponse.Accounts);
				component.set('v.SelectedMenu', 'Search');
			}
			else {
				console.log('Problem getting my recently viewed projects. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(searchForRecordsAction);
	},

	unselectAccount : function(component, event, helper) {
		var emptySelectedProjectIds = [];
		
		component.set('v.SelectedProjectIds', emptySelectedProjectIds);
		component.set('v.SelectedAccountId', null);
		component.set('v.SelectedAccountName', null);
	},
	
	markProjectAsViewed : function(component, projectId, helper) {
		var queryProjectForViewingAction = component.get('c.queryProjectForViewing');
		queryProjectForViewingAction.setParams({
			"projectId": projectId
		});
		
		queryProjectForViewingAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
			}
			else {
				console.log('Problem query project for viewing. Response state: ' + state);
			}
		
		});
		
		$A.enqueueAction(queryProjectForViewingAction);
	},
	
	onSortByChanged : function(component, event, helper) {
		var menuItem = event.getSource();
    	var sortBy = menuItem.get('v.label');
    	
    	component.set('v.SortBy', sortBy);
    	
    	helper.sortTaskBoards(component, event, helper);
	},
	
	getSelectedSortBy : function(component) {
	    return component.get('v.SortBy');
	},
	
	getSelectedSortByMenuItem : function(component, helper) {
	    var sortBy = helper.getSelectedSortBy(component);
	    
	    for (menuItem of helper.sortByMenuItems) {
    		if (menuItem.Label == sortBy) {
    			return menuItem;
    		}
    	}
    	
    	return null;
	},
	
	getSelectedProjects : function(component, helper) {
		var projects = component.get('v.Projects');
    	
    	var selectedProjects = [];
    	
    	for (project of projects) {
    	    if (project.Selected) {
    	        selectedProjects.push(project);
    	    }
		}
		
		return selectedProjects;
	},
	
	convertDateStringToNumber : function(dateString) {
		if (dateString) {
		    return Number( dateString.replace(/-/g, '') );
		}
		
		return dateString;
	},
	
	sortProjects : function(helper, projects, sortByMenuItem) {
		var ascending = sortByMenuItem.sortDirection == "asc";
		
		projects.sort(function(a, b) {
			var aRawValue = a.Record.Opportunity__r ? a.Record.Opportunity__r[sortByMenuItem.ApiField] : null;
			var bRawValue = b.Record.Opportunity__r ? b.Record.Opportunity__r[sortByMenuItem.ApiField] : null;
			
			var aValue = helper.convertDateStringToNumber(aRawValue);
			var bValue = helper.convertDateStringToNumber(bRawValue);
			
			if(aValue === bValue){
		        return 0;
		    }
		    else if (aValue === null) {
		    	return 1;
		    }
		    else if(bValue === null){
		        return -1;
		    }
		    else if(ascending) {
		        return aValue < bValue ? -1 : 1;
		    }
		    else if(!ascending) {
		        return aValue < bValue ? 1 : -1;
		    }
		});
	},
	
	sortTaskBoards : function(component, event, helper) {
    	var sortByMenuItem = helper.getSelectedSortByMenuItem(component, helper);
    	var selectedProjects = helper.getSelectedProjects(component, helper);

    	helper.sortProjects(helper, selectedProjects, sortByMenuItem);

		var sortedSelectedProjectIds = [];

		for (sortedSelectedProject of selectedProjects) {
		    sortedSelectedProjectIds.push(sortedSelectedProject.Record.Id);
		}

		component.set('v.SelectedProjectIds', sortedSelectedProjectIds);
		component.set('v.SelectedMenuItem', sortByMenuItem);
	}
})