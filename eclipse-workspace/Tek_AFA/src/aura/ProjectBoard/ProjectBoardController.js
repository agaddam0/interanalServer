({
    doInit : function(component, event, helper) {
		helper.loadProjectBoard(component, helper);
	},
	
	selectProject : function(component, event, helper) {
		var selectedAccountId = component.get('v.SelectedAccountId');
		
		if (selectedAccountId) {
			helper.unselectAccount(component, event, helper);
		}

		var projectLinkElement = event.currentTarget;
		var projectId = projectLinkElement.getAttribute('data-project-id');
		var selectedProjectIds = component.get('v.SelectedProjectIds');
		
		if (!selectedProjectIds.includes(projectId)) {
			selectedProjectIds.push(projectId);
			component.set('v.SelectedProjectIds', selectedProjectIds);
			
			helper.setProjectToSelected(component, projectId, true, helper);
			helper.markProjectAsViewed(component, projectId, helper);
			
			var sortBy = helper.getSelectedSortBy(component);
			
			if (sortBy) {
			    helper.sortTaskBoards(component, event, helper);
			}
		}
	},
	
	unselectProject : function(component, event, helper) {
		var projectLinkElement = event.currentTarget;
		var projectId = projectLinkElement.getAttribute('data-project-id');
		var selectedProjectIds = component.get('v.SelectedProjectIds');
		var selectedProjectIdIndex = selectedProjectIds.indexOf(projectId);
		
		if (selectedProjectIdIndex != -1) {
			selectedProjectIds.splice(selectedProjectIdIndex, 1);
			component.set('v.SelectedProjectIds', selectedProjectIds);
			
			helper.setProjectToSelected(component, projectId, false, helper);
		}
	},
	
	reselectSelectedProjects : function(component, event, helper) {
		var projectsUpdatedFromReselection = component.get('v.ProjectsUpdatedFromReslection');
		if (projectsUpdatedFromReselection) {
			component.set('v.ProjectsUpdatedFromReslection', false);
			return;
		}
		
		var projects = component.get('v.Projects');
		var selectedProjectIds = component.get('v.SelectedProjectIds');
		var projectsUpdatedFromReselection = component.get('v.ProjectsUpdatedFromReslection');
		
		if (!projects || !projects.length || !selectedProjectIds || !selectedProjectIds.length) {
			return;
		}
		
		for (project of projects) {
			project.Selected = selectedProjectIds.includes(project.Record.Id);
		}
		
		component.set('v.ProjectsUpdatedFromReslection', true);
		component.set('v.Projects', projects);
	},
	
	viewMyPinnedProjects : function(component, event, helper) {
		helper.loadMyPinnedProjects(component, helper);
	},

	viewRecentProjects : function(component, event, helper) {
		helper.loadMyRecentlyViewedProjects(component, helper);
	},
	
	viewAllOpenProjects : function(component, event, helper) {
		helper.loadAllOpenProjects(component, event, helper);
	},
	
	viewMyOpenProjects : function(component, event, helper) {
		helper.loadMyOpenProjects(component, event, helper);
	},
	
	viewMyAssignedProjects : function(component, event, helper) {
		helper.loadMyAssignedProjects(component, event, helper);
	},
	
	onFavoriteClicked : function(component, event, helper) {
		helper.onFavoriteClicked(component, event, helper);
	},
	
	openAccountProjects : function(component, event, helper) {
		var accountMenuItem = event.currentTarget;
		var accountId = accountMenuItem.getAttribute('data-account-id');
	
		helper.loadAccountProjects(component, accountId, event, helper);
	},
	
	filterProjectTasks : function(component, event, helper) {
		var menuItem = event.getSource();
    	var projectFilter = menuItem.get('v.label');
    	
    	if (projectFilter == 'All Tasks') {
    		projectFilter = '';
    	}

    	component.set('v.ProjectFilter', projectFilter);
	},
	
	searchRecords : function(component, event, helper) {
		var searchTextBox = event.currentTarget;
		var searchText = searchTextBox.value;
	
		if (searchText.length >= 3) {
			helper.searchRecords(component, searchText, helper);
		}
	},
	
	unselectAccount : function(component, event, helper) {
		helper.unselectAccount(component, event, helper);
	},
	
	clearSearchText : function(component, event, helper) {
		component.set('v.SearchText', '');
	},
	
	sortTaskBoards : function(component, event, helper) {
		helper.onSortByChanged(component, event, helper);
	},
	
	toggleNavigationSidebar : function (component, event, helper) {
		var navigationSideBarCollapsed = component.get('v.navigationSideBarCollapsed');
		navigationSideBarCollapsed = !navigationSideBarCollapsed;
		
		component.set('v.navigationSideBarCollapsed', navigationSideBarCollapsed);
	}
})