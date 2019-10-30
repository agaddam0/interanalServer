({
    
	doInit: function(component, event, helper) {
        const currentYear = (new Date()).getFullYear();
        const yearOptions = [0, 1, 2, 3].map(f => f + currentYear)
        component.set('v.yearOptions', yearOptions)
		helper.loadFeatures(component, event);
    },
    openPrintModal: function(component, event, helper) {
    	helper.showPrintModal(component);      
    },
    openFeatureDetailModal: function(component, event, helper) {
        var featureReleases = component.get('v.featureReleases');
        var selectedFeature = featureReleases.filter(f => event.srcElement.dataset.target === f.Id)[0];

        component.set('v.selectedFeature', selectedFeature);
        var featureDetailsFieldSetFormCmp = component.find('featureDetailsFieldSetForm');

        featureDetailsFieldSetFormCmp.set('v.fieldSetName', 'Feature_Roadmap');
        featureDetailsFieldSetFormCmp.loadComponent(selectedFeature);
    	helper.showFeatureDetailModal(component);
        
      
    },
    updateTheme: function(component, event, helper) {
       const newTheme = component.find('themeSelect').get('v.value');
       component.set('v.themeName', newTheme);
       helper.filterAndMapFeatures(component);
         
    },
    closeFeatureDetailModal: function(component, event, helper) {
    	helper.hideFeatureDetailModal(component);
    },
    closePrintModal: function(component, event, helper) {
    	helper.hidePrintModal(component);
    },
    setDisplay: function(component, event, helper) {
        helper.filterAndMapFeatures(component);
    },
    updateYear: function(component, event, helper) {
		const newYear = component.find('yearSelect').get('v.value'); 
        component.set('v.filterYear', newYear);
        helper.filterAndMapFeatures(component);
      
    },
    onFieldSetFormLoaded : function(component, event, helper) {
        
    	var fieldSetFormCmp = event.getSource();
    	var fieldComponents = fieldSetFormCmp.get('v.body');
    	var selectedFeature = component.get('v.selectedFeature');
    	
    	for (var i = 0; i < fieldComponents.length; ++i) {
            
    		var fieldComponent = fieldComponents[i];
			var id = fieldComponent.getLocalId();
    		if (id === 'Name' &&
    		    selectedFeature) {

    		    fieldComponents.splice(i, 1);
    		    component.set('v.body', fieldComponents);
    		    break;
    		}
    	}
        
    },
    updateTeam: function(component, event, helper) {
        // future 
        const newTeam = component.find('teamSelect').get('v.value'); 
        component.set('v.filterTeam', newTeam);
        helper.filterAndMapFeatures(component);
    },
    toggleNavigationSidebar : function (component, event, helper) {
      	var navigationSideBarCollapsed = component.get('v.navigationSideBarCollapsed');
		navigationSideBarCollapsed = !navigationSideBarCollapsed;
		component.set('v.navigationSideBarCollapsed', navigationSideBarCollapsed);
	}
})