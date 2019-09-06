({
	calucaltemonthlypayment : function(component) {
        var princple=component.get("v.principle");
        var years=component.get("v.years");
        var rate=component.get("v.rate");
        var monthlyrate=rate/100/12;
        var monthlypayment=princple*monthlyrate;
        component.set("v.monthlypayment",monthlypayment);
		
	}
})