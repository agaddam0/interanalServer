({
    handleClick: function(cmp) {
        cmp.set("v.tabId", "3");
    },
    handleChange: function(cmp) {
        //Display content on the Item Three tab
        var selected = cmp.get("v.tabId");
        cmp.find("tabs").set("v.selectedTabId", selected);
    }
})