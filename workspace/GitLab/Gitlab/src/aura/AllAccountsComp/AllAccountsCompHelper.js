({
    getAllContacts : function(component, event, helper) {

        var action = component.get("c.get10COntacts");

        action.setCallback(this, function(a){

            component.set("v.contactRows", a.getReturnValue());

        });

        $A.enqueueAction(action);

    }

})