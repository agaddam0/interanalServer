public class FormStatusCTRL {
    
    public string opportunityId                     	{get;set;}
    public List<Enrollment_Form__c> eForms          	{get;set;}
    public string eFormId								{get;set;}
    public List<FormStatusWrapperClass> fStatus			{get;set;}
    public List<FormStatusWrapperClass> inProgress		{get;set;}
    public List<FormStatusWrapperClass> submitted		{get;set;}
    public List<FormStatusWrapperClass> HOProcessing	{get;set;}
    public List<FormStatusWrapperClass> waiting			{get;set;}
    public List<FormStatusWrapperClass> completed		{get;set;}
    
    public FormStatusCTRL(ApexPages.StandardController ctrl)
    {
        opportunityId = ctrl.getId();
        
        if(opportunityId != null)
        {
            fStatus = new List<FormStatusWrapperClass>();
            GetEnrollmentForms();
        }
        
        if(eFormId != null)
        {
            GetSetupForms();
        }
        
        fstatus.sort();
        
        inprogress = new List<FormStatusWrapperClass>();
        submitted = new List<FormStatusWrapperClass>();
        HOProcessing = new List<FormStatusWrapperClass>();
        waiting = new List<FormStatusWrapperClass>();
        completed = new List<FormStatusWrapperClass>();
        if(fStatus.size() > 0)
        {
            for(FormStatusWrapperClass fs : fStatus)
            {
                if(fs.Status == 'In Progress')
                    inprogress.add(fs);
                if(fs.Status == 'Submitted' || fs.Status == 'Pending Update' || fs.Status == 'Updated' || fs.Status == 'Submitted via Upload')
                    submitted.add(fs);
                if(fs.Status == 'H.O. Processing')
                    HOProcessing.add(fs);
                if(fs.Status == 'Waiting on Information')
                    waiting.add(fs);
                if(fs.Status == 'Completed')
                    completed.add(fs);
            }
        }
    }
    
    public void GetEnrollmentForms()
    {
        eForms = [SELECT Id, Name, Owner.Name, Status__c, RecordType.Name FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: opportunityId];
        
        // sort order only puts the enrollment forms behind the setup forms
        Integer sortOrder = 5;
        for(Enrollment_Form__c e : eForms)
        {
            if(e.RecordType.Name == 'Master')
                eFormId = e.Id;
            else
                fStatus.add(new FormStatusWrapperClass(e.RecordType.Name, e.Status__c, e.Owner.Name, sortOrder));
            
            sortOrder++;
        }                   
    }
    
    public void GetSetupForms()
    {
        List<Platform_Setup__c> pForms = [SELECT Id, Status__c, Owner.Name FROM Platform_Setup__c WHERE Enrollment_Form__c =: eFormId 
                                          AND (RecordType.Name = 'AWD Form' OR RecordType.Name = 'AFES Form')];
        for(Platform_Setup__c p : pForms)
        {
            fStatus.add(new FormStatusWrapperClass('Platform Setup', p.Status__c, p.Owner.Name, 3));
        }
        
        List<Customer_Setup_Form__c> cForms = [SELECT Id, Status__c, Owner.Name FROM Customer_Setup_Form__c WHERE Enrollment_Form__c =: eFormId];
        for(Customer_Setup_Form__c c : cForms)
        {
            fStatus.add(new FormStatusWrapperClass('Customer Setup', c.Status__c, c.Owner.Name, 1));
        }
        
        List<Section_125_Setup_Form__c> sForms = [SELECT Id, Status__c, Owner.Name FROM Section_125_Setup_Form__c WHERE Enrollment_Form__c =: eFormId];
        for(Section_125_Setup_Form__c s : sForms)
        {
            fStatus.add(new FormStatusWrapperClass('Section 125 Setup', s.Status__c, s.Owner.Name, 2));
        }
        
        List<Section_125_Plan_Summary__c> psForms = [SELECT Id, Status__c, Owner.Name FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__c =: eFormId];
        for(Section_125_Plan_Summary__c ps : psForms)
        {
            fStatus.add(new FormStatusWrapperClass('Plan Summary', ps.Status__c, ps.Owner.Name, 4));
        }
        
        List<Pre_Enrollment_Marketing_Form__c> mrkForms = [SELECT Id, Status__c, Owner.Name FROM Pre_Enrollment_Marketing_Form__c WHERE Enrollment_Form__c =: eFormId];
        for(Pre_Enrollment_Marketing_Form__c mf : mrkForms) 
        {
            fStatus.add(new FormSTatusWrapperClass('Pre-Enrollment Marketing', mf.Status__c, mf.Owner.Name, 5));
        }
    }
}