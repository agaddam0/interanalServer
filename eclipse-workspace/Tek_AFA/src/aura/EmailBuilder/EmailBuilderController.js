({
    init : function(component, event, helper) {
        helper.loadEmailBuilder(component);
    },

    onEmailTemplateChange : function(component, event, helper) {
        helper.onEmailTemplateChange(component);
    },

    previewEmail : function(component, event, helper) {
        helper.loadEmailPreview(component, false);
    },

    sendEmailToRecipient : function(component, event, helper) {
        helper.sendEmailToRecipient(component);
    },

    openSendConfirmation : function(component, event, helper) {
        helper.openSendConfirmation(component);
    },

    closeSendConfirmation : function(component, event, helper) {
        helper.closeSendConfirmation(component);
    }
})