({
    doInit : function(component, event, helper) {
        helper.loadEnrollmentSiteInfo(component);
    },

    onScheduleEnrollmentSiteDatesPreviousButtonClick : function(component, event, helper) {
        helper.openEnrollmentSites(component);
    },

    onNewLocationClick : function(component, event, helper) {
        helper.loadNewEnrollmentSiteModal(component);
    },

    onEditEnrollmentSiteClick : function(component, event, helper) {
        var enrollmentSiteId = event.getSource().get('v.value');

        helper.loadEditEnrollmentSiteModal(component, enrollmentSiteId);
    },

    saveNewEnrollmentSiteClick : function(component, event, helper) {
        helper.saveNewEnrollmentSite(component);
    },

    onScheduleEnrollmentSiteDateClick : function(component, event, helper) {
        var enrollmentSiteId = event.getSource().get('v.value');

        helper.loadNewEnrollmentSiteDateModal(component, enrollmentSiteId);
    },

    saveNewEnrollmentSiteDateClick : function(component, event, helper) {
        helper.saveNewEnrollmentSiteDate(component);
    },

    onEditEnrollmentSiteDateClick : function(component, event, helper) {
        var editLink = event.currentTarget;
        var enrollmentSiteDateId = editLink.getAttribute('data-enrollmentSiteDateId');
        var enrollmentSiteDate = helper.findEnrollmentSiteDate(component, enrollmentSiteDateId);
        
        helper.loadEditEnrollmentSiteDateModal(component, enrollmentSiteDate);
    },

    saveEditEnrollmentSiteClick : function(component, event, helper) {
        helper.saveEditedEnrollmentSite(component);
    },

    saveEditEnrollmentSiteDateClick : function(component, event, helper) {
        helper.saveEditedEnrollmentSiteDate(component);
    },

    onDeleteEnrollmentSiteDateClick : function(component, event, helper) {
        var deleteLink = event.currentTarget;
        var enrollmentSiteDateId = deleteLink.getAttribute('data-enrollmentSiteDateId');
        var enrollmentSiteDate = helper.findEnrollmentSiteDate(component, enrollmentSiteDateId);
        
        helper.showDeleteEnrollmentSiteDateModal(component);
        component.set('v.enrollmentSiteDateToDelete', enrollmentSiteDate);
    },

    closeDeleteEnrollmentSiteDateModal : function(component, event, helper) {
        helper.hideDeleteEnrollmentSiteDateModal(component);
    },

    onDeleteEnrollmentSiteDate : function(component, event, helper) {
        var enrollmentSiteDateToDelete = component.get('v.enrollmentSiteDateToDelete');
        helper.deleteEnrollmentSiteDate(component, enrollmentSiteDateToDelete);
    },
})