({
    showPagesConfig : {
        "HomePageView" : {
            SectionsToShow: ["ShowSideSearch", "ShowFeaturePage"]
        },
        "SearchResultsView" : {
            SectionsToShow: ["ShowSideSearch", "ShowSearchResults"]
        },
        "MaterialDetailsView" : {
            SectionsToShow: ["ShowDetailPage"]
        },
        "OrderHistoryView" : {
            SectionsToShow: ["ShowOrderHistory"],
            Load: function(component, helper) {
                helper.loadOrderHistory(component);
            }
        },
        "OrderConfirmationView" : {
            SectionsToShow: ["ShowOrderConfirmation"],
            Load: function(component, helper, orderId) {
                helper.loadOrderConfirmation(component, orderId);
                helper.preventPreenrollmentSubsequentOrder(component);
            }
        },
        "CartReviewView" : {
            SectionsToShow: ["ShowCartReview"],
            Load : function(component, helper, orderId, returnLocation) {
                if (orderId) {
                    helper.loadShoppingCart(component);
                }
                
                if (returnLocation) {
                    component.set('v.ReturnLocation', returnLocation);
                }
            }
        },
        "CartCheckoutView" : {
            SectionsToShow: ["ShowCheckoutPage"],
            Load: function(component, helper) {
                helper.loadShoppingCart(component);
            }
        },
        "FavoritesView" : {
            SectionsToShow: ["ShowSideSearch", "ShowSearchResults"],
            Load: function(component, helper) {
                helper.loadFavorites(component);
            }
        },
        "Contact_Marketing" : {
            Load: function(component, helper) {
                helper.loadFlowModal(component, 'Contact_Marketing');
            }
        },
        "PreenrollmentView": {
            SectionsToShow: ["ShowPreenrollment"],
            Load : function(component, helper, orderId, returnLocation) {
                if (returnLocation) {
                    component.set('v.ReturnLocation', returnLocation);
                }
            }
        },
        "GroupMeetingVideo": {
            Load: function(component, helper) {
                helper.loadFlowModal(component, 'Video_Request_Flow');
            }
        }
        
    },

    showPages : function(component, helper, desiredNavigationPage, orderId, returnLocation) {
        var desiredPageConfig = this.showPagesConfig[desiredNavigationPage];
        // scroll to top
        if(desiredNavigationPage != "SearchResultsView")
            window.scrollTo(0, 0);
        
        if (desiredPageConfig)
        {
            if(desiredPageConfig.SectionsToShow &&
               desiredPageConfig.SectionsToShow.length > 0) {
                
                helper.hideAllPages(component);
                
                for (let sectionToShow of desiredPageConfig.SectionsToShow) {
                    component.set('v.' + sectionToShow, true);
                }
            }
                
            if (desiredPageConfig.Load &&
                typeof desiredPageConfig.Load === "function") {
                desiredPageConfig.Load(component, helper, orderId, returnLocation);
            }
            
            var currentReturnLocation = component.get('v.ReturnLocation');
            
            if (currentReturnLocation && !returnLocation) {
                component.set('v.ReturnLocation', '');
            }
        }
            
    },
    
    hideAllPages : function(component) {
        component.set('v.ShowOrderHistory', false);
        component.set('v.ShowDetailPage', false);
        component.set('v.ShowSearchResults', false);
        component.set('v.ShowFeaturePage', false);
        component.set('v.ShowSideSearch', false);
        component.set('v.ShowOrderHistory', false);
        component.set('v.ShowOrderConfirmation', false);
        component.set('v.ShowCartReview', false);
        component.set('v.ShowCheckoutPage', false);
        component.set('v.ShowPreenrollment', false);
    },
    
    loadOrderHistory : function(component) {
        var orderHistory = component.find('orderHistory');
        orderHistory.loadOrderHistory();
    },

    loadOrderConfirmation : function(component, orderId) {
        component.set('v.ConfirmationOrderId', orderId);
    },
    
    loadShoppingCart : function(component) {
        var action = component.get("c.getCart");
        var initialLoad = component.get("v.firstLoad");
        var helper = this;
        
        action.setParams({
            "firstLoad" : initialLoad
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var cartInformation = result.getReturnValue();
                component.set('v.Cart', cartInformation.Order);
                component.set('v.CartOrderLineItems', cartInformation.OrderLineItems);
                component.set('v.SalesOffice', cartInformation.SalesOffice);
                component.set('v.firstLoad', false);
                
                var pageReference = component.get("v.pageReference");
                var allowPreenrollmentOrder = component.get("v.allowPreenrollmentOrder");
                
                if (pageReference &&
                    pageReference.state.tag &&
                    initialLoad) {
                    helper.loadSearchTag(component, pageReference.state.tag);
                }

                if (pageReference &&
                    pageReference.state.c__PreenrollmentMarketingFormId &&
                    allowPreenrollmentOrder &&
                    initialLoad) {
                    component.set('v.preenrollmentMarketingFormId', pageReference.state.c__PreenrollmentMarketingFormId);
                    component.set('v.enrollmentOpportunityId', pageReference.state.c__EnrollmentOpportunityId);
                    
                    helper.showPages(component, helper, 'PreenrollmentView', '', '');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    loadFavorites : function(component) {
        // send search event with favorites keyword
        var newEvent = $A.get("e.c:ShoppingCartSearchTermsEvent");
        newEvent.setParams({
            "keywords" : 'Favorites'
        });
        newEvent.fire();
    },

    loadSearchTag : function(component, searchTag) {
        // send search event with search tag
        var newEvent = $A.get("e.c:ShoppingCartSearchTermsEvent");
        newEvent.setParams({
            "selectedTags" : [searchTag]
        });
        newEvent.fire();
        
        var helper = this;
        this.showPages(component, helper, "SearchResultsView");
    },
    
    loadFlowModal : function(component, flowName) {
        // doesn't matter where we are in Marketplace, show modal
        component.set("v.flowModalIssOpen", true);
        var flow = component.find("flowModal");
        flow.startFlow(flowName);
    },

    preventPreenrollmentSubsequentOrder : function(component) {
        component.set("v.preenrollmentMarketingFormId", null);
        component.set("v.allowPreenrollmentOrder", false);
    }
})