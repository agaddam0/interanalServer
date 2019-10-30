public with sharing class PlatformSetupFormPDFExt {

    public Platform_Setup__c p							{get;set;}
    public List<Core_Benefit_Form__c> coreBenefits		{get;set;}

	public PlatformSetupFormPDFExt(ApexPages.standardController stdCtrl)
	{
        List<String> fieldsToAdd = new List<String>{'Enrollment_Form__c'};

        if (!Test.isRunningTest()){
            stdCtrl.addFields(fieldsToAdd);
        }

        this.p = (Platform_Setup__c)stdCtrl.getRecord();

        coreBenefits = [SELECT ID, 
                               Name, 
                               Carrier__c, 
                               Plan_Name__c, 
                               Product_Description__c,
                               Add_Core_Benefit__c,
                               Individual_Employer_Contribution__c, 
                               Individual_Children_Employer_Contribu__c, 
                               Individual_Children_Rate__c, 
                               Individual_Family_Rate__c, 
                               Individual_Family_Employer_Contributi__c, 
                               Individual_Spouse_Employer_Contributi__c, 
                               Individual_Spouse_Rate__c, 
                               Individual_Rate__c, 
                               OtherInformation__c ,
                               Rates__c
                          FROM Core_Benefit_Form__c
                         WHERE Platform_Setup_Form__c =: p.Id
                         ORDER BY createddate];  
	}
}