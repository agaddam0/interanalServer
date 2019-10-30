/*********************************************************************************************
// Version:             1.0
// Author:              Etherios
// Date Created:        1/29/2015
// Description:         opportunityFormManagement Apex class for handling creation of Enrollment Opportunity Forms
//   
// Copyright 2015 Etherios. All rights reserved. Customer confidential. Do not distribute.
//
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
// 1/29/2015         Adam Schultz & Brian Knowlton                                 See Class header notes
//
// *********************************************************************************************
// ********************************************************************************************/

/***********************************************************************************************
* Class Header Notes
** Apex class on the creation of forms and enrollment forms based on rules (form rules) from Enrollment 
*   Opportunity Record.
*
* 
***********************************************************************************************/
public without sharing class opportunityFormManagement{

    private static final Id enrollment_form_master_Id = [SELECT Id FROM RecordType WHERE sObjectType = 'Enrollment_Form__c' AND DeveloperName = 'Master' LIMIT 1].Id;
    private static Integer triggerCounter = 0;

    class opptyDeleteManager 
    {
        Boolean deletePlatformSetupForms = false;
        Boolean deleteCustomerSetupForms = false;
        Boolean deleteSection125SetupForms = false;
        Boolean delete125PlanSummaryForms = false;
        Boolean deleteSubscriptionAgreementForms = false;
        Boolean deleteServiceExchangeAgreementForms = false;
            
        Opportunity o = new Opportunity();
            
    }  
    // Handle creation of new forms upon Enrollment Opportunity Insert
    public static void createEnrollmentForms(List<Opportunity> newOpps, Map<Id, Id> opptyMasterEnrollmentFormMap) 
    {
        System.debug('### Create Enrollment Forms Method');
        
        List<sObject> newForms = new List<sObject>();
        
        for (Opportunity o : getOpptiesAndChildrenRecords(opptyMasterEnrollmentFormMap.keySet())) 
        {
            // Check if the opportunity was cloned so we can clone applicable forms as well.
            if(o.isCloned__c)
            {
                if(o.Has_Platform_Setup_Form__c) newForms.add( clonePlatformForm(opptyMasterEnrollmentFormMap.get(o.Id), o.RecordType.Name,  o.OwnerId, 'Platform_Setup__c', o.Opportunity_Cloned_From__c) );
                if (o.Opportunity_Cloned_Source__c != null && o.Opportunity_Cloned_Source__r.Has_Preenrollment_Marketing_Form__c) {
                    SObject clonedPreenrollmentMarketingForm = clonePreenrollmentMarketingForm(opptyMasterEnrollmentFormMap.get(o.Id), o.OwnerId, o.Opportunity_Cloned_Source__c);

                    if (clonedPreenrollmentMarketingForm != null) {
                        newForms.add( clonedPreenrollmentMarketingForm );
                    }
                }
            }
            else
            {
                //Setup Forms        
                if(o.Has_Platform_Setup_Form__c) newForms.add( genForms(opptyMasterEnrollmentFormMap.get(o.Id), o.RecordType.Name,  o.OwnerId, 'Platform_Setup__c') );
            } 
            
            //These forms are not currently being cloned.  If they need to be cloned, move into else statement above
            if (o.Has_Section_125_setup_form__c) newForms.add( genForms(opptyMasterEnrollmentFormMap.get(o.Id), o.RecordType.Name,  o.OwnerId, 'Section_125_Setup_Form__c') );
            if (o.Has_Customer_Setup_form__c) newForms.add( genForms(opptyMasterEnrollmentFormMap.get(o.Id), o.RecordType.Name,  o.OwnerId, 'Customer_Setup_Form__c') );
            if (o.Has_Section_125_Plan_Summary_form__c) newForms.add( genForms(opptyMasterEnrollmentFormMap.get(o.Id), o.RecordType.Name,  o.OwnerId, 'Section_125_Plan_Summary__c') );
            
            //Signature Forms
            if (o.Has_Subscription_Agreement__c) newForms.add( genEnrollmentForm('Subscription Agreement', o.Id, o.OwnerId ));
            if (o.Has_Service_Exchange_Agreement__c) newForms.add( genEnrollmentForm('Service Exchange Agreement', o.Id, o.OwnerId));
        }

        if(!newForms.isEmpty()) 
        {
            System.debug('### Inserting new Forms: ' + newForms);
            insertNewForms(newForms);
        }
        else
            System.debug('### No forms to insert');
    }

    // Handle creation of new forms upon Enrollment Opportunity Update
    public static void createEnrollmentForms(Set<Id> oppIds, Map<Id, Opportunity> oldOppsMap) 
    {
        System.debug('### Create Enrollment Forms Method');
        
        List<sObject> newForms = new List<sObject>();
        //Need to get a handle on the master ef.id for code below
        for (Opportunity o : getOpptiesAndChildMaster(oppIds)) 
        {
            System.debug('### Opportunity: ' + o);
            System.debug('### Opportunity is cloned? ' + o.isCloned__c);
            System.debug('### o.Enrollment_Tasks__r.size(): ' + o.Enrollment_Tasks__r.size());
            System.debug('### o.Enrollment_Tasks__r: ' + o.Enrollment_Tasks__r);
            
            System.debug('$$$ Field Test formManangement new opp.Has_Customer_Setup_form__c: ' + o.Has_Customer_Setup_form__c);
            System.debug('$$$ Field Test formManagement old opp.Has_Customer_Setup_form__c: ' + oldOppsMap.get(o.Id).Has_Customer_Setup_form__c);
            
            System.debug('AKC Field Test formManangement new opp.Has_Platform_Setup_Form__c: ' + o.Has_Platform_Setup_Form__c);
            System.debug('AKC Field Test formManagement old opp.Has_Platform_Setup_Form__c: ' + oldOppsMap.get(o.Id).Has_Platform_Setup_Form__c);
            System.debug('AKC Field Test formManagement new opp.Has_Service_Exchange_Agreement__c: ' + o.Has_Service_Exchange_Agreement__c);
            System.debug('AKC Field Test formManagement old opp.Has_Service_Exchange_Agreement__c: ' + oldOppsMap.get(o.Id).Has_Service_Exchange_Agreement__c);
            System.debug('LF Field Test formManagement new opp.Has_Service_Exchange_Agreement__c: ' + o.Has_Service_Exchange_Agreement__c);
            
            //Setup Forms
            if (o.Enrollment_Tasks__r.size() > 0){
                if(o.isCloned__c)
                {
                    if (o.Has_Platform_Setup_Form__c && !oldOppsMap.get(o.Id).Has_Platform_Setup_Form__c) newForms.add( clonePlatformForm(o.Enrollment_Tasks__r[0].Id, o.RecordType.Name,  o.OwnerId, 'Platform_Setup__c', o.Opportunity_Cloned_From__c) );
                }
                else
                {
                    if (o.Has_Platform_Setup_Form__c && !oldOppsMap.get(o.Id).Has_Platform_Setup_Form__c) newForms.add( genForms(o.Enrollment_Tasks__r[0].Id, o.RecordType.Name, o.OwnerId, 'Platform_Setup__c') );                    
                }
                //These forms are not currently being cloned.  If they need to be cloned, move into else statement above
                if (o.Has_Section_125_setup_form__c && !oldOppsMap.get(o.Id).Has_Section_125_setup_form__c) newForms.add( genForms(o.Enrollment_Tasks__r[0].Id, o.RecordType.Name,  o.OwnerId, 'Section_125_Setup_Form__c') );
                if (o.Has_Customer_Setup_form__c && !oldOppsMap.get(o.Id).Has_Customer_Setup_form__c) newForms.add( genForms(o.Enrollment_Tasks__r[0].Id, o.RecordType.Name,  o.OwnerId, 'Customer_Setup_Form__c') );
                if (o.Has_Section_125_Plan_Summary_form__c && !oldOppsMap.get(o.Id).Has_Section_125_Plan_Summary_form__c) newForms.add( genForms(o.Enrollment_Tasks__r[0].Id, o.RecordType.Name,  o.OwnerId, 'Section_125_Plan_Summary__c') );
                
            }
            
            //Signature Forms
            if (o.Has_Subscription_Agreement__c && !oldOppsMap.get(o.Id).Has_Subscription_Agreement__c) newForms.add( genEnrollmentForm('Subscription Agreement', o.Id, o.OwnerId ));
            if (o.Has_Service_Exchange_Agreement__c && !oldOppsMap.get(o.Id).Has_Service_Exchange_Agreement__c) newFOrms.add(genEnrollmentForm('Service Exchange Agreement', o.Id, o.OwnerId));
        
        }

        if(!newForms.isEmpty()) 
        {
            System.debug('### Inserting new Forms: ' + newForms);
            insertNewForms(newForms);
        }
        else
            System.debug('### No forms to insert');
    }
    
    // Insert forms  
    public static void insertNewForms (List<sObject> newForms) {
        System.debug('CREATE FORMS! ');
        try{
            if (triggerCounter <= 1)
                insert newForms;
                
            triggerCounter++;
        }catch(System.DmlException ex){
            System.debug('*** EXCEPTION BEGIN ***');
            System.debug('*** Unable to create Forms from checkRulesOnInsert ***' + ex.getDmlType(0));
            System.debug('*** More INFO *** ' + ex.getDmlMessage(0) );
            SYstem.debug('*** ' + ex.getDmlId(0) + ' *** ' + ex.getNumDml());
            System.debug('*** ' + ex.getDmlFieldNames(0) + ' *** ' + ex.getDmlFields(0) + ' *** ');
            System.debug('*** Exception END ***');
        }   
    }
  
   public static List<Opportunity> getOpptiesAndChildrenRecords (Set<Id> opptyIds)
   {
        List<Opportunity> opps = [SELECT Id, RecordType.Name, RecordTypeId, OwnerId,
                                Has_Subscription_Agreement__c,
                                Has_Section_125_setup_form__c,
                                Has_Private_Exchange_form__c,
                                Has_Customer_Setup_form__c,
                                Has_Platform_Setup_Form__c,
                                Has_Section_125_Plan_Summary_form__c,
                                Has_Service_Exchange_Agreement__c,
                                Has_Preenrollment_Marketing_Form__c,
                                isCloned__c,
                                Opportunity_Cloned_From__c,
                                Opportunity_Cloned_Source__c,
                                Opportunity_Cloned_Source__r.Has_Preenrollment_Marketing_Form__c,
                                (SELECT Id, RecordType.Name, RecordTypeId FROM Enrollment_Tasks__r WHERE RecordTypeId != :enrollment_form_master_Id)

                                FROM Opportunity WHERE Id IN : opptyIds];                   
        return opps;
   }
   
   public static List<Opportunity> getOpptiesAndChildMaster (Set<Id> opptyIds)
   {
        List<Opportunity> opps = [SELECT Id, RecordType.Name, RecordTypeId, OwnerId,
                                Has_Subscription_Agreement__c,
                                Has_Section_125_setup_form__c,
                                Has_Private_Exchange_form__c,
                                Has_Customer_Setup_form__c,
                                Has_Platform_Setup_Form__c,
                                Has_Section_125_Plan_Summary_form__c,
                                Has_Service_Exchange_Agreement__c,
                                isCloned__c,
                                Opportunity_Cloned_From__c,
                                Opportunity_Cloned_Source__c,
                                Opportunity_Cloned_Source__r.Has_Preenrollment_Marketing_Form__c,
                                Has_Preenrollment_Marketing_Form__c,
                                (SELECT Id, RecordType.Name, RecordTypeId FROM Enrollment_Tasks__r WHERE RecordTypeId = :enrollment_form_master_Id)

                                FROM Opportunity WHERE Id IN : opptyIds];                   
        return opps;
   }
   
     
    /******************************************************************************************
     * Method Name:     genForms
     * Parameters:      Enrollment Form (master form), String (developer Name either awd or afes), String (sObject form to be created) 
     * Return type:     sObject (type of form object e.g. Section_125, customer_setup)
     * Description:     Generates forms (section 125, etc.) and links master enrollment form as parent 
     *              
     *                   
     * Notes:           
     *                  
     ******************************************************************************************/
    public static sOBject genForms(Id efId, String name, Id ownerId, String t)
    {
        System.debug('### genForms Method. Params:' + efId + ', ' + name + ', ' + ownerId + ', ' + t);
        String recordTypeName = '';
        if(name.substring(0,3) == 'AWD')
            recordTypeName = 'AWD Form';
        else
            recordTypeName = 'AFES Form';
        
        Id rTypeId = Schema.getGlobalDescribe().get(t).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        sObject sObj = Schema.getGlobalDescribe().get(t).newSObject(); 
        sObj.put('RecordTypeId', rTypeId);
        sObj.put('Enrollment_Form__c', efId);
        sObj.put('OwnerId', OwnerId);
        
        return sObj;
    }
    
    /******************************************************************************************
     * Method Name:     genEnrollmentForm
     * Parameters:      String recordTypeName, Enrollment_Form__c  
     * Return type:     sObject (type of form object e.g. Section_125, customer_setup)
     * Description:     Generates Enrollment_Form__c based on recordtype name given 
     *              
     *                   
     * Notes:           
     *                  
     ******************************************************************************************/
    public static sObject genEnrollmentForm(String recTypeName, Id opptyId, Id ownerId )
    {
        Id rTypeId = Schema.SObjectType.Enrollment_Form__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        
        Enrollment_Form__c newEF = new Enrollment_Form__c();
        newEf.recordTypeId = rTypeId;
        newEf.Enrollment_Opportunity__c = opptyId;
        newEf.OwnerId = OwnerId;
        if(recTypeName != 'Master')
            newEf.Auto_Generated__c = true;
        else
            newEf.Lightning_Form__c = true;
        
        return newEf;
    }
    
    /******************************************************************************************
     * Method Name:     createEnrollmentForm
     * Parameters:      Opportunity object 
     * Return type:     Enrollment_Form__c
     * Description:     creates Master record type enrollment form 
     *              
     *                   
     * Notes:           
     *                  
     ******************************************************************************************/
    public static Enrollment_Form__c createEnrollmentForm(Opportunity opp)
    {
        Enrollment_Form__c ef = new Enrollment_Form__c();
        ef.Enrollment_Opportunity__c = opp.Id;
        ef.RecordTypeId = enrollment_form_master_Id;
        ef.OwnerId = opp.OwnerId;
        ef.Lightning_Form__c = true;
        
        System.debug('### opp owner Id: ' + opp.OwnerId);
        System.debug('### ef owner Id: ' + ef.OwnerId);
        
        return ef;
    }   
    
    public static void checkForDeletes(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap)
    {
        System.debug('### Check For Deletes Method');
        
        Boolean deletePlatformSetupForms = false;
        Boolean deleteCustomerSetupForms = false;
        Boolean deleteSection125SetupForms = false;
        Boolean delete125PlanSummaryForms = false;
        Boolean deleteSubscriptionAgreementForms = false;
        Boolean deleteServiceExchangeAgreementForms = false;
        
        List<opptyDeleteManager> odms = new List<opptyDeleteManager>();
        
        for (Opportunity o : newOpps)
        {
            opptyDeleteManager odm = new opptyDeleteManager();
            odm.o = o;
            
            if (!o.Has_Section_125_setup_form__c && oldOppsMap.get(o.Id).Has_Section_125_setup_form__c) odm.deleteSection125SetupForms = true;
            if (!o.Has_Customer_Setup_form__c && oldOppsMap.get(o.Id).Has_Customer_Setup_form__c) odm.deleteCustomerSetupForms = true;
            if (!o.Has_Section_125_Plan_Summary_form__c && oldOppsMap.get(o.Id).Has_Section_125_Plan_Summary_form__c) odm.delete125PlanSummaryForms = true;
            if (!o.Has_Platform_Setup_Form__c && oldOppsMap.get(o.Id).Has_Platform_Setup_Form__c) odm.deletePlatformSetupForms = true;
            
            if (!o.Has_Subscription_Agreement__c && oldOppsMap.get(o.Id).Has_Subscription_Agreement__c) odm.deleteSubscriptionAgreementForms = true;
            if (!o.Has_Service_Exchange_Agreement__c && oldOppsMap.get(o.Id).Has_Service_Exchange_Agreement__c) odm.deleteServiceExchangeAgreementForms = true;
            
            System.debug('### ODM: ' + odm);
                        
            odms.add(odm);
        }
        
        List<Id> PlatformOppIds = new List<Id>();
        List<Id> Sect125OppIds = new List<Id>();
        List<Id> CustomerOppIds = new List<Id>();
        List<Id> PlanOppIds = new List<Id>();
        
        List<Id> SubscriptionOppIds = new List<Id>();
        List<Id> SEAoppIds = new List<Id>();
        
        
        for (opptyDeleteManager odm: odms)
        {
            if (odm.deletePlatformSetupForms == true)
                PlatformOppIds.add(odm.o.Id);
            if (odm.deleteSection125SetupForms == true)
                Sect125oppIds.add(odm.o.Id);
            if (odm.deleteCustomerSetupForms == true)
                CustomerOppIds.add(odm.o.Id);
            if (odm.delete125PlanSummaryForms == true)
                PlanOppIds.add(odm.o.Id);
            
            if (odm.deleteSubscriptionAgreementForms == true)
                SubscriptionOppIds.add(odm.o.Id);
            if (odm.deleteServiceExchangeAgreementForms == true)
                SEAoppIds.add(odm.o.Id);
        }
        
        System.debug('### PlatformOppIds: ' + PlatformOppIds);
        System.debug('### Sect125OppIds: ' + Sect125oppIds);
        System.debug('### CustomerOppIds: ' + CustomerOppIds);
        System.debug('### PlanOppIds: ' + PlanOppIds);
        System.debug('### SubscriptionOppIds: ' + SubscriptionOppIds);
        System.debug('### SEAoppIds: ' + SEAoppIds);
        
        if (PlatformOppIds.size() > 0)
        {
            List<Platform_Setup__c> PlatformSetupFormsToDelete = [SELECT Id FROM Platform_Setup__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c IN: PlatformOppIds];
            system.debug('### PlatformSetupFormsToDelete: ' + PlatformSetupFormsToDelete);
            delete PlatformSetupFormsToDelete;
        }
        if (Sect125OppIds.size() > 0){
            List<Section_125_Setup_Form__c> Section125SetupFormsToDelete = [SELECT Id FROM Section_125_Setup_Form__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c in: Sect125OppIds];
            System.debug('### Section125SetupFormsToDelete: ' + Section125SetupFormsToDelete);
            delete Section125SetupFormsToDelete;
        }
        if (CustomerOppIds.size() > 0){
            List<Customer_Setup_Form__c> CustomerSetupFormsToDelete = [SELECT Id FROM Customer_Setup_Form__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c in: CustomerOppIds];
            System.debug('### CustomerSetupFormsToDelete: ' + CustomerSetupFormsToDelete);
            delete CustomerSetupFormsToDelete;
        }
        if (PlanOppIds.size() > 0){
            List<Section_125_Plan_Summary__c> Section125PlanSummariesToDelete = [SELECT Id FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c in: PlanOppIds];
            System.debug('### Section125PlanSummariesToDelete: ' + Section125PlanSummariesToDelete);
            delete Section125PlanSummariesToDelete;
        }
        if (SubscriptionOppIds.size() > 0){
            List<Enrollment_Form__c> SubscriptionFormsToDelete = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c in: SubscriptionOppIds
                                                                                                AND RecordType.DeveloperName = 'Subscription_Agreement' 
                                                                                                AND Auto_Generated__c = true];
            System.debug('### SubscriptionFormsToDelete: ' + SubscriptionFormsToDelete);
            delete SubscriptionFormsToDelete;
        }
        if (SEAoppIds.size() > 0) {
            List<Enrollment_Form__c> SEAFormsToDelete = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c in: SEAoppIds
                                                         AND RecordType.DeveloperName = 'Service_Exchange_Agreement' 
                                                         AND Auto_Generated__c = true];
            System.debug('### SEAFormsToDelete: ' + SEAFormsToDelete);
            delete SEAFormsToDelete;
        }
    }
    
    public static sObject clonePlatformForm(Id efId, String name, Id ownerId, String t, Id clonedFromOpp)
    {
        Schema.FieldSet enrollmentFieldsToCloneFieldSet = SObjectType.Platform_Setup__c.FieldSets.Enrollment_Fields_To_Clone;
        
        Set<String> fieldsToQuery = Util.getObjectCreatableFields('Platform_Setup__c');
        fieldsToQuery.addAll( Util.getFieldSetFields(enrollmentFieldsToCloneFieldSet) );

        String soql = Util.getCreatableFieldsAndFieldSetSOQL(t, 'Enrollment_Form__r.Enrollment_Opportunity__c =\'' + clonedFromOpp + '\'' +
                      '   AND (RecordTypeId =\'' + Constants.PLATFORM_SETUP_AFES_FORM + '\'' +
                      '   OR RecordTypeId = \'' + Constants.PLATFORM_SETUP_AWD_FORM + '\')', enrollmentFieldsToCloneFieldSet);

        
        List<Platform_Setup__c> originals = (List<Platform_Setup__c>)Database.query(soql);
        
        system.debug('   clonePlatformForm::originals ' + originals);
        
        if(originals.size() > 0)
        {
            Set<String> fieldsToClone = Util.getFieldSetFields(enrollmentFieldsToCloneFieldSet);
            
            Platform_Setup__c original = originals[0];
            Platform_Setup__c clone = new Platform_Setup__c();
            
            clone.Enrollment_Form__c                        = efId;
            clone.OwnerId                                   = ownerId;
            clone.Status__c                                 = 'In Progress';
            if(original.RecordTypeId == Constants.PLATFORM_SETUP_AFES_FORM) {
                clone.RecordTypeId = Constants.PLATFORM_SETUP_AFES_FORM;
            }
            else {
                clone.RecordTypeId = Constants.PLATFORM_SETUP_AWD_FORM;
            }
            
            for (String fieldToClone : fieldsToClone) {
                Object originalFieldValue = original.get(fieldToClone);
                clone.put(fieldToClone, originalFieldValue);
            }
            
            return clone; 
        }
        else
        {
            return genForms(efid, name, ownerId, t);
        }
    }
    
    public static sObject clonePreenrollmentMarketingForm(Id efId, Id ownerId, Id sourceOppId) {
        Schema.FieldSet enrollmentFieldsToCloneFieldSet = SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Enrollment_Fields_To_Clone;
        
        String soql = Util.getCreatableFieldsAndFieldSetSOQL('Pre_Enrollment_Marketing_Form__c', 'Enrollment_Form__r.Enrollment_Opportunity__c =\'' + sourceOppId + '\'', enrollmentFieldsToCloneFieldSet);
        
        List<Pre_Enrollment_Marketing_Form__c> originals = (List<Pre_Enrollment_Marketing_Form__c>)Database.query(soql);
        
        if (originals.isEmpty()) {
            return null;
        }
        
        Set<String> fieldsToClone = Util.getFieldSetFields(enrollmentFieldsToCloneFieldSet);
        
        Pre_Enrollment_Marketing_Form__c original = originals[0];
        Pre_Enrollment_Marketing_Form__c clone = new Pre_Enrollment_Marketing_Form__c();
        
        for (String fieldToClone : fieldsToClone) {
            Object originalFieldValue = original.get(fieldToClone);
            clone.put(fieldToClone, originalFieldValue);
        }
        
        clone.Enrollment_Form__c = efId;
        clone.OwnerId = ownerId;
        clone.Status__c = 'In Progress';
        
        return clone; 
    }
    
    public static void cloneCoreBenefits(List<Platform_Setup__c> insertedPlatformSetups) {
        List<Platform_Setup__c> platformSetupsToClone = getEligiblePlatformSetupsToClone(insertedPlatformSetups);
        
        system.debug('    cloneCoreBenefits::platformSetupsToClone ' + platformSetupsToClone);
        
        if (platformSetupsToClone.isEmpty()) {
            return;
        }
        
        Map<Id, List<Core_Benefit_Form__c>> coreBenefitsFormsBySourceOpportunity = getCoreBenefitsFormsBySourceOpportunity(platformSetupsToClone);
        List<Core_Benefit_Form__c> clonedCoreBenefitFormsToInsert = new List<Core_Benefit_Form__c>();
        
        system.debug('    cloneCoreBenefits::coreBenefitsFormsBySourceOpportunity ' + coreBenefitsFormsBySourceOpportunity);
        
        for (Platform_Setup__c platformSetupToClone : platformSetupsToClone) {
            Id sourceOppId = platformSetupToClone.Enrollment_Form__r.Enrollment_Opportunity__r.Opportunity_Cloned_Source__c;
            List<Core_Benefit_Form__c> coreBenefitsFormsToClone = coreBenefitsFormsBySourceOpportunity.get(sourceOppId);
            
            if (coreBenefitsFormsToClone == null) {
                continue;
            }
            
            for (Core_Benefit_Form__c coreBenefitFormToClone : coreBenefitsFormsToClone) {
                Core_Benefit_Form__c clonedCoreBenefitForm = coreBenefitFormToClone.clone(false, true);
                clonedCoreBenefitForm.Platform_Setup_Form__c = platformSetupToClone.Id;

                clonedCoreBenefitFormsToInsert.add(clonedCoreBenefitForm);
            }
        }
        
        system.debug('    cloneCoreBenefits::clonedCoreBenefitFormsToInsert ' + clonedCoreBenefitFormsToInsert);
        
        if (clonedCoreBenefitFormsToInsert.size() > 0) {
            insert clonedCoreBenefitFormsToInsert;
        }
    }
    
    private static List<Platform_Setup__c> getEligiblePlatformSetupsToClone(List<Platform_Setup__c> potentialPlatformSetupsToClone) {
        return
        [SELECT Id,
                Name,
                Enrollment_Form__c,
                Enrollment_Form__r.Enrollment_Opportunity__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Opportunity_Cloned_Source__c
           FROM Platform_Setup__c
          WHERE Id in :potentialPlatformSetupsToClone
            AND Enrollment_Form__r.Enrollment_Opportunity__r.IsCloned__c = true
            AND Enrollment_Form__r.Enrollment_Opportunity__r.Opportunity_Cloned_Source__c != null];
    }
    
    private static Map<Id, List<Core_Benefit_Form__c>> getCoreBenefitsFormsBySourceOpportunity(List<Platform_Setup__c> platformSetupsToClone) {
        Map<Id, List<Core_Benefit_Form__c>> coreBenefitsFormsBySourceOpportunity = new Map<Id, List<Core_Benefit_Form__c>>();
        
        Set<Id> sourceOpportunityIds = new Set<Id>();
        
        for (Platform_Setup__c platformSetupToClone : platformSetupsToClone) {
            sourceOpportunityIds.add(platformSetupToClone.Enrollment_Form__r.Enrollment_Opportunity__r.Opportunity_Cloned_Source__c);
        }
        
        system.debug('    getCoreBenefitsFormsBySourceOpportunity::sourceOpportunityIds ' + sourceOpportunityIds);
        
        List<Core_Benefit_Form__c> coreBenefitForms = getCoreBenefitFormsForCloningByOpportunities(sourceOpportunityIds);
        
        system.debug('    getCoreBenefitsFormsBySourceOpportunity::coreBenefitForms ' + coreBenefitForms);
        
        for (Core_Benefit_Form__c coreBenefitForm : coreBenefitForms) {
            Id sourceOppId = coreBenefitForm.Platform_Setup_Form__r.Enrollment_Form__r.Enrollment_Opportunity__c;
            
            List<Core_Benefit_Form__c> coreBenefitFormsBySourceOppId = coreBenefitsFormsBySourceOpportunity.get(sourceOppId);
            
            if (coreBenefitFormsBySourceOppId == null) {
                coreBenefitFormsBySourceOppId = new List<Core_Benefit_Form__c>();
                coreBenefitsFormsBySourceOpportunity.put(sourceOppId, coreBenefitFormsBySourceOppId);
            }
            
            coreBenefitFormsBySourceOppId.add(coreBenefitForm);
        }
        
        return coreBenefitsFormsBySourceOpportunity;
    }

    private static List<Core_Benefit_Form__c> getCoreBenefitFormsForCloningByOpportunities(Set<Id> opportunityIds) {
        Schema.FieldSet coreBenefitsEnrollmentFieldsToCloneFieldSet = SObjectType.Core_Benefit_Form__c.FieldSets.Enrollment_Fields_To_Clone;
        Set<String> coreBenefitFieldsToQuery = Util.getFieldSetFields(coreBenefitsEnrollmentFieldsToCloneFieldSet);
        coreBenefitFieldsToQuery.add('Platform_Setup_Form__r.Enrollment_Form__r.Enrollment_Opportunity__c');
        
        String soql = 'SELECT ' + String.Join(new List<String>(coreBenefitFieldsToQuery), ',') + ' ' +
                        ' FROM Core_Benefit_Form__c ' +
                       'WHERE Platform_Setup_Form__r.Enrollment_Form__r.Enrollment_Opportunity__c in :opportunityIds' +
                       '  AND Platform_Setup_Form__r.What_Core_Benefits_will_show_in_the_case__c = \'Detailed Core Benefits\'';

        return Database.query(soql);
    }
}