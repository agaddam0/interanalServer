({
    loadRecords : function(component, event, helper) {
        helper.showSpinner(component);
        helper.setTableClass(component);
        var searchByOwner = component.get("v.useOwnerId");
        var searchByProTraxUser = component.get("v.ProTraxUser");
        if(searchByOwner){
            // get logged in user id
            helper.getUserInfo(component);
        }
        else if(searchByProTraxUser)
        {
            helper.getProtraxUser(component);
        }
            else
            {
                helper.getRecords(component, event); 
            }
    },
    
    setTableClass : function(component) {
      	var showStripes = component.get('v.showAlternatingStripes');
        var removeHover = component.get("v.removeHoverHighlight");
        
        var tableClass = 'slds-table slds-table_bordered slds-table_cell-buffer';
        if(showStripes)
            tableClass += ' slds-table_striped';
        if(removeHover)
            tableClass += ' slds-no-row-hover';
            
        component.set("v.tableClass", tableClass);
    },
    
    getRecords : function(component, event) {
        var action = component.get("c.getRecords"),
            objectName = component.get("v.objectName"),
            fieldSet = component.get("v.fieldSetColumns"),
            whereClause = component.get("v.whereClause"),
            addWhereClause = component.get("v.additionalWhereClause"),
            fieldSetFilter = component.get("v.fieldSetFilter"),
            searchByOwner = component.get("v.useOwnerId"),
            searchByProTrax = component.get("v.ProTraxUser"),
            paginator = component.find('paginator'),
            additionalColumns = component.get('v.additionalColumns'),
            sortBy = component.get('v.sortField'),
            sortDirection = component.get('v.sortDirection');
        
        if(whereClause && addWhereClause)
            whereClause = whereClause + addWhereClause;
        else if (addWhereClause)
            whereClause = addWhereClause;
        
        if(searchByOwner || searchByProTrax){
            if(whereClause)
                whereClause += ' AND OwnerId = \'' + component.get("v.OwnerId") + '\'' ;
            else
                whereClause = 'WHERE OwnerId = \'' + component.get("v.OwnerId") + '\'' ;
        }
        
        console.log("whereClause: " + whereClause);
        
        var getRecordsRequest = {
            "requestJSON" : JSON.stringify({
                "SObjectName": objectName,
                "FieldSet": fieldSet,
                "WhereClause": whereClause,
                "AdditionalColumns": additionalColumns,
                "SortDirection": sortDirection,
                "SortBy": sortBy
            })
        }
        
        action.setParams(getRecordsRequest);
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("callback state: " + state);
            
            if (component.isValid() && state === "SUCCESS") {
                var context = response.getReturnValue();
                for(var i = 0; i < context.Records.length; i++)
                {
                    for(var b = 0; b < context.Records[i].fields.length; b++)
                    {
                        if(b === 0)
                            context.Records[i].fields[b].FirstField = true;
                        else
                            context.Records[i].fields[b].FirstField = false;
                        
                        console.log(context.Records[i].fields[b]);                        
                    }
                }
                
                var clonedRecords = JSON.parse(JSON.stringify(context.Records));
                component.set("v.originalRecords", clonedRecords);
                
                component.set("v.records", context.Records);
                component.set("v.columnNames", context.ColumnNames);
                component.set("v.columnAPINames", context.ColumnAPINames);
                component.set("v.columns", context.Fields);
                if(component.get("v.useNextPagination"))
                    this.renderPage(component);
                else
                    paginator.reload();
            }
            this.hideSpinner(component);
        });
        
        $A.enqueueAction(action);
    },
    
    filterRecordsUsingSearchText : function(component, event) {
        var helper = this;
        var searchText;
        var params = event.getParam('arguments');
        if(params && params.searchParam) {
            searchText = params.searchParam;
        }
        else {
            searchText = component.get('v.searchText');    
        }
        
        var paginator = component.find('paginator');
        
        if (!searchText) {
            var originalRecords = component.get('v.originalRecords');
            component.set('v.records', originalRecords);
            
            if(component.get("v.useNextPagination"))
                this.renderPage(component);
            else
                paginator.reload();
            
            return;
        }
        
        if (searchText.length < 2) {
            return;
        }
        
        var filteredRecords = [];
        var records = component.get('v.originalRecords');
        var searchTextRegEx = new RegExp(helper.escapeRegExp(searchText), 'i');
        
        for (let record of records) {
            var matchFound = false;
            
            for (let recordField of record.fields) {
                if (recordField.FieldValue &&
                    String(recordField.FieldValue).search(searchTextRegEx) > -1) {
                    matchFound = true;
                    break;
                }
            }
            
            if (matchFound) {
                filteredRecords.push(record);
            }
        }
        
        component.set('v.records', filteredRecords);
        
        if(component.get("v.useNextPagination"))
            this.renderPage(component);
        else
            paginator.reload();
    },
    
    showSpinner : function(component) {
        component.set('v.showSpinner', true);
    },
    
    hideSpinner : function(component) {
        component.set('v.showSpinner', false);
    },
    
    toggle: function (component, event) {
        //var spinner = component.find("mySpinner");
        //$A.util.toggleClass(spinner, "slds-hide");
    },
    
    getUserInfo: function(component){
        var searchByOwner = component.get("v.useOwnerId");
        
        if(searchByOwner){
            var action = component.get("c.getOwnerId");
            var recordId = component.get("v.recorId");
            action.setParams({
                "recordId" : recordId 
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log("callback state: " + state);
                
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.OwnerId", response.getReturnValue());
                    
                    this.getRecords(component, event);
                } 
            });
            $A.enqueueAction(action);
        }
    },
    
    getProtraxUser : function(component){
        var action = component.get("c.getProtraxUserId");
        var recordId = component.get("v.recordId");
        action.setParams({
            "recordId" : recordId 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("callback state: " + state);
            
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.OwnerId", response.getReturnValue());
                
                this.getRecords(component, event);
            } 
        });
        $A.enqueueAction(action);
    },
    
    findRecordById : function(component, rowId) {
        var records = component.get('v.records');
        var recordsLength = records.length;
        
        for (var i = 0; i < recordsLength; ++i) {
            var record = records[i];
            
            if (record.Record.Id == rowId) {
                return record.Record;
            }
        }
        
        return null;
    },
    
    renderPage: function(component) {
        var records = component.get("v.records"),
            itemsToShow = component.get("v.numItemsToShow"),
            totalPages = Math.trunc(records.length/itemsToShow)+1,
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*itemsToShow, pageNumber*itemsToShow);
        component.set("v.maxPage", totalPages);
        component.set("v.slicedRecords", pageRecords);
        this.scrollToTop();
    },
    
    scrollToTop: function(){
        var scrollEvent = $A.get("e.c:ScrollToTopEvent");
        scrollEvent.fire();
    },

    escapeRegExp : function(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
    }
})