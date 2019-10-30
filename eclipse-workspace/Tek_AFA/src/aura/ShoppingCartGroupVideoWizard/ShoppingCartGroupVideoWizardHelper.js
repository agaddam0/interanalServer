({
    startGroupMeetingVideoFlow : function(component) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "GroupMeetingVideo"
        });
        newEvent.fire();
    }
})