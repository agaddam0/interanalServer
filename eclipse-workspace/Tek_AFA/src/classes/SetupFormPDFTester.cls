@isTest
public class SetupFormPDFTester {
    
    public static testMethod void TestSetupFormPDFPages()
    {
        Util u = new Util();
        Id AcctRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id OppRType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AWD Enrollment').getRecordTypeId();
        Account a = u.createOneAcc('Test Account', true, AcctRType);
        Contact c = u.createOneCont('Test First', 'Test Last', a.Id, true);
        
        Opportunity o = u.createOneOpp('Test Opp', 'Enrollment', a.Id, false, OppRType);
        o.Marketed_Products__c = 'HSA';
        o.Administrative_Contact__c = c.Id;
        o.Confirm_New_or_Existing_Group__c = 'Existing';
        o.Are_you_making_any_product_changes__c = 'Yes';
        //o.What_products_are_you_changing_or_adding__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
        o.Generate_a_Section_125_One_page_summary__c = true;
        o.Are_you_adding_new_plans_or_services__c = 'New Group Plans';
        o.Has_Section_125_setup_form__c = true;
        insert o;
        
        // For the Section 125 Form generation
        List<Opportunity> oppty = new List<Opportunity>();
        oppty.add(o);
        OpportunityFormRules.setFormBooleans(oppty, true, true );
        update oppty;
        
        Id enrollment_form_master_Id = [SELECT Id FROM RecordType WHERE sObjectType = 'Enrollment_Form__c' AND DeveloperName = 'Master' LIMIT 1].Id;
        Enrollment_Form__c eForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: o.Id AND RecordTypeId =: enrollment_form_master_Id];
        system.debug('eForm ' + eForm);
        
        /***********  Customer Setup Form *******************/
        Customer_Setup_Form__c CSF = [SELECT Id FROM Customer_Setup_Form__c WHERE Enrollment_Form__c =: eForm.Id];
        CSF.ContactInfoBenefitContactSame__c = 'No';
        CSF.ContactInfoBenefitContact__c = c.Id;
        CSF.ContactInfoBillingContactSame__c = 'No';
        CSF.ContactInfoBillingContact__c = c.Id;
        update CSF;
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(CSF);
        CustomerSetupFormPDFExt CustomerPDF = new CustomerSetupFormPDFExt(ctrl);
        
        /***********  Platform Setup Form *******************/
        Platform_Setup__c PSF = [SELECT Id, Enrollment_Form__c FROM Platform_Setup__c WHERE Enrollment_Form__c =: eForm.Id];
        ctrl = new ApexPages.StandardController(PSF);
        PlatformSetupFormPDFExt PlatformPDF = new PlatformSetupFormPDFExt(ctrl);
        
        /***********  Section 125 Setup Form ****************/
        ctrl = new ApexPages.StandardController(eForm);
        Section125PDFExt s125PDF = new Section125PDFExt(ctrl);
        
        /***********  Plan Summary Form *********************/
        Section_125_Plan_Summary__c Summary = [SELECT Id, Enrollment_Form__c FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__c =: eForm.Id];
        ctrl = new ApexPages.StandardController(Summary);
        PlanSummaryFormPDFExt summaryPDF = new PlanSummaryFormPDFExt(ctrl);
    }
}