public class SetupFormManagement {
    // This class is to drive the creation or deletion of the SetupForms which are now mostly
    // created and removed based on the Marketed Products
    // 
    // This calss is to ventually need to erradicate the OpportunityFormManagement class as 
    // the forms are no longer solely driven off opportunity values

    // Created forms when a Marketed Product is inserted
    // NOTE:  Currently only managaing Signature Forms
    public static final String GROUP_HI_PRODUCT_NAME = 'Group Hospital Indemnity';
    
    public static List<Id> mpIds;
    public static List<Id> existingMPids;
    public static List<Marketed_Product__c> MarketedProducts;
    public static List<Id> efIds;
    public static Map<Id, Section_125_Setup_Form__c> mpTo125;
    public static Map<Id, Customer_Setup_Form__c> mpToCustomer;
    public static Map<Id, Opportunity> oppsToUpdate;
    
    public static void CreateFormsFromMarketedProductsAfterInsert(List<Marketed_Product__c> mProducts)
    {
        mpIds = new List<Id>();
        efIds = new List<Id>();
        existingMPids = new List<Id>();
        
        for(Marketed_Product__c mp : mProducts)
        { 
            mpIds.add(mp.Id);
            efIds.add(mp.Enrollment__c);
        }
        
        if(mpIds.size() > 0)
        {
            queryProductsForRelationships();
            determineFormsToCreate();
        }
    }
    
    public static void CreateFormsFromMarketedProductsAfterUpdate(List<Marketed_Product__c> mProducts, Map<Id, Marketed_Product__c> oldmProducts)
    {
        mpIds = new List<Id>();
        efIds = new List<Id>();
        
        for(Marketed_Product__c mp : mProducts)
        { 
            // only do work on produts that the plan status has changed
            if(mp.Plan_Status__c != oldmProducts.get(mp.Id).Plan_Status__c)
            {
                mpIds.add(mp.Id);
                efIds.add(mp.Enrollment__c);
            }
        }
        
        if(mpIds.size() > 0)
        {
            queryProductsForRelationships();
            determineFormsToCreate();
        }
    }
    
    public static void CreateFormsFromSection125AfterUpdate(List<Section_125_Setup_Form__c> newS125s, Map<Id, Section_125_Setup_Form__c> oldMapS125)
    {
        system.debug('JJJ After Update');
        efIds = new List<Id>();
        for(Section_125_Setup_Form__c s125 : newS125s)
        { 
            // only do work on forms that they key fields have changed on
            if(s125.FlexSpendAcctUniformCoverageRisk__c != oldMapS125.get(s125.Id).FlexSpendAcctUniformCoverageRisk__c
              || s125.FlexSpendAcctForAFESPremium__c != oldMapS125.get(s125.Id).FlexSpendAcctForAFESPremium__c)
            {
                efIds.add(s125.Enrollment_Form__c);
            }
        }
        
        if(efIds.size() > 0)
        {
            queryProductsForRelationships();
            determineFormsToCreate();
        }
    }
    
    public static void CreateFormsFromCustomerSetupAfterUpdate(List<Customer_setup_Form__c> newCustForms, Map<Id, Customer_setup_Form__c> oldMapCustForms)
    {
        efIds = new List<Id>();
        for(Customer_setup_Form__c c : newCustForms)
        { 
            // only do work on forms that they key fields have changed on
            if(c.GrpProdTrustOrDirect__c != oldMapCustForms.get(c.Id).GrpProdTrustOrDirect__c)
            {
                efIds.add(c.Enrollment_Form__c);
            }
        }
        
        if(efIds.size() > 0)
        {
            queryProductsForRelationships();
            determineFormsToCreate();
        }
        
    }
    
    public static void CreateFormsFromOpportunityAfterUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldMapOpps)
    {
        
    }
    
    public static void queryProductsForRelationships()
    {
        if(mpIds != null)
        {
            // This method is coming from an update or insert on Marketed Products
            MarketedProducts = [SELECT Plan_Status__c, 
                                Products__c, 
                                Products__r.Name,
                                Products__r.Product_Family__c,
                                Products__r.Chassis__c,
                                Enrollment__c, 
                                Enrollment__r.Enrollment_Opportunity__c,
                                Enrollment__r.Enrollment_Opportunity__r.Confirm_New_or_Existing_Group__c,
                                Enrollment__r.Enrollment_Opportunity__r.OwnerId,
                                Enrollment__r.Enrollment_Opportunity__r.Are_you_adding_new_plans_or_services__c,
                                Enrollment__r.Enrollment_Opportunity__r.Has_Customer_Setup_form__c,
                                Chassis__c
                                FROM Marketed_Product__c
                                WHERE Id in: mpIds];
        }
        else
        {
            // This one is coming from an update on a different object
            MarketedProducts = [SELECT Plan_Status__c, 
                                Products__c, 
                                Products__r.Name,
                                Products__r.Product_Family__c,
                                Products__r.Chassis__c,
                                Enrollment__c, 
                                Enrollment__r.Enrollment_Opportunity__c,
                                Enrollment__r.Enrollment_Opportunity__r.Confirm_New_or_Existing_Group__c,
                                Enrollment__r.Enrollment_Opportunity__r.OwnerId,
                                Enrollment__r.Enrollment_Opportunity__r.Has_Subscription_Agreement__c,
                                Enrollment__r.Enrollment_Opportunity__r.Are_you_adding_new_plans_or_services__c,
                                Enrollment__r.Enrollment_Opportunity__r.Has_Customer_Setup_form__c,
                                Chassis__c
                                FROM Marketed_Product__c
                                WHERE Enrollment__c in: efIds];
        }
        
        
        List<Section_125_Setup_Form__c> section125s = [SELECT FlexSpendAcctUniformCoverageRisk__c, FlexSpendAcctForAFESPremium__c, Enrollment_Form__c
                                                       FROM Section_125_Setup_Form__c
                                                       WHERE Enrollment_Form__c in: efIds];
        
        List<Customer_Setup_Form__c> customerForms = [SELECT GrpProdTrustOrDirect__c, Enrollment_Form__c
                                                     FROM Customer_Setup_Form__c
                                                     WHERE Enrollment_Form__c in: efIds];
        
        mpTo125 = new Map<Id, Section_125_Setup_Form__c>();
        mpToCustomer = new Map<Id, Customer_Setup_Form__c>();
        for(Marketed_Product__c mp : MarketedProducts)
        {
            for(Section_125_Setup_Form__c s : section125s)
            {
                if(s.Enrollment_Form__c == mp.Enrollment__c)
                {
                    mpTo125.put(mp.Id, s);
                }
            }
            for(Customer_Setup_Form__c c : customerForms)
            {
                if(c.Enrollment_Form__c == mp.Enrollment__c)
                {
                    mpToCustomer.put(mp.Id, c);
                }
            }
        }
    }
    
    public static void determineFormsToCreate()
    {
        oppsToUpdate = new Map<Id, Opportunity>();
        for(Marketed_Product__c mp : MarketedProducts)
        {
            system.debug('BBB');
            // If it has a value it should equal New or Existing
            if(mp.Enrollment__r.Enrollment_Opportunity__r.Confirm_New_or_Existing_Group__c != null)
            {
                if(mp.Enrollment__r.Enrollment_Opportunity__r.Confirm_New_or_Existing_Group__c == 'New')
                {
                    system.debug('New Group');
                    if(mp.Products__r.Name.equalsIgnoreCase('Section 125'))
                    {
                        if(mp.Plan_Status__c.equalsIgnoreCase('new'))
                        {
                            system.debug('New Section 125');
                            // create Service Exchange Agreement
                            mp.Enrollment__r.Enrollment_Opportunity__r.Has_Service_Exchange_Agreement__c = true;
                            oppsToUpdate.put(mp.Enrollment__r.Enrollment_Opportunity__c, mp.Enrollment__r.Enrollment_Opportunity__r);
                        }
                        else
                        {
                            system.debug('Existing Section 125');
                            // create Service Exchange Agreement
                            mp.Enrollment__r.Enrollment_Opportunity__r.Has_Service_Exchange_Agreement__c = false;
                            oppsToUpdate.put(mp.Enrollment__r.Enrollment_Opportunity__c, mp.Enrollment__r.Enrollment_Opportunity__r);
                        }
                    }
                    
                    if(mp.Products__r.Name.equalsIgnoreCase('Long-Term Disability') || mp.Products__r.Name.equalsIgnoreCase('Short-Term Disability')
                      && mp.Plan_Status__c.equalsIgnoreCase('new'))
                    {
                        system.debug('Disability');
                       if(mpToCustomer.get(mp.Id) != null &&
                          mpToCustomer.get(mp.Id).GrpProdTrustOrDirect__c == 'Trust')
                       {
                           // create Subscription Agreement
                           mp.Enrollment__r.Enrollment_Opportunity__r.Has_Subscription_Agreement__c = true;
                           oppsToUpdate.put(mp.Enrollment__r.Enrollment_Opportunity__c, mp.Enrollment__r.Enrollment_Opportunity__r);
                       }
                    }
                }
                // existing group
                else
                {
                    system.debug('FFF Remove All');
                    mp.Enrollment__r.Enrollment_Opportunity__r.Has_Subscription_Agreement__c = false;
                    mp.Enrollment__r.Enrollment_Opportunity__r.Has_Service_Exchange_Agreement__c = false;

                    oppsToUpdate.put(mp.Enrollment__r.Enrollment_Opportunity__c, mp.Enrollment__r.Enrollment_Opportunity__r);
                }
            }
        }
        
        if(oppsToUpdate.size() > 0)
        {
            update oppsToUpdate.values();
        }
    }
    
    public static void SetGroupHIAddingFromMarketedProductsAfterUpdate(Map<Id, Marketed_Product__c> oldMarketedProducts, Map<Id, Marketed_Product__c> newMarketedProducts) {
        Set<Id> enrollmentFormsWithNewGroupHI = new Set<Id>();
        Set<Id> enrollmentFormsWithoutNewGroupHI = new Set<Id>();
        
        for (Marketed_Product__c newMP : newMarketedProducts.values()) {
            if (newMP.Name != GROUP_HI_PRODUCT_NAME) {
                continue;
            }

            Marketed_Product__c oldMP = oldMarketedProducts.get(newMP.Id);

            if (oldMP.Plan_Status__c != newMP.Plan_Status__c &&
                newMP.Plan_Status__c == 'New') {
                enrollmentFormsWithNewGroupHI.add(newMP.Enrollment__c);
            }
            
            // The name is updated to the product catalog name declaratively so see if a new
            // MP is a New Group HI.
            if (oldMP.Name != newMP.Name &&
                newMP.Plan_Status__c == 'New') {
                enrollmentFormsWithNewGroupHI.add(newMP.Enrollment__c);
            }

            if (oldMP.Plan_Status__c != newMP.Plan_Status__c &&
                newMP.Plan_Status__c == 'Existing') {
                enrollmentFormsWithoutNewGroupHI.add(newMP.Enrollment__c);
            }
        }

        if (enrollmentFormsWithNewGroupHI.isEmpty() == false) {
            setGroupHIAddingToValueONCustomerSetupForms(enrollmentFormsWithNewGroupHI, 'Yes');
        }

        if (enrollmentFormsWithoutNewGroupHI.isEmpty() == false) {
            setGroupHIAddingToValueONCustomerSetupForms(enrollmentFormsWithoutNewGroupHI, 'No');
        }
    }

    public static void SetGroupHIAddingFromMarketedProductsBeforeDelete(List<Marketed_Product__c> deletedMarketedProducts) {
        Set<Id> enrollmentFormsWithoutGroupHI = new Set<Id>();
        
        List<Marketed_Product__c> deletedQueriedMPs =
        [SELECT Id,
                Name,
                Enrollment__c
           FROM Marketed_Product__c
          WHERE Id in :deletedMarketedProducts];
        
        for (Marketed_Product__c deletedMP : deletedQueriedMPs) {
            if (deletedMP.Name == GROUP_HI_PRODUCT_NAME) {
                enrollmentFormsWithoutGroupHI.add(deletedMP.Enrollment__c);
            }
        }
        
        if (enrollmentFormsWithoutGroupHI.isEmpty() == false) {
            setGroupHIAddingToValueONCustomerSetupForms(enrollmentFormsWithoutGroupHI, 'No');
        }
    }
    
    private static void setGroupHIAddingToValueONCustomerSetupForms(Set<Id> enrollmentFormIds, String addingGroupHIVal) {
        List<Customer_Setup_Form__c> customerSetupForms = getCustomerSetupFormsByEnrollmentFormIds(enrollmentFormIds);
        
        for (Customer_Setup_Form__c csf : customerSetupForms) {
            csf.GrpHospitalIndemnity__c = addingGroupHIVal;
        }

        if (customerSetupForms.isEmpty() == false) {
            update customerSetupForms;
        }
    }
    
    private static List<Customer_Setup_Form__c> getCustomerSetupFormsByEnrollmentFormIds(Set<Id> enrollmentFormIds) {
        return
        [SELECT Id,
                Name,
                GrpHospitalIndemnity__c
           FROM Customer_Setup_Form__c
          WHERE Enrollment_Form__c in :enrollmentFormIds];
    }
}