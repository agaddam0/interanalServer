({
    doInit : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        helper.loadShoppingCart(component);
    },
    
    reInit : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        component.set("v.showMarketplace", true);
        helper.loadShoppingCart(component);
        helper.showPages(component, helper, "HomePageView", null);
    },
    
    showPages : function(component, event, helper) {
        var desiredNavigationPage = event.getParam("navigate");
        var orderId = event.getParam("OrderId");
        var returnLocation = event.getParam("ReturnLocation");
        
        helper.showPages(component, helper, desiredNavigationPage, orderId, returnLocation);
    },
    
    reloadCart : function(component, event, helper) {
        helper.loadShoppingCart(component);
    },
    
    updateLineItems : function(component, event, helper) {
        var order = event.getParam("Order");
        var lineItems = event.getParam("OrderLineItems");
        component.set("v.Cart", order);
        component.set("v.CartOrderLineItems", lineItems);
    },
    
    destroyComponent : function(component, event, helper) {
        component.set("v.showMarketplace", false);
    },
    
    closeFlowModal : function(component, event, helper) {
        component.set("v.flowModalIssOpen", false);
    },
    
    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.flowModalIssOpen", false);
        }
    },
    
    hideLoadingSpinner : function(component, event, helper) {
        var PageLoaded = event.getParam('PageLoaded');
        
        if(PageLoaded == 'SearchResults')
            component.set("v.MarketingMaterialsLoaded", true);
        
        if(PageLoaded == 'Announcements')
            component.set("v.AnnouncementsLoaded", true);
        
        if(PageLoaded == 'FeaturedItems')
            component.set("v.FeaturedItemsLoaded", true);
        
        var MaterialsLoaded = component.get("v.MarketingMaterialsLoaded");
        var AnnouncementsLoaded = component.get("v.AnnouncementsLoaded");
        var FeaturedItemsLoaded = component.get("v.FeaturedItemsLoaded");
        
        if(MaterialsLoaded && AnnouncementsLoaded && FeaturedItemsLoaded)
        	component.set("v.ShowSpinner", false);
    }
})