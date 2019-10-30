({
	doInit : function(component, event, helper) {
		helper.loadLineItems(component);
	},
    
    openModal : function(component, event, helper) {
        component.set("v.isOpen", true);
        component.set("v.SelectedProducts", []);
        component.set("v.SelectedNum", 0);
        helper.loadCatalog(component);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isOpen" , false);
    },
    
    addProducts : function(component, event, helper) {
        component.set("v.isOpen", false);
        helper.addProductsToOpportunity(component, event);
    },
    
    deleteLineItem : function(component, event, helper) {
        helper.removeOpportunityLineItem(component, event);
    },
    
    AddProductToSelectedList : function(component, event, helper) {        
        var selectedProducts = component.get("v.SelectedProducts");
        var record = event.target.getAttribute("data-recordName");
        if(event.target.checked)
        {
            selectedProducts.push(record);
        }
        else
        {
            for(var i = 0; i < selectedProducts.length; i++)
            {
                if(selectedProducts[i] == record)
                    selectedProducts.splice(i, 1);
            }

        }
        component.set("v.SelectedNum", selectedProducts.length);
        component.set("v.SelectedProducts", selectedProducts);
    },
    
    filterResults : function(component, event, helper) {
        
        var allProducts = component.get("v.ProductCatalog");
        var searchResults = component.get('v.searchResults');
        var keyword = event.getSource().get('v.value');
        
        searchResults = [];
        
        for(var i = 0; i < allProducts.length; i++)
        {
            if(allProducts[i].Product2.Name.search(new RegExp(keyword, 'i')) > -1)
            {
                searchResults.push(allProducts[i]);
            }
        }
        component.set("v.searchResults", searchResults);
    },
    
    removeSelectedFromPillList : function(component, event, helper) {
        console.log(event.currentTarget.getAttribute("data-recordName"));
        
        var selectedProducts = component.get("v.SelectedProducts");
        var record = event.currentTarget.getAttribute("data-recordName");
        
        for(var i = 0; i < selectedProducts.length; i++)
        {
            if(selectedProducts[i] == record)
                selectedProducts.splice(i, 1);
        }
        
        var checkboxes = component.find("boxPack");
        for(var c = 0; c < checkboxes.length; c++)
        {
            var elem = checkboxes[c].getElement();
            var checkboxRecordName = elem.getAttribute("data-recordname");
            if(record == checkboxRecordName)
            {
                elem.checked = false;
                break;
            }
        }
        
        component.set("v.SelectedNum", selectedProducts.length);
        component.set("v.SelectedProducts", selectedProducts);
    }
    
})