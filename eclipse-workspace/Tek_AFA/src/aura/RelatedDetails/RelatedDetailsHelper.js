({
	waiting : function(component) {
        var spinner = component.find("wait");
        var recordView = component.find("recordDiv");
        $A.util.removeClass(spinner, "slds-assistive-text");
        $A.util.addClass(recordView, "slds-assistive-text");
    },
    doneWaiting : function(component) {
        var spinner = component.find("wait");
        var recordView = component.find("recordDiv");
        $A.util.addClass(spinner, "slds-assistive-text");
        $A.util.removeClass(recordView, "slds-assistive-text");
    }
})