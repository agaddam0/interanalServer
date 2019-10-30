({
	doInit : function(component, event, helper) {
		helper.getMaterials(component, event);
	},
    
    showSearchTerms : function(component, event, helper) {
    	var keyword = event.getParam('keywords');
        var tags = event.getParam('selectedTags');
        var searchArray = [];
        if(keyword)
            searchArray.push(keyword);
        
        if(tags)
        {
            for(var i = 0; i < tags.length; i++)
            {
                searchArray.push(tags[i]);
            }
            
            component.set('v.selectedTags', tags);
        }
        
        component.set('v.searchTerms', searchArray);
        component.set('v.keyword', keyword);        
        helper.filterMaterials(component, event);        
    },
    
    goToDetails : function(component, event, helper) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var material;
        var filteredList = component.get("v.filteredMaterials");
        
        for(var i = 0; i < filteredList.length; i++)
        {
            if(filteredList[i].Record.Id == materialId)
            {
                material = filteredList[i];
                break;
            }
                
        }
        
        var keyword = component.get("v.keyword");
        var location;
        if(keyword == 'Favorites')
            location = 'FavoritesView';
            
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "MaterialDetailsView",
            "MarketingMaterial" : material,
            "ReturnLocation" : location
        });
        newEvent.fire();
        
    },
    
    addToCart: function(component, event, helper) {
        helper.addMaterialToCart(component, event);
    },
    
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    
    searchByTagName : function(component, event, helper) {
        var tagName = event.currentTarget.getAttribute('data-name');
        
        var newEvent = $A.get("e.c:ShoppingCartTagClickedEvent");
        newEvent.setParams({
            "TagClicked" : tagName
        });
        newEvent.fire();
    },
    
    toggleFavorite : function(component, event, helper) {
        helper.updateFavorite(component, event);
    },
    
    updateFavoriteInMasterList : function(component, event, helper) {
        var materialId = event.getParam("materialId");
        var isFavorite = event.getParam("isFavorite");
        var rerender = event.getParam("rerender");
        helper.updateMasterListWithFavorite(component, materialId, isFavorite, rerender);
    }
})