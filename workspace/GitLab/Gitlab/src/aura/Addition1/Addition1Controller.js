({
    calculate : function(component, event, helper) {
    var input1=component.find("inputOne").get("v.value");
    var input2=component.find("inputTwo").get("v.value");
    var input3=component.find("inputThree").get("v.value");
    var totalval=parseInt(input1)+parseInt(input2)+parseInt(input3);
       
       
    var outputval = component.find("totalValue");
    outputval.set("v.value", totalval);
  }

})