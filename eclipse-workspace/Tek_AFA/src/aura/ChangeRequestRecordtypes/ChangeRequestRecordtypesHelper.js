({
	getValuesAndRedirect : function(cmp) {
		var checkboxes = cmp.find("boxPack");
        var selectedTypes = cmp.get("v.SelectedTypes");
        
        for(var i = 0; i < checkboxes.length; i++) {
            if(checkboxes[i].get("v.value") == true) {
                selectedTypes.push(checkboxes[i].get("v.text"));
            }
        }
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url" : '/apex/ChangeRequestForm?id=' + cmp.get("v.recordId") + '&RecordTypeNames=' + selectedTypes
        });
        urlEvent.fire();
	}
})