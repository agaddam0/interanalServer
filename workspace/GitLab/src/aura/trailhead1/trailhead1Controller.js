({
	handleClick : function(component, event, helper) {
        // METHOD 1
		/*var btnClicked = event.getSource();         // the button
        var btnMessage = btnClicked.get("v.label"); // the button's label
        component.set("v.message", btnMessage);  
        console.log("handleClick2: Message: " + newMessage);
       */
        // METHOD 2
        var newMessage = event.getSource().get("v.label");
        console.log("handleClick2: Message: " + newMessage);
        component.set("v.message", newMessage+'ASHOK');     // update our message
        

        // METHOD 3
      //  component.set("v.message", event.getSource().get("v.label"));

	}
})