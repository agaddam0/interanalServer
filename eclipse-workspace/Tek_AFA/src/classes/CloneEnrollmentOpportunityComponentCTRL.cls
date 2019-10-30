public class CloneEnrollmentOpportunityComponentCTRL {
    
    public static Id OpportunityId			{get;set;}
    public static Id AccountId				{get;set;}
    public static Opportunity clonedOpp		{get;set;}
    public static Opportunity original		{get;set;}
    public static Account act				{get;set;}

    @AuraEnabled
    public static CloneEnrollmentContext getInitialCloneEnrollmentOpportunityContext(Id recordId) {
        CloneEnrollmentContext context = new CloneEnrollmentContext();
        
        // clone opportunity first so Account or Opportunity Id are populated.
        context.ClonedOpportunity = cloneOpportunity(recordId);
        context.OpenEnrollmentOpportunities = getOpenEnrollmentOpportunitiesInLast6Months();

        return context;
    }

    @AuraEnabled
    public static Opportunity cloneOpportunity(Id recordId)
    {
        String sObjectName = recordId.getSobjectType().getDescribe().getName();
        if(sObjectName.equalsIgnoreCase('Opportunity'))
        {
            OpportunityId = recordId;
        }
        else if(sObjectName.equalsIgnoreCase('Account'))
        {
            // This is a cloned opportunity that is coming from the related list buttons on the account passing in the Account Id
            // We want to query for the latest opportunity according to the Enrollment Start Date and clone it
            // by setting the variable OpportunityId
            
            AccountId = recordId;
            
            // Grab the latest enrollment opportunity to clone
            List<Opportunity> op = [SELECT Id 
                              FROM Opportunity 
                              WHERE Account.Id =: AccountId 
                              AND (RecordTypeId =: Constants.OPPORTUNITY_AWD_ENROLLMENT OR RecordTypeId =: Constants.OPPORTUNITY_AFES_ENROLLMENT)
                              Order By Enrollment_Start_Date__c DESC LIMIT 1];
            if(op.size() > 0)
                OpportunityId = op[0].Id;
            
            if(act == null)
                act = [SELEcT Id, Plan_Date__c, Division__c FROM Account WHERE Id =: AccountId];
        }
        
        // Clone Opportunity Logic
        if(OpportunityId != null)
        {
            clonedOpp = cloneOpportunity();
        }
        // This is a new opportunity not coming from the specified buttons
        else
        {
            clonedOpp = CreateNewOpportunity();
        }
        
        return clonedOpp;
    }
    
    @AuraEnabled
    public static Opportunity insertClonedOpportunity(Opportunity opp, String originalOppId)
    {
        system.debug(opp);
        insert opp;
        
        OpportunityId = originalOppId;
        clonedOpp = opp;
        
        cloneMarketedProducts();
        cloneOpportunityTeam();
        
        return opp;
    }
    
    private static Opportunity cloneOpportunity() {
        Set<String> fieldsToQuery = Util.getObjectCreatableFields('Opportunity');
        Set<String> enrollmentFieldsToClone = Util.getFieldSetFields(SObjectType.Opportunity.FieldSets.Enrollment_Fields_To_Clone);
        
        fieldsToQuery.addAll(enrollmentFieldsToClone);
        
        String soql = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ',') + ',RecordType.Name FROM Opportunity WHERE Id=\'' + OpportunityId + '\'';
            
        if(original == null || original.Id != OpportunityId) {
            original = (Opportunity)Database.query(soql);
        }
        
        if(act == null) {
            act = [SELECT Id, Plan_Date__c, Annualized_Premium__c FROM Account WHERE Id =: original.AccountId];
        }
            
        Opportunity clonedOpportunity = new Opportunity();
        
        clonedOpportunity.Name = 'Cloned Opportunity';
        clonedOpportunity.OwnerId = UserInfo.getUserId();
        clonedOpportunity.StageName = 'Enrollment';
        clonedOpportunity.AccountId = act.Id;
        clonedOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        clonedOpportunity.CloseDate = system.today().addDays(30);
        clonedOpportunity.Platform__c = 'AFenroll';
        if(original.Division__c == 'AFES') {
            clonedOpportunity.RecordTypeId = Constants.OPPORTUNITY_AFES_ENROLLMENT;
        }
        else {
            clonedOpportunity.RecordTypeId = Constants.OPPORTUNITY_AWD_ENROLLMENT;
        }
        
        for (String enrollmentFieldToClone : enrollmentFieldsToClone) {
            Object originalFieldValue = original.get(enrollmentFieldToClone);
            clonedOpportunity.put(enrollmentFieldToClone, originalFieldValue);
        }
                    
        // Behind the scenes needs
        clonedOpportunity.isCloned__c = true;
        clonedOpportunity.Opportunity_Cloned_From__c = original.Id;
        clonedOpportunity.Opportunity_Cloned_Source__c = original.Id;
        
        // Account assignments
        clonedOpportunity.Plan_Date_New__c = act.Plan_Date__c;
        Decimal percentOfPremium = Decimal.valueOf(Label.Percent_of_Annual_Premium);
        clonedOpportunity.Enrollment_AP_Goal__c = act.Annualized_Premium__c * percentOfPremium;
        
        return clonedOpportunity;
    }    
    
    private static void cloneMarketedProducts()
    {
        if (OpportunityId == null) {
            return;
        }
        
        // Clone Marketed Products from the enrollment form
        Enrollment_Form__c[] originalForm = [SELECT ID FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: OpportunityId AND RecordType.Name = 'Master'];
        Enrollment_Form__c[] newForm = [SELECT ID FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: clonedOpp.Id AND RecordType.Name = 'Master'];
        
        if(originalForm.isEmpty() || newForm.isEmpty()) {
            return;
        }

        Id originalFormId = originalForm[0].Id;
        Id newFormId = newForm[0].Id;
        
        List<Marketed_Product__c> productsToInsert = new List<Marketed_Product__c>();
        string soql = Util.getCreatableFieldsAndFieldSetSOQL('Marketed_Product__c', 'Enrollment__c =\'' + originalFormId + '\'', SObjectType.Marketed_Product__c.FieldSets.Enrollment_Fields_To_Clone);
        List<Marketed_Product__c> mkProducts = (List<Marketed_Product__c>)Database.query(soql);
        
        system.debug('*** Products To Clone: ' + mkProducts);
        for(Marketed_Product__c mp : mkProducts)
        {
            Marketed_Product__c clonedProduct = mp.clone(false, true);
            clonedProduct.Enrollment__c = newFormId;
            clonedProduct.Plan_Status__c = 'Existing';
            productsToInsert.add(clonedProduct);
        }
        
        if(productsToInsert.size() > 0) {
            insert productsToInsert;
        }
    }
    
    private static void cloneOpportunityTeam()
    {
    	string soql = '';
    	List<OpportunityTeamMember> teamMembersToInsert = new List<OpportunityTeamMember>();
    	
    	if(OpportunityId != null)
    	{
    		soql = Util.getCreatableFieldsSOQL('OpportunityTeamMember', 'OpportunityId =\'' + OpportunityId + '\'');
    		List<OpportunityTeamMember> members = (List<OpportunityTeamMember>)Database.query(soql);
    		
    		system.debug('*** Team Members to clone: ' + members);
    		for(OpportunityTeamMember OTM : members)
    		{
    			OpportunityTeamMember clonedMember = OTM.clone(false, true);
    			teamMembersToInsert.add(clonedMember);
    		}
    		
    		if(teamMembersToInsert.size() > 0)
    			insert teamMembersToInsert;
    	}
    }
    
    private static Opportunity CreateNewOpportunity()
    {
        Opportunity o = new Opportunity();
        o.CloseDate = system.today().AddDays(30);
        o.Name = 'New Opportunity';
        o.Confirm_New_or_Existing_Group__c = 'Existing';
        o.AccountId = act.Id;
        o.Division__c = act.Division__c;
        o.StageName = 'Enrollment';
        o.Plan_Date_New__c = act.Plan_Date__c;
        o.Platform__c = 'AFenroll';
        o.OwnerId = UserInfo.getUserId();
        if(act.Division__c == 'AFES')
            o.RecordTypeId = Constants.OPPORTUNITY_AFES_ENROLLMENT;
        if(act.Division__c == 'AWD')
            o.RecordTypeId = Constants.OPPORTUNITY_AWD_ENROLLMENT;
        
        return o;
    }

    private static List<Opportunity> getOpenEnrollmentOpportunitiesInLast6Months() {
        if (AccountId == null) {
            Opportunity currentOpportunity =
            [SELECT AccountId
               FROM Opportunity
              WHERE Id = :OpportunityId];

            AccountId = currentOpportunity.AccountId;
        }

        return getAccountOpenEnrollmentsInLast6Months(AccountId);
    }

    private static List<Opportunity> getAccountOpenEnrollmentsInLast6Months(Id accountIdArg) {
        return
        [SELECT Id,
                Name,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                OwnerId,
                Owner.Name,
                CreatedDate
           FROM Opportunity 
          WHERE AccountId = :accountIdArg 
            AND (RecordTypeId =: Constants.OPPORTUNITY_AWD_ENROLLMENT OR RecordTypeId =: Constants.OPPORTUNITY_AFES_ENROLLMENT)
            AND CreatedDate >= LAST_N_MONTHS:6
            AND StageName = 'Enrollment'];
    }

    public class CloneEnrollmentContext {
        @AuraEnabled
        public Opportunity ClonedOpportunity { get; set; }

        @AuraEnabled
        public List<Opportunity> OpenEnrollmentOpportunities { get; set; }

        public CloneEnrollmentContext() {
            OpenEnrollmentOpportunities = new List<Opportunity>();
        }
    }
}