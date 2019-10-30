({
	navigateToHome : function(component, event, helper) {
		helper.fireShoppingCartNavigationEvent('HomePageView');
	},

	navigateToOrderHistory : function(component, event, helper) {
		helper.fireShoppingCartNavigationEvent('OrderHistoryView');
	},
    
    navigateToCartReview : function(component, event, helper) {
        helper.fireShoppingCartNavigationEvent('CartReviewView');
    },
    
    navigateToFavorites : function(component, event, helper) {
        helper.fireShoppingCartNavigationEvent('FavoritesView');
    }
})