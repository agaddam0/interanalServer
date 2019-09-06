({
	doInit : function(component, event, helper) {
		var action =component.get("c.getaccounts");
        var pageSize = component.get("v.pageSize");
        action.setCallback(this,function(results){
             component.set("v.paginationList",results.getReturnValue());
             component.set("v.accountList",results.getReturnValue());
             component.set("v.totalSize", component.get("v.accountList").length);
             component.set("v.start",0);
             component.set("v.end",pageSize-1);
             var paginationList = [];
             for(var i=0; i< pageSize; i++)
             {
               paginationList.push(results.getReturnValue()[i]);
             }
             component.set("v.paginationList", paginationList);
        });
         $A.enqueueAction(action);
	},
    
     onSelectChange : function(component,event,helper){
      			  var selected =component.find('records').get("v.value");
        		  var paginationList = [];
        		  var oppList = component.get("v.accountList");
        		  for(var i=0;i<selected; i++){
            	     paginationList.push(oppList[i]);
        		  }
                 component.set("v.paginationList", paginationList);
        },
       first : function(component, event, helper)
       {
           var oppList = component.get("v.accountList");
           var pageSize = component.get("v.pageSize");
           var paginationList = [];
           for(var i=0; i< pageSize; i++)
           {
             paginationList.push(oppList[i]);
           }
          component.set("v.paginationList", paginationList);

       },
    last : function(component, event, helper)
    {
        var oppList = component.get("v.accountList");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalSize");
        alert(pageSize+'/////'+totalSize);
        var paginationList = [];
        for(var i=totalSize-pageSize+1; i< totalSize; i++)
        {
        paginationList.push(oppList[i]);
        }
        component.set("v.paginationList", paginationList);
    },
    next : function(component, event, helper)
        {
        var oppList = component.get("v.accountList");
        var end = component.get("v.end");
            alert('end***'+end);
        var start = component.get("v.start");
            alert('start***'+start);
        var pageSize = component.get("v.pageSize");
            alert('pageSize****'+pageSize);
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++)
        {
        if(oppList.length > end)
        {
        paginationList.push(oppList[i]);
        counter ++ ;
        }
        }
        start = start + counter;
        end = end + counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
        },

        previous : function(component, event, helper)
        {
        var oppList = component.get("v.accountLists");
        var end = component.get("v.end");
            alert("end****"+end);
        var start = component.get("v.start");
            alert("start****"+start);
        var pageSize = component.get("v.pageSize");
            alert("pageSize****"+pageSize);
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++)
        {
        if(i > -1)
        {
        paginationList.push(oppList[i]);
        counter ++;
        }
        else {
        start++;
        }
        }
        start = start-counter;
        end = end-counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
        }

})