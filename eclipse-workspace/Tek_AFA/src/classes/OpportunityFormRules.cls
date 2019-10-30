/*********************************************************************************************
// Version:             1.0
// Author:              Etherios
// Date Created:        2/10/2015
// Description:         OpportunityFormRule Apex class for customization on form Rules from 
//                      OpportunityBLogic class
//   
// Copyright 2015 Etherios. All rights reserved. Customer confidential. Do not distribute.
//
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
// 2/10/2015        Adam Schultz                                  See Class header notes
//
// *********************************************************************************************
// ********************************************************************************************/

/***********************************************************************************************
* Class Header Notes
** Apex class to evaluate Opportunity questions/answers and check boolean fields accordingly.
*
* 
***********************************************************************************************/
public without sharing class OpportunityFormRules {
	private static final ID AWDRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AWD Enrollment').getRecordTypeId();
    private static final ID AFESRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AFES Enrollment').getRecordTypeId();

    public static Set<Id> createOpportunityCustomerSetupFormsIds = new Set<Id>();
    private static Map<Id, List<Marketed_Product__c>> OpportunityMarketedProducts = new Map<Id, List<Marketed_Product__c>>();

	// overload function so as not to break existing code 
	public static void setFormBooleans(List<Opportunity> opptyList) {
		setFormBooleans(opptyList,false,false);
	}
	
	private static void loadOpportunityMarketedProducts(List<Opportunity> opptyList) {
	    OpportunityMarketedProducts = new Map<Id, List<Marketed_Product__c>>();
	    
	    List<Marketed_Product__c> AllOpportunitiesMPs =
	    [SELECT Id,
	            Name,
	            Products__r.Chassis__c,
	            Products__r.Product_Family__c,
	            Plan_Status__c,
	            Enrollment__r.Enrollment_Opportunity__c
	       FROM Marketed_Product__c
	      WHERE Enrollment__r.Enrollment_Opportunity__c in :opptyList
          AND Enrollment__r.Enrollment_Opportunity__c != null
	      ORDER BY Enrollment__r.Enrollment_Opportunity__c];
	    
	    for (Marketed_Product__c opportunityMP : AllOpportunitiesMPs) {
	        List<Marketed_Product__c> oppMarketedProducts = OpportunityMarketedProducts.get(opportunityMP.Enrollment__r.Enrollment_Opportunity__c);
	        
	        if (oppMarketedProducts == null) {
	            oppMarketedProducts = new List<Marketed_Product__c>();
	            OpportunityMarketedProducts.put(opportunityMP.Enrollment__r.Enrollment_Opportunity__c, oppMarketedProducts);
	        }
	        
	        oppMarketedProducts.add(opportunityMP);
	    }
	}
	
    public static void setFormBooleans(List<Opportunity> opptyList, boolean calledFromGenInfoForm, boolean section125Required) 
    {
        loadOpportunityMarketedProducts(opptyList);
        
        for (Opportunity o : opptyList) {

            if(o.RecordTypeId == AFESRtId || o.RecordTypeId == AWDRtId) {
				//jhicks - 12/16 - set S125 flag only when called from General Information Form (which has the products)
				//otherwise leave as is
				
				if (calledFromGenInfoForm) {
					o.Has_Section_125_setup_form__c = section125Required;
				}
				else {
					// Reservice can set whether or not to generate the Section 125 Form
					// The flag being set in general information should probably be refactored
					o.Has_Section_125_setup_form__c = section125Check(o);
				}

				
				o.Has_Private_Exchange_form__c = privateExchangeFormCheck(o);
				o.Has_Customer_Setup_form__c = customerSetupFormCheck(o);
				o.Has_Section_125_Plan_Summary_form__c = section125PlanSummaryFormCheck(o);
				o.Has_Platform_Setup_Form__c = PlatformSetupFormCheck(o);
				 			
    		}
            
    		system.debug('::: Opportunity: ' + o.Name + ' form booleans: ' + o.Has_Trust_Subscription_Agreement__c+ ', ' + 
    			o.Has_Subscription_Agreement__c+ ', ' +
    			o.Has_Section_125_setup_form__c+ ', ' +
    			o.Has_Private_Exchange_form__c+ ', ' +
    			o.Has_Customer_Setup_form__c+ ', ' +
    			o.Has_Section_125_Plan_Summary_form__c+ ', ' + 
    			o.Has_Platform_Setup_Form__c
    			);
       }
    	
    }
    
    // Determine if Customer Setup Form should be created
    public static Boolean customerSetupFormCheck (Opportunity o)
    {
        system.debug('### Customer Form Check');
    	
		// Check for 'New' group 
		if (o.Confirm_New_or_Existing_Group__c == 'New'){ 
            system.debug('### Customer Form Check 1');
				return true;
		} 
		
		else if (o.Confirm_New_or_Existing_Group__c == 'Existing' ){
			string newPlans = o.Are_you_adding_new_plans_or_services__c == null ? 'x' : o.Are_you_adding_new_plans_or_services__c;
	
			if (newPlans.containsIgnoreCase('New Group Plans') || newPlans.containsIgnoreCase('New Annuity Plans') ||
			    o.Are_you_making_any_billing_changes__c == 'Yes'|| o.Requesting_Open_Enrollment__c == 'Yes' ||
			    o.Add_a_New_Group_Plan_s__c || o.Add_an_Annuity__c || o.Add_a_New_Billing_Mode__c)
            {
                system.debug('### Customer Form Check 2');
                return true;
            } 
		}
		
		if (createOpportunityCustomerSetupFormsIds.contains(o.Id)) {
            system.debug('### Customer Form Check 3');
		    return true;
		}
		
		List<Marketed_Product__c> oppMarketedProducts = OpportunityMarketedProducts.get(o.Id);
        
        system.debug('### Customer Form Check Marketed Products: ' + oppMarketedProducts);
		
		if (oppMarketedProducts != null &&
		    o.Confirm_New_or_Existing_Group__c == 'Existing' &&
            o.Are_you_adding_new_plans_or_services__c == 'No Changes') {

		    for (Marketed_Product__c mp : oppMarketedProducts) {
		        if (mp.Plan_Status__c == 'New' &&
		            mp.Products__r.Chassis__c == 'Group') {
                        system.debug('### Customer Form Check 4');
		            return true;
	            }
	            
	            if (mp.Plan_Status__c == 'New' &&
                    (mp.Products__r.Product_Family__c == 'Fixed Annuity' ||
                     mp.Products__r.Product_Family__c == 'Variable Annuity')) {
                         system.debug('### Customer Form Check 5');
                    return true;
                }
		    }
		}
		
        system.debug('### Customer Form Check FALSE');
		return false;	
    }
	
    public static Boolean privateExchangeFormCheck(Opportunity o)
    {
		// Check for 'New' group 
		if (o.Confirm_New_or_Existing_Group__c != null && o.Confirm_New_or_Existing_Group__c.equalsIgnoreCase('New'))
		{ 		
	 		if (o.What_products_are_you__c != null && o.What_products_are_you__c.contains('AF Benefits Market'))
			{
				return true;
			} else return false;
		// Check for 'Existing' Group
		} else if (o.Confirm_New_or_Existing_Group__c != null && o.Confirm_New_or_Existing_Group__c.equalsIgnoreCase('Existing') &&	o.Are_you_making_any_product_changes__c == 'Yes')
		{
	 		if(o.What_products_are_you_changing_or_adding__c != null && o.What_products_are_you_changing_or_adding__c.contains('AF Benefits Market'))
			{
				return true;
			} else return false;
		} else return false; 		
    }
    
    // Determine if Section 125 Plan Summary form should be created
    public static Boolean section125PlanSummaryFormCheck (Opportunity o)
    {
		// Only applicable for AWD record type
		if (o.RecordTypeId == AWDRtId && o.Generate_a_Section_125_One_page_summary__c && o.Confirm_New_or_Existing_Group__c.equalsIgnoreCase('Existing')) return true;
		else return false;
    }
    
    public static Boolean PlatformSetupFormCheck(Opportunity o)
    {
    	return true;
    }

    public static Boolean section125Check (Opportunity o) {
        if (o.Confirm_New_or_Existing_Group__c == 'Existing' ) {
	
            if (o.Add_a_Section_125_Plan__c || o.Add_a_FSA__c || o.Add_a_HSA__c || o.Add_a_HRA__c) {
                return true;
            }
        }

        return false;
    }
}