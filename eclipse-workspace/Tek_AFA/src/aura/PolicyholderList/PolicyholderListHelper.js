({
    getRecords : function(component, event) {
        var searchTerm = component.find("searchTerm").get("v.value");
        var searchDate = component.get("v.searchDate");
        var alphaFilter = '';
        if(event.currentTarget !== undefined)
        	alphaFilter = event.currentTarget.getAttribute("data-Letter");
        var action = component.get("c.getPolicyholders");
        action.setParams({
            "acctId" : component.get("v.recordId"),
            "alphaFilter" : alphaFilter,
            "keyword" : searchTerm,
            "bdate" : searchDate,
            "sortAsc" : component.get("v.sortAsc")
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.policyholders", result.getReturnValue());
                this.renderPage(component);
            }
            this.toggle(component, event);
        });
        $A.enqueueAction(action);
    },
    
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.policyholders");
        sortAsc = sortField != field || !sortAsc;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.policyholders", records);
        this.renderPage(component);
    },
    
    renderPage: function(component) {
        var records = component.get("v.policyholders"),
            totalPages = Math.trunc(records.length/25)+1,
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*25, pageNumber*25);
        component.set("v.maxPage", totalPages);
        component.set("v.currentList", pageRecords);
    },
    
     toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})