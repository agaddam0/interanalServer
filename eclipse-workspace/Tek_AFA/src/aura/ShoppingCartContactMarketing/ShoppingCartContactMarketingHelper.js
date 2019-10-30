({
    fireShoppingCartNavigationEvent : function(navigate) {
		var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : navigate
        });
        newEvent.fire();
	}
})