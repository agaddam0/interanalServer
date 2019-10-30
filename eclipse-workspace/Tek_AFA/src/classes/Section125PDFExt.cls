public with sharing class Section125PDFExt {
	
	public List<Section_125_Setup_Form__c> section125s	{get;set;}
	public Enrollment_Form__c enrollmentForm			{get;set;}
    public string formType								{get;set;}
    public List <Marketed_Product__c> mProducts_svc		{get;set;} 
    public boolean showS125tab							{get;set;}
    public boolean showFSAtab							{get;set;}
    public boolean showHSAtab							{get;set;}

	public Section125PDFExt(ApexPages.standardController stdCtrl)
	{
        Id efId = stdCtrl.getId();
		
        // Gets parent Enrollment Form
		this.enrollmentForm = [SELECT Id, 
                               Name, 
                               OwnerId, 
                               Enrollment_Opportunity__c, 
                               Enrollment_Opportunity__r.AccountId, 
                               Enrollment_Opportunity__r.Division__c, 
                               Enrollment_Opportunity__r.OwnerID, 
                               Enrollment_Opportunity__r.MCP_Number__c,
                               Enrollment_Opportunity__r.Assigned_Account_Manager__r.Name,
                               Enrollment_Opportunity__r.Tax_ID_Number__c
                              FROM Enrollment_Form__c WHERE Id =: efId];
        
        mProducts_svc = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                         products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c 
                         From Marketed_Product__c 
                         where enrollment__c = :efId and products__r.Type__c = 'Service'
                           and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                         order by products__r.Order__c];
        
        // Gets the Section 125 forms
        String soql = Util.getCreatableFields('Section_125_Setup_Form__c');
        
        // Related Employers
        soql += ', (SELECT Id, Name, Legal_Name__c, Address_Line_1__c, Address_Line_2__c, City__c, DBA_Name__c, ' + 
            ' State__c, State_Picklist__c, ZipCode__c, Contact_Name__c, Contact_Email__c, Contact_Phone_Extension__c, Contact_Phone_Number__c, Employer_Tax_ID_Number__c ' +
            ' FROM Common_Ownership_Forms__r ORDER BY CreatedDate)';
        
        // Qualified Benefits
        soql += ', (SELECT ID, Name, Carrier__c, Plan_Name__c, Product_Description__c, Eligibility__c, Add_Benefit__c' +
                ' FROM Qualitfied_Benefits_Form__r ORDER BY CreatedDate)';
                
        // Bill Modes
        Set<String> billModeFields = Util.getFieldSetFields(SObjectType.Bill_Mode__c.FieldSets.Flex_Billing);

        soql += ', (SELECT Id, ' + String.join(new List<String>(billModeFields), ',') +
                ' FROM Bill_Modes__r)';
        
        // FROM Clause
        soql += ' FROM Section_125_Setup_Form__c ';
        // WHERE Clause
        soql += ' WHERE Enrollment_Form__c = \'' + enrollmentForm.Id + '\' ORDER BY CreatedDate';
        
        system.debug('soql: ' + soql);
        section125s = (List<Section_125_Setup_Form__c>)Database.query(soql);
        
        formType = enrollmentForm.Enrollment_Opportunity__r.Division__c;
        
        showFSAtab = false;
        showHSAtab = false;
        showS125tab = false;
        
        for(Section_125_Setup_Form__c s : section125s)
        {            
            for(Marketed_Product__c mp : mProducts_svc)
            {
                if(mp.Products__r.Name == 'Section 125' && mp.Plan_Status__c == 'New')
                    showS125tab = true;
                
                if(mp.Products__r.Name == 'HSA' && mp.Plan_Status__c == 'New')
                    showHSAtab = true;
                
                if(mp.Products__r.Name == 'Health FSA' && mp.Plan_Status__c == 'New')
                    showFSAtab = true;
                
                if(mp.Products__r.Name == 'Dependent Daycare FSA' && mp.Plan_Status__c == 'New')
                    showFSAtab = true;
            }
        }
	}
}