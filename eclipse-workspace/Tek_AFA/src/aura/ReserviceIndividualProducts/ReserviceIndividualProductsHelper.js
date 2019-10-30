({
	loadCurrentProducts : function(component) {
        var getIndividualProducts = component.get("c.retrieveIndividualProductsVersion2");
        var enrollmentForm = component.get("v.EnrollmentForm");
        getIndividualProducts.setParams({
            enrollmentFormId : enrollmentForm.Id
        });
        getIndividualProducts.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.IndividualMarketedProducts", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(getIndividualProducts);    
	},
    
    loadCatalog : function(component) {
        var getCatalog = component.get("c.getCatalogForIndividualProductsVersion2");
        var enrollmentForm = component.get("v.EnrollmentForm");
        getCatalog.setParams({
            enrollmentFormId : enrollmentForm.Id,
            division : enrollmentForm.Division__c
        });
        getCatalog.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.productCatalog", result.getReturnValue());
                component.set("v.searchResults", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(getCatalog);
    },
    
    addProductsToEnrollmentForm : function(component, event) {
        var selected = component.get("v.SelectedProducts");
        var allProducts = component.get("v.productCatalog");
        var productsToAdd = [];
        
        for(var i = 0; i < allProducts.length; i++)
        {
            for(var s = 0; s < selected.length; s++)
            {
                if(allProducts[i].Name == selected[s])
                {
                    productsToAdd.push(allProducts[i]);
                }
            }
        }
        
        if(productsToAdd.length > 0)
        {
            var addIndividualProducts = component.get("c.insertIndividualProductsVersion2");
            var enrollmentForm = component.get("v.EnrollmentForm");
            addIndividualProducts.setParams({
                enrollmentFormId : enrollmentForm.Id,
                products : productsToAdd
            });
            addIndividualProducts.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS") {
                    component.set("v.IndividualMarketedProducts", result.getReturnValue());
                }
            });
            
            $A.enqueueAction(addIndividualProducts);
        }
    },
    
    removeIndividualProduct : function(component, event){
        var deleteProduct = component.get("c.removeIndividualProductVersion2");
        var enrollmentForm = component.get("v.EnrollmentForm");
        deleteProduct.setParams({
            productId : event.target.getAttribute("data-recId"),
            enrollmentFormId : enrollmentForm.Id
        });
        deleteProduct.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.IndividualMarketedProducts", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(deleteProduct);
    }
})