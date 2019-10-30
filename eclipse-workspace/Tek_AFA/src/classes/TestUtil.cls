@isTest
public with sharing class TestUtil {
    public static void assertPageHasErrorMessage() {
        system.assert(ApexPages.hasMessages(ApexPages.Severity.Error), 'The page has no error messages.');
    }
    
    public static void assertPageHasMessage(String expectedPageMessage) {
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();

        system.assert(pageMessages.size() > 0, 'There are no page messages.');
        Boolean messageFound = false;

        for (ApexPages.Message pageMessage : pageMessages) {
            String msg = pageMessage.getSummary();

            if (msg == expectedPageMessage) {
                messageFound = true;
                break;
            }
        }

        system.assert(messageFound, 'The expected page message, ' + expectedPageMessage + ', was not found.');
    }
    
    public static void assertPageDoesNotHaveMessage(String messageToNotHave) {
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();

        Boolean messageFound = false;

        if (pageMessages != null) {
	        for (ApexPages.Message pageMessage : pageMessages) {
	            String msg = pageMessage.getSummary();
	
	            if (msg == messageToNotHave) {
	                messageFound = true;
	                break;
	            }
	        }
        }

        system.assertEquals(false, messageFound, 'The page message, ' + messageToNotHave + ', was found when it should not have been.');
    }
}