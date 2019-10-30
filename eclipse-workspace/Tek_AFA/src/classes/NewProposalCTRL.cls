public class NewProposalCTRL {
    @AuraEnabled
    public static List<RecordTypeObject> getRecordTypeObjectsForObject(string sObjectName)
    {
        List<RecordTypeObject> AvailableRecordTypeNames = new List<RecordTypeObject>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(sObjectName);
        List<Schema.RecordTypeInfo> rti = sobjType.getDescribe().getRecordTypeInfos();
        system.debug('RTI: ' + rti);
        for(Schema.RecordTypeInfo rt : rti)
        {
            if(rt.isAvailable() && !rt.isMaster())
            {                
                AvailableRecordTypeNames.add(new RecordTypeObject(rt.getRecordTypeId(), rt.getName(), getLabel(rt.getName()), getSortOrder(rt.getName())));
            }
        } 
        
        system.debug('Record Type Names: ' + AvailableRecordTypeNames);
        AvailableRecordTypeNames.sort();
        
        return AvailableRecordTypeNames;
    }
    
    public static String getLabel(String typeName)
    {
        if(typeName == 'Custom Proposal')
            return system.label.Custom_Proposal;
        if(typeName == 'Generic Proposal')
            return system.label.Generic_Proposal;
        if(typeName == 'Group Product Only Proposal')
            return system.label.Group_Product_Only_Proposal;
        if(typeName == 'RFP')
            return system.label.RFP;
        
        return '';
    }
    
    public static Integer getSortOrder(String typeName)
    {
        if(typeName == 'Custom Proposal')
            return 3;
        if(typeName == 'Generic Proposal')
            return 2;
        if(typeName == 'Group Product Only Proposal')
            return 1;
        if(typeName == 'RFP')
            return 4;
        
        return 0;
    }
    
    @AuraEnabled
    public static Proposal__c insertProposal(String RecordTypeId, String OpportunityId)
    {
        User u = [SELECT Id, AFA_Division__c FROM User WHERE Id =: system.UserInfo.getUserId()];
        
        Proposal__c newProposal = new Proposal__c();
        newProposal.RecordTypeId = RecordTypeId;
        newProposal.Status__c = 'In Progress';
        newProposal.Division__c = u.AFA_Division__c;
        newProposal.Main_Rep__c = system.UserInfo.getUserId();
        system.debug(OpportunityId);
        if(OpportunityId != null && OpportunityId != '')
        {
            Opportunity o = [SELECT Id, Estimated_Employees__c FROM Opportunity WHERE Id =: OpportunityId];
            newProposal.Opportunity__c = o.Id;
            newProposal.EligibleEmployees__c = o.Estimated_Employees__c;
        }
            
        
        insert newProposal;
        
        return newProposal;
    }
    
    @AuraEnabled
    public static Proposal__c retrieveProposal(String recordId)
    {
        Set<String> proposalFields = Util.getObjectCreatableFields('Proposal__c');
        
        String soql = 'SELECT ' + String.join(new List<String>(proposalFields), ',');
        
        soql += ', Opportunity__r.Account.Name, Opportunity__r.Account.ShippingStreet, Opportunity__r.Account.ShippingCity, ' +
            'Opportunity__r.Account.ShippingState, Opportunity__r.Account.ShippingPostalCode';
        
        // FROM Clause
        soql += ' FROM Proposal__c ';
        // WHERE Clause
        soql += ' WHERE Id = \'' + recordId + '\'';
        
        system.debug('Proposal soql: ' + soql);
        
        Proposal__c proposal = (Proposal__c)Database.query(soql);
        system.debug('Proposal: ' + proposal);
        return proposal;
    }
    
    @AuraEnabled
    public static void deleteProposal(String recordId)
    {
        Proposal__c proposalToDelete = [SELECT Id FROM Proposal__c WHERE Id =: recordId];
        
        delete proposalToDelete;
    }
    
    @AuraEnabled
    public static Proposal__c updateProposal(Proposal__c proposal)
    {
        update proposal;
        
        return proposal;
    }
    
    @AuraEnabled
    public static Account retrieveAccount(String accountId)
    {
        Account a = [SELECT ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Industry 
                     FROM Account
                     WHERE Id =: accountId];
        
        return a;
    }
    
    @AuraEnabled
    public static Account updateAccount(Account acct)
    {
        update acct;
        return acct;
    }
    
    @AuraEnabled
    public static User retrieveUser()
    {
        User u = [SELECT Street, City, State, PostalCode
                 FROM User
                 WHERE Id =: UserInfo.getUserId()];
        
        return u;
    }
    
    @AuraEnabled
    public static User updateUser(User usr)
    {
        update usr;
        return usr;
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> retrieveOpportunityProducts(string opportunityId)
    {
        List<OpportunityLineItem> oppProducts = [SELECT Id, Quantity, Product2.Name 
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId =: opportunityId];
        
        return oppProducts;
    }
    
    public class RecordTypeObject implements Comparable{
        @AuraEnabled
        public String RecordTypeId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Label;
        @AuraEnabled
        public String ScoredName;
        public Integer sortOrder;
        
        public RecordTypeObject(String rTypeId, String name, String label, Integer sortOrder)
        {
            this.RecordTypeId = rTypeId;
            this.Name = name;
            this.ScoredName = name.replace(' ', '_');
            this.Label = label;
            this.sortOrder = sortOrder;
        }
        
        public Integer compareTo(object objToCompare)
        {
            RecordTypeObject compareTo = (RecordTypeObject) objToCompare;
            integer returnValue = 0;
            
            if(sortOrder > compareTo.sortOrder)
                returnValue = 1;
            else if(sortOrder < compareTo.sortOrder)
                returnValue = -1;
            
            return returnValue;
        }
    }
    
}