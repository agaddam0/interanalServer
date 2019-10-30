public class ProductivityDataBLogic {
    
    public static void beforeInsert(List<Productivity_Data__c> data)
    {
        UpdateIntegrationOwnerToAgent(data);
    }
    
    public static void UpdateIntegrationOwnerToAgent(List<Productivity_Data__c> data)
    {
        Map<Id, Boolean> userToActiveStatus = new Map<Id, Boolean>();
        List<Id> userIds = new List<Id>();
        Id profileId = userinfo.getProfileId();
        String ProfileName = [SELECT Name FROM Profile WHERE Id =: profileId LIMIT 1].Name;
        for(Productivity_Data__c d : data)
        {
            if(d.Agent__c != null)
            	userIds.add(d.Agent__c);
        }
        
        List<User> users = new List<User>([SELECT Id, isActive FROM User where Id IN: userIds]);
        
        for(User u : users)
        {
            userToActiveStatus.put(u.Id, u.isActive);
        }
        
        for(Productivity_Data__c d : data)
        {
            system.debug('### ' + d.OwnerId);
            if(ProfileName == 'Integration User')
            {
                system.debug('### UserToActiveStatus ' + string.valueOf(userToActiveStatus.get(d.Agent__c)));
                if(d.Agent__c != null && userToActiveStatus.get(d.Agent__c))
                {
                    d.OwnerId = d.Agent__c;
                } 
            }
        }
    }
}