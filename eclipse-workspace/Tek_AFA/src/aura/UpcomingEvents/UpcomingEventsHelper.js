({
	toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    getRecords : function(component, event) {
        var selected = component.find("timeSpan").get("v.value"),
            startDate,
            endDate,
            today = new Date(),
            sunday = this.subDays(today, today.getDay());
        
        if(selected == 'Today'){
            startDate = this.dateFormatter(today);
            endDate = this.dateFormatter(today);
        }
        if(selected == 'Tomorrow'){            
            startDate = this.dateFormatter(this.addDays(today, 1));
            endDate = this.dateFormatter(this.addDays(today, 1)); 
        }
        if(selected == 'This Week') {
            startDate = this.dateFormatter(sunday);
            endDate = this.dateFormatter(this.addDays(sunday, 6));
        }
        if(selected == 'Next Week') {
            startDate = this.dateFormatter(this.addDays(sunday, 6));
            endDate = this.dateFormatter(this.addDays(sunday, 13)); 
        }
        
        var action = component.get("c.getEvents");
        action.setParams({
            "StringStartDate" : startDate,
            "StringEndDate"   : endDate
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.Events", result.getReturnValue());
                this.renderPage(component);
            }
            this.toggle(component, event);
        });
        $A.enqueueAction(action);
    },
    
    searchRecords : function(component, event) {
        var startDate = this.dateFormatter(new Date(component.get("v.StartDate"))),
            endDate = this.dateFormatter(new Date(component.get("v.EndDate"))),
            action = component.get("c.getEvents");
        
        action.setParams({
            "StringStartDate" : startDate,
            "StringEndDate" : endDate
        });
        
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                console.log('Setting Events');
                component.set("v.Events", result.getReturnValue());
                this.renderPage(component);
            }
            this.toggle(component, event);
        });
        $A.enqueueAction(action);
    },
    
    getRecordType : function(component, event) {
        var getType = component.get("c.getGeneralEventRecordType");
        getType.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.newEventRecordType", result.getReturnValue());
            }
        });
        $A.enqueueAction(getType);
    },
    
    dateFormatter : function(changeDate) {
        var stringDate = changeDate.getFullYear() + '-' + (changeDate.getMonth() + 1) + '-' + changeDate.getDate();
        return stringDate;
    },
    
    addDays : function addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    },
    
    subDays : function addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() - days);
        return result;
    },
    
    renderPage: function(component) {
        var records = component.get("v.Events"),
            recordsToDisplay = component.get("v.displayCount"),
            sliceNumber = component.get("v.sliceNo"),
            maxSlice,
            pageRecords = records.slice(0, sliceNumber*recordsToDisplay);
        
        if(this.isInteger(records.length/recordsToDisplay))
            maxSlice = records.length/recordsToDisplay;
        else
            maxSlice = this.trunc(records.length/recordsToDisplay)+1;
        
		if(pageRecords.length <= recordsToDisplay && records.length <= maxSlice * recordsToDisplay)
            component.set("v.showLess", false);
        
        console.log(maxSlice);
        component.set("v.maxSlice", maxSlice);
        component.set("v.currentList", pageRecords);
    },
    
    setToday: function(component, event) {
        var today = new Date();
        var yesterday = this.subDays(today, 1);
        component.set('v.now', today.toISOString());
        component.set('v.yesterday', yesterday.toISOString());
    },
    
    // These methods (Number.isInteger and Math.trunc) is not available in all browsers
    isInteger : function(num) {
    	return (typeof num === 'number') && (num % 1 === 0);
	},
    
    trunc : function(x) {
        var n = x - x%1;
        return n===0 && (x<0 || (x===0 && (1/x !== 1/0))) ? -0 : n;
    }
})