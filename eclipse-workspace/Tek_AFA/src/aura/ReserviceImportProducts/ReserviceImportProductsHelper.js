({
	loadCurrentProducts : function(component) {
        var getImportProducts = component.get("c.retrieveImportProductsVersion2");
        var enrollmentForm = component.get("v.EnrollmentForm");
        console.log(enrollmentForm.Id);
        getImportProducts.setParams({
            enrollmentFormId : enrollmentForm.Id
        });
        getImportProducts.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.ImportMarketedProducts", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(getImportProducts);    
	},
    
    loadCatalog : function(component) {
        var getCatalog = component.get("c.getCatalogForImportProductsVersion2");
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
            var addImportProducts = component.get("c.insertImportProductsVersion2");
            var enrollmentForm = component.get("v.EnrollmentForm");
            addImportProducts.setParams({
                enrollmentFormId : enrollmentForm.Id,
                products : productsToAdd
            });
            addImportProducts.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS") {
                    component.set("v.ImportMarketedProducts", result.getReturnValue());
                }
            });
            
            $A.enqueueAction(addImportProducts);
        }
    },
    
    removeImportProduct : function(component, event){
        var deleteProduct = component.get("c.removeImportProductVersion2");
        var enrollmentForm = component.get("v.EnrollmentForm");
        deleteProduct.setParams({
            productId : event.target.getAttribute("data-recId"),
            enrollmentFormId : enrollmentForm.Id
        });
        deleteProduct.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.ImportMarketedProducts", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(deleteProduct);
    }
})