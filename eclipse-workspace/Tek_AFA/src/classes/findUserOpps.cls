public class findUserOpps {
    public Id userId {get;set;}
    public List<Opportunity> opportunities {
        get {
            opportunities = [select Name, StageName, Record_Type__c from Opportunity WHERE OwnerId =: userId AND Opportunity.StageName != 'Closed Won' AND Opportunity.StageName != 'Closed Lost' AND Opportunity.StageName != 'Enrollment Closed' AND Opportunity.StageName != 'Saved'];
            return opportunities;
        }
        set;
    }
    
    public findUserOpps() {
               
    }
}