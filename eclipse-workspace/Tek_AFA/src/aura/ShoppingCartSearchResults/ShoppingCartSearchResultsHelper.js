({
    getMaterials : function(component, event) {
        var action = component.get("c.getMarketingMaterials");
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.MarketingMaterials", result.getReturnValue());
                component.set("v.filteredMaterials", result.getReturnValue());
                this.renderPage(component);
                
                var event = $A.get("e.c:TaskCompleteEvent");
                event.setParams({
                    "PageLoaded" : "SearchResults"
                });
                event.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    filterMaterials : function(component, event) {
        var masterList = component.get("v.MarketingMaterials"),
            filteredTagList = [],
            keywordTagList = [],
            searchTermFilteredList = [],
            filteredList = [],
            keyword = component.get("v.keyword"),
            selectedTags = component.get("v.selectedTags"),
            keywordRegEx = '';
        
        if(!keyword && selectedTags.length == 0)
        {
            component.set("v.filteredMaterials", masterList);
            this.renderPage(component);
            return;
        }
        
        if(keyword == 'Favorites')
        {
            this.filterFavorites(component);
        }
        else {
            if(keyword) {
                keywordRegEx = new RegExp(this.escapeRegExp(keyword), 'i');
            }
            for(let mm of masterList)
            {
                let matchFound = false;
                
                // search the tags for equal to keyword
                if (!mm.Record.Marketing_Material_Tags__r) {
                        continue;
                }
                
                if(keywordRegEx)
                {
                    for(let mmTag of mm.Record.Marketing_Material_Tags__r)
                    {
                        if(mmTag.Tag__r.Name.search(keywordRegEx) > -1)
                        {
                            keywordTagList.push(mm);
                            matchFound = true;
                            break;
                        }
                    }
                }
                
                
                // Skip if match found already or if there are no selected tags
                if (matchFound || !selectedTags) {
                    continue;
                }
                
                // search tags for equal to selectedTags
                for(let selectedTag of selectedTags)
                {
                    if (matchFound) {
                        break;
                    }
                    
                    for(let mmTag of mm.Record.Marketing_Material_Tags__r)
                    {
                        if(selectedTag == mmTag.Tag__r.Name)
                        {
                            filteredTagList.push(mm);
                            matchFound = true;
                            break;
                        }
                    }
                }
            }
            
            // Now we search in our filtered list for keyword matches on
            // Title or Form Number.  If no match, remove from filtered list
            
            if(keywordRegEx) {
                // If there are no tags selected, search on the master list
                if(selectedTags.length == 0) {
                    filteredTagList = masterList;
                } 
                
                searchTermFilteredList = filteredTagList.filter(function(e) {
                    if((e.Record.Title__c && e.Record.Title__c.search(keywordRegEx) > -1) ||
                       (e.Record.Material_Number__c && e.Record.Material_Number__c.search(keywordRegEx) > -1))
                    {
                        return true;
                    }
                });
                
                filteredList = searchTermFilteredList.concat(keywordTagList);
            } else {
                filteredList = filteredTagList.concat(keywordTagList);
            }
            
            component.set("v.filteredMaterials", filteredList.reduce(function(a,b){if(a.indexOf(b)<0)a.push(b);return a;},[]));
            this.renderPage(component); 
        }        
    },
    
    filterFavorites : function(component) {
        var masterList = component.get("v.MarketingMaterials"),
            filteredList = [];
        
        for(let mm of masterList)
        {
            if(mm.IsFavorite)
                filteredList.push(mm);
        }
        
        component.set("v.filteredMaterials", filteredList.reduce(function(a,b){if(a.indexOf(b)<0)a.push(b);return a;},[]));
        this.renderPage(component);
    },
    
    addMaterialToCart : function(component, event) {
        var materialId = event.getSource().get('v.name');
        var preenrollmentMarketingFormId = component.get('v.preenrollmentMarketingFormId');
        var material;
        var filteredList = component.get("v.filteredMaterials");
        
        for(var i = 0; i < filteredList.length; i++)
        {
            if(filteredList[i].Record.Id == materialId)
            {
                material = filteredList[i].Record;
                break;
            }                
        }
        
        var action = component.get('c.addMarketingMaterialToCart');
        action.setParams({
            "marketingMaterial" : material,
            "quantity" : 1,
            "customOrderLineFields" : {"Preenrollment_Marketing_Form__c" : preenrollmentMarketingFormId }
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                
                // send event component to update line item count
                var cartInformation = result.getReturnValue();
                var event = $A.get("e.c:ShoppingCartOrderDetailsEvent");
                event.setParams({
                    "Order" : cartInformation.Order,
                    "OrderLineItems" : cartInformation.OrderLineItems
                });
                event.fire();
                
                // show toast that item was successfully added to cart
                this.showSuccessToast("Added to the cart successfully!")
            }
            else if (component.isValid() && state !== "SUCCESS") {
                var errors = result.getError();
                if (errors && Array.isArray(errors) && errors.length > 0)
                {
                    let errorData = JSON.parse(errors[0].message);
                    this.showErrorToast(errorData.message);
                }
            }
        });
        $A.enqueueAction(action);        
    },
    
    updateFavorite : function(component, event) {
        var isFavoriteString = event.currentTarget.getAttribute('data-favorite');        
        var isFavorite = (isFavoriteString == 'true');
        if(isFavorite)
            this.removeFavorite(component, event, isFavorite);
        else
            this.addFavorite(component, event, isFavorite);
    },
    
    removeFavorite : function(component, event, isFavorite) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var action = component.get("c.removeUserFavorite");
        
        action.setParams({
            "materialId" : materialId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                
                this.updateMasterListWithFavorite(component, materialId, isFavorite, true);
            }
        });
        $A.enqueueAction(action);
    },
    
    addFavorite : function(component, event, isFavorite) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var action = component.get("c.addUserFavorite");
        
        action.setParams({
            "materialId" : materialId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                
                this.updateMasterListWithFavorite(component, materialId, isFavorite, true);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateMasterListWithFavorite : function(component, materialId, isFavorite, rerender){
        var masterList = component.get("v.MarketingMaterials");
        for(let mm of masterList)
        {
            if(mm.Record.Id == materialId)
            {
                // set to the opposite of the current value
                mm.IsFavorite = !isFavorite;
                break;
            }
        }
        
        component.set("v.MarketingMaterials", masterList);

        if (rerender) {
            this.renderPage(component);
        }
    },
    
    renderPage: function(component) {
        var records = component.get("v.filteredMaterials"),
            totalPages = Math.trunc(records.length/25)+1,
            pageNumber = component.get("v.pageNumber"),
            pageRecords = records.slice((pageNumber-1)*25, pageNumber*25);
        component.set("v.maxPage", totalPages);
        component.set("v.filteredMaterialsPage", pageRecords);
        window.scrollTo(0, 0);
    },
    
    showSuccessToast : function(successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": successMessage,
            "type": 'success'
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": errorMessage,
            "type": 'error'
        });
        toastEvent.fire();
    },

    escapeRegExp : function(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
    }
})