({
  doInit: function(component, event, helper) {
    helper.toggle(component, event);
    helper.setToday(component, event);
    helper.getRecords(component, event);
    helper.getRecordType(component, event);
  },

  goToRecord: function(component, event, handler) {
    var sObjectEvent = $A.get("e.force:navigateToSObject");
    var selectedId = event.currentTarget.getAttribute("data-recId");
    sObjectEvent.setParams({
      recordId: selectedId
    });
    sObjectEvent.fire();
  },

  onSelectChange: function(component, event, helper) {
    helper.toggle(component, event);
    helper.getRecords(component, event);
  },

  searchDates: function(component, event, helper) {
    helper.toggle(component, event);
    helper.searchRecords(component, event);
  },

  newEvent: function(component, event, helper) {
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
      entityApiName: "Event",
      recordTypeId: component.get("v.newEventRecordType")
    });
    createRecordEvent.fire();
  },

  loadMore: function(component, event, helper) {
    component.set("v.sliceNo", component.get("v.sliceNo") + 1);
    component.set("v.showLess", true);
    helper.renderPage(component);
  },

  showLess: function(component, event, helper) {
    component.set("v.sliceNo", component.get("v.sliceNo") - 1);
    helper.renderPage(component);
  }
});