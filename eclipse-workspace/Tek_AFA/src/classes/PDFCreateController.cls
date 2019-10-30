public class PDFCreateController {

    public Opportunity opptyItem            {get;set;}
    public string idVal                     {get;set;}
    public string other                     {get;set;}
    public string title                     {get;set;}
    public string printedSignature          {get;set;}

    public String effDate                   {get;set;}
    public String physStreet                {get;set;}
    public String physCity                  {get;set;}
    public String physState                 {get;set;}
    public String physZip                   {get;set;}
    public String legalName                 {get;set;}
    public Boolean pdf                      {get;set;}
    public Attachment a                     {get;set;}
    public Id enrollmentFormId              {get;set;}
    public Id accountId						{get;set;}
    public Id opportunityId                 {get;set;}
    public Id attachmentId                  {get;set;}
    public Id SubscriptionAgreementSig      {get;set;}
    public Id ServiceExchangeSig            {get;set;}
    public Id MasterEfId                    {get;set;}
    public String retUrl                    {get;set;}
    public String status                    {get;set;}
    public String attBody                   {get;set;}

    public String day                       {get;set;}
    public String month                     {get;set;}
    public String year                      {get;set;}
    
    public String statusMsg                 {get;set;}
    public String SubscriptionPDF           {get;set;}
    public String ServicePDF                {get;set;}
    public String deleteId                  {get;set;}
    public List<FormSelection> formSelect   {get;set;}
    public List<FormSelection> generatedForms   {get;set;}

    public static string notNeededStatus    { get{ return 'Not Needed'; } }
    public static string submittedStatus    { get{ return 'Submitted'; } }
    public static string uploadedStatus		{ get{ return 'Submitted via Upload'; } }
    public static string inProgressStatus   { get{ return 'In Progress'; } }

    //Constructor
    public PDFCreateController(ApexPages.StandardController stdController){
        
        enrollmentFormId = stdController.getId();
        
        // Get the master enrollment form and Opportunity
        Enrollment_Form__c ef = [SELECT Id, Enrollment_Opportunity__c FROM Enrollment_Form__c WHERE Id =: enrollmentFormId];
        
        // Get Opportunity fields
        Opportunity o = [
            SELECT  Id,
            Name,
            AccountId,
            Account.Name,
            Account.BillingCity,
            Account.BillingState,
            Account.BillingPostalCode,
            Account.BillingStreet,
            Estimated_Employees__c,
            Enrollment_Start_Date__c,
            Effective_Date_of_AFA_Products__c,
            Division__c
            FROM Opportunity
            WHERE Id =: ef.Enrollment_Opportunity__c];
        
        opptyItem = o;
        opportunityId = o.Id;
        accountId = o.AccountId;
        
        //Gather each sig form record
        List<RecordType> efRTs = [
            SELECT Id, Name, DeveloperName
            FROM RecordType
            WHERE sObjectType = 'Enrollment_Form__c'
            AND IsActive = true
        ];
        
        List<Enrollment_Form__c> forms = [
            SELECT Id, Name, RecordtypeId, RecordType.DeveloperName, Status__c, Signature_Form_Name__c, Auto_Generated__c
            FROM Enrollment_Form__c
            WHERE Enrollment_Opportunity__c =: opportunityId
        ];
        
        // Build our selection list
        formSelect = new List<formSelection>();
        generatedForms = new List<formSelection>();
        for(RecordType rt : efRTs)
        {
            string dName = rt.DeveloperName;
            if(dName != 'Master')
            {
                formSelect.add(new FormSelection(rt.Name, rt.DeveloperName, rt.Id));
            }
        }
        
        // Remove selections for forms that already exist
        boolean inProgress = false;
        for (Enrollment_Form__c form: forms)
        {
            for (RecordType rt : efRTs)
            {
                if(form.RecordTypeId == rt.Id)
                {
                    string dName = rt.DeveloperName;
                    
                    if (dName == 'Subscription_Agreement')
                    {
                        SubscriptionAgreementSig = form.Id;
                        SubscriptionPDF = '/apex/Disability_Subscription_Form_PDF?id='+ form.Id;
                        generatedForms.add(new FormSelection(form.Id, form.Signature_Form_Name__c, dName, form.Status__c, SubscriptionPDF, form.Auto_Generated__c, 'Required for new accounts with group plans that are issued via Trust.', 1));
                    }
                    else if (dName == 'Service_Exchange_Agreement')
                    {
                        ServiceExchangeSig = form.Id;
                        ServicePDF = '/apex/ServiceExchangePDF?id='+ form.Id;
                        generatedForms.add(new FormSelection(form.Id, form.Signature_Form_Name__c, dName, form.Status__c, ServicePDF, form.Auto_Generated__c, 'Required with new group who has AFA\'s Section 125 & FSA plans.', 2));
                    }
                    else if (dName == 'Master')
                        MasterEfId = form.id;
                }
                
                for(Integer i = formSelect.size() - 1; i >= 0; --i)
                {
                    if(formSelect.get(i).RecordTypeName == form.RecordType.DeveloperName)
                        formSelect.remove(i);
                }
            }
            
            if(form.Status__c == 'In Progress')
                inProgress = true;
        }
        
        generatedForms.sort();
        
        system.debug(formSelect);
        
        if(inProgress)
            statusMsg = 'In Progress';
    }


    // Standard Api for JS access to enrollment forms
    @RemoteAction
    static public List<Enrollment_Form__c> getEnrollmentForms(Id opportunityId)
    {
        // get enrollment forms for oppertunity
         List<Enrollment_Form__c> forms = [
            SELECT
                    Id,
                    Status__c,
                    Name,
                    Enrollment_Opportunity__c,
                    Other__c,
                    Title__c,
                    Printed_Signature__c,
                    Day__c,
                    Month__c,
                    Year__c,
                    Physical_Address_Street__c,
                    Physical_Address_State__c,
                    Physical_Address_City__c,
                    Effective_Date_of_AFA_Products__c ,
                    Physical_Address_Zip_Code__c,
                    Legal_Name_Text__c,
                    Digital_Signature__c,
                    RecordType.DeveloperName,
                    Signature_Form_Name__c,
                    Enrollment_Opportunity__r.Account.BillingStreet,
                    Enrollment_Opportunity__r.Account.BillingCity,
                    Enrollment_Opportunity__r.Account.BillingState,
                    Enrollment_Opportunity__r.Account.BillingPostalCode,
             		Enrollment_Opportunity__r.AccountId,
                    MCP_Number__c,
                    Common_Ownership__c

            FROM    Enrollment_Form__c

            WHERE
                    Enrollment_Opportunity__c =: opportunityId  AND
                    RecordType.sObjectType = 'Enrollment_Form__c'   AND
                    RecordType.DeveloperName IN (
                        'Subscription_Agreement',
                        'Service_Exchange_Agreement'
                    )

        ];

        // After retrieval the status should be in progress;
        List<Enrollment_Form__c> formsToUpdate = new List<Enrollment_Form__c>();
        for(Enrollment_Form__c form : forms) {
            if(form.Status__c == notNeededStatus || form.status__c == submittedStatus || form.Status__c == uploadedStatus)
                break;

            form.Status__c = inProgressStatus;

            formsToUpdate.add(form);
        }
        
        if(formsToUpdate.size() > 0)
            update formsToUpdate;
        
        return forms;
    }

     @RemoteAction
     static public Opportunity getOpportunity(Id id)
     {
         return [
            SELECT
                Id,
                Name,
                Account.Name,
                Account.BillingCity,
                Account.BillingState,
                Account.BillingPostalCode,
                Account.BillingStreet,
                Estimated_Employees__c,
                Effective_Date_of_AFA_Products__c
            FROM Opportunity
            WHERE Id =: id
        ];
     }
    
    @RemoteAction
    static public Enrollment_Form__c saveEnrollmentFormForPrint(Enrollment_Form__c form)
    {
        update form;
        
        return form;
    }

    @RemoteAction
    static public Enrollment_Form__c updateEnrollmentForm(Enrollment_Form__c form)
    {

        form.Status__c = getEnrollmentFormStatus(form);
        if(form.Status__c != notNeededStatus)
        {
            updateSignature(form);

            if(ValidateEnrollmentForm(form)) {
                form.Status__c = submittedStatus;
                
                // if the form is valid we want to update the pdf that gets attached to the account
                updatePDF(form, form.Enrollment_Opportunity__r);
            }
        }

        update form;
        
        if(form.RecordTypeId == Constants.SIGNATURE_SERVICE_EXCHANGE_AGREEMENT)
            UploadedSignatureHelper.UpdateAccountOnServiceExchangeSubmitted(form.Enrollment_Opportunity__r.AccountId);

        return form;

    }

    @RemoteAction
    static public string getEnrollmentFormStatus(Enrollment_Form__c form)
    {
        if(form.Status__c == notNeededStatus)
            return notNeededStatus;

        return inProgressStatus;
    }

    @RemoteAction
    static public Opportunity updateOpportunity(Opportunity opportunity)
    {
        update opportunity;
        
        return opportunity;
    }
    
    // Helper Functions
    public static void updateSignature(Enrollment_Form__c enrollment)
    {
        System.debug(enrollment);

        string contentType  = 'image/png';
        string name         = 'SignaturePDF.png';
        Blob content        = EncodingUtil.base64Decode(enrollment.Digital_Signature__c);

        delete [
            SELECT Id FROM Attachment
            WHERE
                ParentId =: enrollment.Id AND
                Name =: name
        ];

        insert new Attachment(
            ParentId = enrollment.Id,
            Body = content,
            ContentType = contentType,
            Name = name
        );

    }

    public static boolean updatePDF(Enrollment_Form__c enrollment, Opportunity opportunity)
    {
        string url = '';
        string name = enrollment.RecordType.DeveloperName;
        
        if(name == 'Subscription_Agreement')
            url = 'Disability_Subscription_Form_PDF';
        else if(name == 'Service_Exchange_Agreement')
            url = 'ServiceExchangePDF';
        else
            return false;

        PageReference pagePdf = new PageReference('/apex/'+url);

        pagePdf.getParameters().put('id', enrollment.Id);
        
        return true;
    }

    public static Boolean ValidateEnrollmentForm(Enrollment_Form__c form)
    {
        string[] properties = new string [] {
            'Printed_Signature__c',
            'Title__c',
            'Digital_Signature__c',
            'Month__c',
            'Day__c',
            'Year__c'
        };


        for(string property : properties)
        {
            if(form.get(property) == null)
                return false;
        }

        return true;
    }
    
    public pageReference generateNewForms()
    {
        system.debug('Form selections: ' + formSelect);
        
        List<Enrollment_Form__c> newToInsert = new List<Enrollment_Form__c>();
        
        for(FormSelection f : formSelect)
        {
            if(f.selected)
            {
                Enrollment_Form__c newSigForm = new Enrollment_Form__c();
                newSigForm.Auto_Generated__c = false;
                newSigForm.Enrollment_Opportunity__c = opportunityId;
                newSigForm.RecordTypeId = f.RecordTypeId;
                newSigForm.Status__c = 'In Progress';
                
                newToInsert.add(newSigForm);
            }  
        }
        
        if(newToInsert.size() > 0)
            insert newToInsert;
        
        PageReference redirect;
        redirect = new PageReference('/apex/FormSignatureCapture?id=' + enrollmentFormId);
        redirect.setRedirect(true);
        
        return redirect;
    }
    
    public pageReference deleteEnrollmentForm()
    {
        system.debug('### deleteId: ' + deleteId);
        if(deleteId != null)
        {
            Enrollment_Form__c formToDelete = [SELECT Id FROM Enrollment_Form__c WHERE Id =: deleteId];
            
            system.debug('### formToDelete: ' + formToDelete);
            
            delete formToDelete;
        }
        
        PageReference redirect;
        redirect = new PageReference('/apex/FormSignatureCapture?id=' + enrollmentFormId);
        redirect.setRedirect(true);
        
        return redirect;
    }
}