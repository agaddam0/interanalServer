({
	init : function(component, event, helper) {
		var loadOnInit = component.get('v.loadOnInit');
	
	    if (loadOnInit) {
	    	helper.loadRecords(component, event, helper);
        }
    },

    reloadRecords : function(component, event, helper) {
        helper.loadRecords(component, event, helper);
    },
    
    searchFields : function(cmp, event, helper) {
        helper.toggle(cmp, event);
        var searchObject = cmp.get("v.searchObject");
        var whereClause = cmp.get("v.whereClause");
        var addWhereClause = cmp.get("v.additionalWhereClause");
        
        addWhereClause = '';
                
        for(var property in searchObject) {
                    
            if(typeof(searchObject[property]) === "boolean"){
                if(searchObject[property] == true){
                    if(whereClause && addWhereClause)
                        addWhereClause += ' AND';
                    else
                        whereClause = 'WHERE';
                    
                    addWhereClause += ' ' + property + ' = ' + searchObject[property];
                }
                
            }
            else if(searchObject[property] && searchObject[property] !== ''){
                if(whereClause && addWhereClause)
                    addWhereClause += ' AND';
                else
                    whereClause = 'WHERE';
                
                addWhereClause += ' ' + property + ' = ' + "'" + searchObject[property] + "'";
            }
            
            console.log(property + " = " + searchObject[property]);
        }
        
        if(whereClause && whereClause.length + addWhereClause.length == 5)
            whereClause = '';
        
        cmp.set("v.whereClause", whereClause);
        cmp.set("v.additionalWhereClause", addWhereClause);
        helper.getRecords(cmp, event);
    },
    
    clear : function(cmp, event, helper)
    {
        helper.toggle(cmp, event);
        var searchObject = cmp.get("v.searchObject");
        var whereClause = cmp.get("v.whereClause");
        var addWhereClause = cmp.get("v.additionalWhereClause");
        
        addWhereClause = '';
        
        for(var property in searchObject)
        {
            searchObject[property] = undefined;
        }
        
        
        if(whereClause.length == 5)
            whereClause = '';
        
        cmp.set("v.searchObject", searchObject);
        cmp.set("v.whereClause", whereClause);
        cmp.set("v.additionalWhereClause", addWhereClause);
        
        helper.getRecords(cmp, event);
    },
    
    goToRecord : function(component, event, handler) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        var selectedId = event.currentTarget.getAttribute("data-recId");
        sObjectEvent.setParams({
            "recordId" : selectedId
        });
        sObjectEvent.fire();
    },
    
    onRowActionClick : function(component, event, helper) {
    	var actionName;
    	var rowId;
    	
    	if (event.currentTarget &&
    	    typeof event.currentTarget.getAttribute === 'function') {
    	    actionName = event.currentTarget.getAttribute('data-action-name');
    	    rowId = event.currentTarget.getAttribute('data-row-id');
    	}
    	
    	if (!actionName) {
    		var sourceComponent = event.getSource();
    		var sourceComponentValue = sourceComponent.get('v.value');
    		
    		var valueParts = sourceComponentValue.split('_');
    		rowId = valueParts[0];
    		actionName = valueParts[1];
    	}

    	if (!rowId) {
    		rowId = event.currentTarget.getAttribute('value');
    	}
    	
    	var rowRecord = helper.findRecordById(component, rowId);
    	
    	var onRowActionEvent = component.getEvent("onRowAction");
		onRowActionEvent.setParams({
		    "actionName" : actionName,
		    "record" : rowRecord
		});

		onRowActionEvent.fire();
    },
    
    filterRecordsUsingSearchText : function(component, event, helper) {
        helper.filterRecordsUsingSearchText(component, event);
    },
    
    onSortColumn : function(component, event, helper) {
    	var currentSortField = component.get('v.sortField');
    	var currentSortDirection = component.get('v.sortDirection');
    	var nextSortField = event.currentTarget.getAttribute('data-column');
    	
    	var nextSortDirection = currentSortField == nextSortField && currentSortDirection == 'ASC' ? 'DESC' : 'ASC';
    	
    	component.set('v.sortField', nextSortField);
    	component.set('v.sortDirection', nextSortDirection);
    	
    	helper.getRecords(component, event);
    },
    
    renderPage : function(component, event, helper) {
        helper.renderPage(component);
    }
})