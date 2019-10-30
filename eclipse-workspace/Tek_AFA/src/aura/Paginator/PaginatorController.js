({
    loadMore : function(component, event, helper) {
        component.set("v.sliceNo", component.get("v.sliceNo") + 1);
        component.set("v.showLess", true);
        helper.renderPage(component);
    },
    
    showLess : function(component, event, helper) {
        component.set("v.sliceNo", component.get("v.sliceNo") - 1);
        helper.renderPage(component);
    },
    
    reload : function(component, event, helper) {
    	helper.renderPage(component, event, helper);
    }
})