({
  getAccounts: function(component) {
    var action = component.get("c.GetAccounts");
    var self = this;
    action.setCallback(this, function(a) {
        component.set("v.accounts", a.getReturnValue());
    });
    $A.enqueueAction(action);
  }
})