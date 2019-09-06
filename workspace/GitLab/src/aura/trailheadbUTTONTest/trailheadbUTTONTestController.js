({
   nameThatButton : function(cmp, event, helper) {
   var whichOne = event.getSource().getLocalId();
   console.log(whichOne);
   cmp.set("v.whichButton", whichOne);
    }

})