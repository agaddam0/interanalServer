({
	init : function(cmp, ev) {
		var action = cmp.get("c.GetAccountNames");
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var accs=response.getReturnValue()
				var wrappers=new Array();
                for (var idx=0; idx<accs.length; idx++) {
					var wrapper = { 'acc' : accs[idx], 
									'selected' : false
									};
					wrappers.push(wrapper);
                }
                cmp.set('v.wrappers', wrappers);
            }
            else if (state === "ERROR") {
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
	},
	getAccounts : function(cmp, ev) {
		var action = cmp.get("c.GetAccountDetails");
        var wrappers=cmp.get('v.wrappers');
        var ids=new Array();
        for (var idx=0; idx<wrappers.length; idx++) {
            if (wrappers[idx].selected) {
	            ids.push(wrappers[idx].acc.Id);
            }
        }
        var idListJSON=JSON.stringify(ids);
        action.setParams({
                   "idListJSONStr": idListJSON
        });
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var accs=response.getReturnValue()
                cmp.set('v.accounts', accs);
            }
            else if (state === "ERROR") {
		        var errors = response.getError();
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
	}
})