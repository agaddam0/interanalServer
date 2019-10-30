/*********************************************************************************************
// Version:             1.0
// Author:              Etherios
// Date Created:        1/13/2015
// Description:         OpportunityBLogic Apex class for customization on triggers from the 
//                      Opportunity object
//   
// Copyright 2015 Etherios. All rights reserved. Customer confidential. Do not distribute.
//
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
// 1/13/2015         Brian Knowlton                                  See Class header notes
//
// *********************************************************************************************
// ********************************************************************************************/


/***********************************************************************************************
* Class Header Notes
* Apex class on the modification of fields on the Opportunity object coming from the standardOpportunity Trigger
** Updates the Decision Maker Field to either true or false depending on if an OCR is a decision maker.
* 
** Clones existing opportunity and assigns enrollment recordtype if new grou recordtype isClosed & isWon
* 
* 
*
***********************************************************************************************/
public without sharing class opportunityBLogic {
    
    private static final String enrollmentOppStageName = 'Proposal';    
    
    public static void setDateFields(list<Opportunity> newOpp) {
        for (Opportunity o : newOpp) {
            if (o.RecordTypeId == Constants.OPPORTUNITY_AWD_ENROLLMENT || o.RecordTypeId == Constants.OPPORTUNITY_AFES_ENROLLMENT) {
                system.debug('### inside of if');
                if (o.Administrative_Contact__c != null) {
                    system.debug('### has admin contact');
                    system.debug('### o.Date_Admin_Contact_Created__c = ' + o.Date_Admin_Contact_Created__c);
                    if (o.Date_Admin_Contact_Created__c == null) o.Date_Admin_Contact_Created__c = date.today();
                    system.debug('### oo.Date_Admin_Contact_Created__c = ' + o.Date_Admin_Contact_Created__c);
                } else o.Date_Admin_Contact_Created__c = null;
                
                if (o.Assigned_Account_Manager__c != null && o.Group_Name__c != null && (( o.Legal_Name_is_different_than_Group_Name__c == true
                //if (o.Group_Name__c != null && (( o.Legal_Name_is_different_than_Group_Name__c == true 
                    && o.Legal_Name__c != null) || !o.Legal_Name_is_different_than_Group_Name__c))
                    {
                        if ( o.Date_General_Setup_Questions_Completed__c == null) 
                            o.Date_General_Setup_Questions_Completed__c = date.today();
                } else o.Date_General_Setup_Questions_Completed__c = null;
            }
        }
    }
    
    /******************************************************************************************
     * Method Name:     createMasterEnrollmentFormRecord
     * Parameters:      list Opportunity 
     * Return type:     void
     * Description:     when Enrollment Opp is inserted, this reviews the form rules and creates master enrollment forms 
     *                  and records when necessary
     *                   
     * Notes:           
     *                  
     ******************************************************************************************/   
    public static Map<Id, Id> createMasterEnrollmentFormRecord(List<Opportunity> triggerNew)
    {
        List<Enrollment_Form__c> efListToInsert = new List<Enrollment_Form__c>();
        Map<Id, Id> opptyMasterEnrollmentFormMap = new Map<Id, Id>();
        
        for(Opportunity o : triggerNew)
        {
            efListToInsert.add( opportunityFormManagement.createEnrollmentForm(o) );
        }   
        
        //inserts one 'master' enrollment form per opportunity
        if (efListToInsert.size() > 0)
        {    
            try{
                System.debug('TRYING TO CREATE MASTER ENROLLMENT FORM(S)' + efListToInsert.size());
                insert efListToInsert;
            }catch(Exception eX){
                System.debug(LoggingLevel.DEBUG, 'Unable to create Enrollment forms from new Enrollment Opportunity -- ' +
                                            eX.getLineNumber() + '\t' + eX.getMessage() );
            }
            
            //return efListToInsert;
            
            for (Enrollment_Form__c ef : efListToInsert)
            {
                opptyMasterEnrollmentFormMap.put(ef.Enrollment_Opportunity__c, ef.Id);
            }
            
            return opptyMasterEnrollmentFormMap;
            
        } else return null;                                   
        //OpportunityFormRuleCheck.checkRulesOnInsert(tempList);
        //System.debug('*** END ***');                  
    }    
    
    /******************************************************************************************
     * Method Name:     enrollmentOpptyFormHandler
     * Parameters:      Opportunity List 
     * Return type:     none
     * Description:     handles Enrollment Form Creation on Enrollment Opprtunity Insert
     *              
     *                   
     * Notes:           
     *                  
     ******************************************************************************************/
    public static void enrollmentOpptyFormHandler(List<Opportunity> triggerNew)
    {
        System.debug('### Insert Form Handler');
        
        List<Opportunity> opps = new List<Opportunity>();
        Map<Id, Id> opptyMasterEnrollmentFormMap = new Map<Id, Id>();
        
        // Only operate on Enrollment Opportunities (record type = AWD_Enrollment or AFES_Enrollment)
        for (Opportunity o : triggerNew)
        {
            if(o.RecordTypeId == Constants.OPPORTUNITY_AFES_ENROLLMENT || o.RecordTypeId == Constants.OPPORTUNITY_AWD_ENROLLMENT) 
                opps.add(o);
        }
        
        if (opps.size() > 0) 
        {
            // Need map of Enrollment Opportunites and their Master Enrollment Form child for form creation
            opptyMasterEnrollmentFormMap = createMasterEnrollmentFormRecord(opps);
            opportunityFormManagement.createEnrollmentForms(opps, opptyMasterEnrollmentFormMap);
        }
    }
    // Enrollment Oppty Update handler
    public static void enrollmentOpptyFormHandler(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap)
    {
        System.debug('### Update Form Handler');
        
        List<Opportunity> opps = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        //Map<Id, Id> opptyMasterEnrollmentFormMap = new Map<Id, Id>();
        
        // Only operate on Enrollment Opportunities (record type = AWD_Enrollment or AFES_Enrollment)
        for (Opportunity o : triggerNew)
        {
            if(o.RecordTypeId == Constants.OPPORTUNITY_AFES_ENROLLMENT || o.RecordTypeId == Constants.OPPORTUNITY_AWD_ENROLLMENT){
                oppIds.add(o.Id);
                opps.add(o);
            }
        }
        
        if (oppIds.size() > 0) 
        {
            // Need map of Enrollment Opportunites and their Master Enrollment Form child for form creation
            //opptyMasterEnrollmentFormMap = createMasterEnrollmentFormRecord(opps);
            opportunityFormManagement.createEnrollmentForms(oppIds, triggerOldMap);
            opportunityFormManagement.checkForDeletes(opps, triggerOldMap);
        }
    } 
    
    public static void SetAssignedAccountManagerToAccountOwner(List<Opportunity> newOpps)
    {
        List<Id> acctIds = new List<Id>();
        for(Opportunity o : newOpps)
        {
            acctIds.add(o.AccountId);
        }
        
        List<Account> accts = [SELECT Id, OwnerId FROM Account WHERE Id IN :acctIds];
        
        for(Opportunity o : newOpps)
        {
            for(Account a : accts)
            {
                if(o.AccountId == a.Id)
                {
                    if(o.Assigned_Account_Manager__c == null)
                        o.Assigned_Account_Manager__c = a.OwnerId;
                }
            }
        }
    }
    
    public static void CreateAccountAssets(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap)
    {
        List<Id> opportunityIds = new List<Id>();
        List<Id> acctIds = new List<Id>();
        List<Asset> assetsToInsert = new List<Asset>();
        
        for(Opportunity o : newOpps)
        {
            if((o.StageName == 'Closed Won' && oldOppsMap.get(o.Id).StageName != 'Closed Won') && o.RecordTypeId == Constants.OPPORTUNITY_AFAS)
            {
                opportunityIds.add(o.Id);
                acctIds.add(o.AccountId);
            }
        }
        
        if(opportunityIds.size() > 0)
        {
            List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
            oppProducts = [SELECT Id,
                                Name,
                                PricebookEntryId,
                                ProductCode,
                                Quantity,
                                ServiceDate,
                                Product2Id, 
                                Product2.Name,
                                Product2.Family__c,
                                OpportunityId,
                                Opportunity.Name,
                                Opportunity.AccountId
                           FROM OpportunityLineItem
                           WHERE OpportunityId IN: opportunityIds];
            
            List<Asset> AcctAssets = new List<Asset>();
            AcctAssets = [SELECT Id, Name, AccountId FROM Asset WHERE AccountId IN: acctIds];
            Set<String> lAssets;
            Map<Id, Set<String>> AccountIdToAssets = new Map<Id, Set<String>>();
            
            for(Integer i = 0; i < acctIds.size(); i++)
            {
                lAssets = new Set<String>();
                for(Asset aa : AcctAssets)
                {
                    if(acctIds[i] == aa.AccountId)
                    {
                       lAssets.add(aa.Name); 
                    }
                }
                AccountIdToAssets.put(acctIds[i], lAssets);
            }
            
            for(OpportunityLineItem oli : oppProducts)
            {
                if(!AccountIdToAssets.get(oli.Opportunity.AccountId).contains(oli.Product2.Name))
                {
                    Asset ass = new Asset();
                    ass.AccountId = oli.Opportunity.AccountId;
                    ass.Family__c = oli.Product2.Family__c;
                    ass.Name = oli.Product2.Name;
                    ass.Status = 'Active';
                    
                    //if(oli.Product2.Name == 'AF Benefit Market')
                    //  ass.RecordTypeId = Constants.ASSET_BENEFIT_MARKET;
                    //else
                    //
                    ass.RecordTypeId = Constants.ASSET_HCR_SERVICES;
                    
                    assetsToInsert.add(ass);
                }            
            }
        }
        
        if(assetsToInsert.size() > 0)
            insert assetsToInsert;      
    }
    
    public static void DeleteRelatedEnrollmentOpportunityRecords(List<Opportunity> deleteOpps)
    {
        List<Id> enrollOppIds = new List<Id>();
        for(Opportunity o : deleteOpps)
        {
            if(o.RecordTypeId == Constants.OPPORTUNITY_AFES_ENROLLMENT || o.RecordTypeId == Constants.OPPORTUNITY_AWD_ENROLLMENT)
            {
                enrollOppIds.add(o.Id);
            }
        }
        
        // If an opportunity being deleted is an Enrollment Opportunity, Delete all the records that relate to it
        
        List<sObject> deleteRecords = new List<sObject>();
        
        List<Enrollment_Form__c> eFormsToDelete = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c IN :enrollOppIds];
        
        if(eFormsToDelete.size() > 0)
        {
            // Now we need to delete all the setup forms related to these enrollment forms
            
            // Query Platforms
            for(Platform_Setup__c p : [SELECT Id FROM Platform_Setup__c WHERE Enrollment_Form__c IN: eFormsToDelete])
            {
                deleteRecords.add(p);
            }
             
            // Query Customer Forms
            for(Customer_Setup_Form__c cf : [SELECT Id FROM Customer_Setup_Form__c WHERE Enrollment_Form__c IN: eFormsToDelete])
            {
                deleteRecords.add(cf);
            }
            
            // Query Section 125 Forms
            for(Section_125_Setup_Form__c s125 : [SELECT Id FROM Section_125_Setup_Form__c WHERE Enrollment_Form__c IN: eFormsToDelete])
            {
                deleteRecords.add(s125);
            }
            
            // Query Plan Summary Forms
            for(Section_125_Plan_Summary__c pSum : [SELECT Id FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__c IN: eFormsToDelete])
            {
                deleteRecords.add(pSum);
            }
            // Query Pre-Enrollment Marketing Forms
            List<Id> PreEnrollmentFormIds = new List<Id>();
            for(Pre_Enrollment_Marketing_Form__c pemf : [SELECT Id FROM Pre_Enrollment_Marketing_Form__c WHERE Enrollment_Form__c IN: eFormsToDelete])
            {
                deleteRecords.add(pemf);
                PreEnrollmentFormIds.add(pemf.Id);
            }
            // Query Group Meetings from Pre-Enrollment Marketing Forms
            for(Group_Meeting__c gm : [SELECT Id FROM Group_Meeting__c WHERE Pre_Enrollment_Marketing_Form__c IN: PreEnrollmentFormIds])
            {
                deleteRecords.add(gm);
            }
            
            delete eFormsToDelete;
        }
        
        // Delete the ids to delete
        if(deleteRecords.size() > 0)
            delete deleteRecords;
    }
}