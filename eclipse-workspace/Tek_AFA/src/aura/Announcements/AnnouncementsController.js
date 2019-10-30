({
	doInit : function(component, event, helper) {
		helper.getAnnouncements(component, event);
	},
    
    openModal : function(component, event, helper) {
        var videoUrl = event.currentTarget.getAttribute('data-url');
        component.set("v.videoURL", videoUrl);
        component.set("v.isOpen", true);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isOpen" , false);
    },
    
    onCarouselIndicatorClick : function(component, event, helper) {
    	var currentIndicator = event.currentTarget;
    	var index = currentIndicator.getAttribute('data-item-num');
    	
    	helper.navigateToCarouselItem(component, index);
    },
    
    navToNextItem : function(component, event, helper) {
    	var announcements = component.get('v.wrapper');
    	var currentIndex = helper.getCurrentAnnouncement(announcements);
    	
    	var start = 0;
    	var end = announcements.length - 1;
    	var nextIndex = currentIndex + 1;
    	
    	if (nextIndex > end) {
    		nextIndex = start;
    	}
    	
    	helper.navigateToCarouselItem(component, nextIndex);
    },
    
    navToPreviousItem : function(component, event, helper) {
    	var announcements = component.get('v.wrapper');
    	var currentIndex = helper.getCurrentAnnouncement(announcements);
    	
    	var start = 0;
    	var end = announcements.length - 1;
    	var nextIndex = currentIndex - 1;
    	
    	if (nextIndex < start) {
    		nextIndex = end;
    	}
    	
    	helper.navigateToCarouselItem(component, nextIndex);
    },
})