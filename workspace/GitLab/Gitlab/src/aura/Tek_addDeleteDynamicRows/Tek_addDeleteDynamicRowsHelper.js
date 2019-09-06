({
	addAccountRecord : function(component,event) {
		var accountlist=component.get('v.accountlist');
        accountlist.push({
            'sobjectType': 'Account',
            'Name': '',
            'AccountNumber': '',
            'Phone': ''
        });
         component.set("v.accountlist", accountlist);
	},
    validateAccountList: function(component, event) {
        //Validate all account records
        var isValid = true;
        var accountlist = component.get("v.accountlist");
        for (var i = 0; i < accountlist.length; i++) {
            if (accountlist[i].Name == '') {
                isValid = false;
                alert('Account Name cannot be blank on row number ' + (i + 1));
            }
        }
        return isValid;
    },
    saveAccountList: function(component, event, helper) {
        //Call Apex class and pass account list parameters
        var action = component.get("c.insertAcclist");
        action.setParams({
            "accList": component.get("v.accountlist")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errors = response.getError();
            
            alert('ashokgaddam'+state);
            if (state === "SUCCESS") {
                component.set("v.accountlist", []);
                alert('Account records saved successfully');
            }
        }); 
        $A.enqueueAction(action);
    },
})