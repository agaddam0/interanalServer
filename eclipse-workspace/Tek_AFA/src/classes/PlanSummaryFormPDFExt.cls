public with sharing class PlanSummaryFormPDFExt {

    public Section_125_Plan_Summary__c s                {get;set;}
    public Account acc                                  {get;set;}
    public List<Plan_Date__c> planDates                 {get;set;}
    public Enrollment_Form__c enrollmentForm            {get;set;}
    public Opportunity enrollmentOpp                    {get;set;}

    public PlanSummaryFormPDFExt(ApexPages.StandardController stdController)
    {        
        this.s = (Section_125_Plan_Summary__c)stdController.getRecord();
        
        // Get the Enrollment Form
        enrollmentForm = [SELECT Id, Enrollment_Opportunity__c 
                          FROM Enrollment_Form__c WHERE Id =: s.Enrollment_Form__c];
        
        // Get the Opportunity
        enrollmentOpp = [SELECT Id, AccountId, MCP_Number__c, Tax_Id__c, Additional_MCPs__c 
                         FROM Opportunity WHERE Id =: enrollmentForm.Enrollment_Opportunity__c];
        
        // Get the Account
        acc = [SELECT Id, Name, BillingAddress, ShippingAddress, Type, BillingStreet, BillingCity, BillingState, 
               ShippingStreet, ShippingCity, ShippingState, OwnerId, Owner.Agent_Id__c, Owner.Name 
               FROM Account WHERE Id =: enrollmentOpp.AccountId];
        
        // Get the Plan Dates
        planDates = [SELECT ID, Name, Plan_Name__c, Product__c, Plan_Start_Date__c, Plan_End_Date__c, Account__c 
                     FROM Plan_Date__c WHERE Account__c =: acc.Id];
    }
}