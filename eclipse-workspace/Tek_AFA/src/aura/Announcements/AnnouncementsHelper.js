({
	getAnnouncements : function(component, event) {
		var action = component.get("c.getAnnouncement");
        
        action.setParams({
            'RecordTypeName' : component.get('v.RecordTypeName')
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
            	var announcements = result.getReturnValue();
                
                if (announcements) {
            		announcements[0].ShowInCarousel = true;
            	}
                
                var event = $A.get("e.c:TaskCompleteEvent");
                event.setParams({
                    "PageLoaded" : "Announcements"
                });
                event.fire();
                
                component.set('v.wrapper', announcements);
            }
        });
        
        $A.enqueueAction(action);
	},
    
    navigateToCarouselItem : function(component, desiredIndex) {
    	var transformToUse = 'transform:translateX(-' + desiredIndex + '00%)';
    	
    	var carouselPanels = component.find('carouselPanels');
    	var carouselPanelsElement = carouselPanels.getElement();
    	carouselPanelsElement.style = transformToUse;
    	
    	var announcements = component.get('v.wrapper');
    	
    	for (let announcement of announcements) {
    		announcement.ShowInCarousel = false;
    	}
    	
    	var announcementItemToShow = announcements[desiredIndex];
    	announcementItemToShow.ShowInCarousel = true;
    	
    	component.set('v.wrapper', announcements);
	},
	
	getCurrentAnnouncement : function(announcements) {
		return announcements.findIndex(function(announcement) { 
			return announcement.ShowInCarousel;
		});
	},
})