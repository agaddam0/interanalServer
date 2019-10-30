public with sharing class ProTraxRedirectLandingPage {
    
    
    public ProTraxRedirectLandingPage(ApexPages.StandardController controller)
    {
        
    }
    
    public pageReference redirect()
    {
        pageReference returnURL;
        
        system.debug('User Info: ' + UserInfo.getUserId());
        
        List<Colleague__c> colleagues = [SELECT Id FROM Colleague__c 
                                        WHERE RecordTypeId =: Constants.COLLEAGUE_COLLEAGUE 
                                        AND User__c =: system.UserInfo.getUserId()];
        
        system.debug(colleagues);
        if(colleagues.size() > 0)
        {
            returnURL = new ApexPages.StandardController(colleagues[0]).view();
        }
        else
        {
            returnURL = new ApexPages.Action('{!List}').invoke();
        }
        
        return returnURL;
    }

}