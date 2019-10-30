public class PolicyholderChangeRequestEXT {
    
    public List<cRecordType> recordTypeSelection        {get;set;}
    public Policyholder__c holder                       {get;set;}
    public List<cRecordType> selectedTypes              {get;set;}
    public List<cProduct> purchProducts                 {get;set;}
    public List<cProduct> selectedProducts              {get;set;}
    public Change_Request__c EmployerTransfer           {get;set;}
    public Change_Request__c AddressChange              {get;set;}
    public Change_Request__c BeneficiaryChange          {get;set;}
    public Change_Request__c ContactChange              {get;set;}
    public Change_Request__c ConservationRequest        {get;set;}
    private Id holderAccountId                          {get;set;}
    public boolean EmployerTransferSubmitted            {get;set;}
    public boolean AddressChangeSubmitted               {get;set;}
    public boolean BeneficiaryChangeSubmitted           {get;set;}
    public boolean ContactChangeSubmitted               {get;set;}
    public boolean ConservationRequestSubmitted         {get;set;}
    public boolean isError                              {get;set;}
    public boolean disableSubmitButton                  {get;set;}
    public boolean productsError                        {get;set;}
    public Id AddressChangeId                           {get;set;}
    public Id ContactChangeId                           {get;set;}
    public Id EmployerChangeId                          {get;set;}
    public Id BeneficiaryChangeId                       {get;set;}
    public Id ConservationId                            {get;set;}
    public Integer activeTabNum                         {get;set;}
    public String LastFormSubmitted						{get;set;}
    public static String removeJobId					{get;set;}
    
    public PolicyholderChangeRequestEXT(ApexPages.StandardController ctrl)
    {
        Policyholder__c h = (Policyholder__c)ctrl.getRecord();
        
        AddressChangeId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Address Change').getRecordTypeId();
        ContactChangeId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Phone/Email Change').getRecordTypeId();
        EmployerChangeId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Employer Transfer').getRecordTypeId();
        BeneficiaryChangeId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Beneficiary Change').getRecordTypeId();
        ConservationId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Conservation').getRecordTypeId();
        
        LastFormSubmitted = '';
        
        holder = [SELECT Id, 
                      First_Name__c, 
                      Last_Name__c, 
                      Customer_Number__c, 
                      Social_Security_Number__c,
                      Primary_Phone__c,
                      Secondary_Phone__c,
                      Physical_Street_Address__c,
                      Physical_Street_Address_2__c,
                      Physical_City__c,
                      Physical_State__c,
                      Physical_Zip_Code__c,
                      Mailing_Street_Address__c,
                      Mailing_Street_Address_2__c,
                      Mailing_City__c,
                      Mailing_State__c,
                      Mailing_Zip_Code__c,
                      Personal_Email__c,
                      Work_Email__c
                  FROM Policyholder__c
                  WHERE Id =: h.Id];
        
        String RequestNumber = ApexPages.currentPage().getParameters().get('ReqNum');
        String ConservationRecTypeId = ApexPages.currentPage().getParameters().get('RType');
        
        // Loading the page for view
        if(RequestNumber != null)
        {
            system.debug('Request Number: ' + RequestNumber);
            Integer Rnum = 0;
            if(RequestNumber != 'new')
                Rnum = Integer.valueOf(RequestNumber);
            
            if(ConservationRecTypeId != null)
            {
                if(RequestNumber == 'new')
                {
                    Decimal size = GetSize();
                    
                    ConservationRequest = new Change_Request__c();
                    ConservationRequest.Policyholder__c = holder.Id;
                    ConservationRequest.RecordTypeId = ConservationRecTypeId;
                    ConservationRequest.Status__c = 'Pending';
                    ConservationRequest.Request_Number__c = size;
                }
                else
                {
                    Change_Request__c Con = [SELECT Id,
                                                 Last_Month_Paid_by_Group__c,
                                                 Reason_for_Leaving_Employment__c,
                                                 Is_customer_a_Flex_participant__c,
                                                 Additional_Info__c,
                                                 Date_of_Request__c,
                                                 Status__c,
                                                 Requesting_Agent_Id__c,
                                                 LastModifiedById,
                                                 LastModifiedDate
                                             FROM Change_Request__c
                                             WHERE RecordTypeId =: ConservationRecTypeId 
                                                 AND Request_Number__c =: Rnum 
                                                 AND Policyholder__c =: h.Id];
                    
                    if(con != null)
                    {
                        ConservationRequest = con;
                        if(con.Status__c == 'Submitted')
                            ConservationRequestSubmitted = true;
                    }
                }
            }
            else
            {
                List<Id> rTypeIds = new List<Id>();
                List<Change_Request__c> existingRequests = [SELECT Id,
                                                                RecordTypeId,
                                                                Account_Name__c,
                                                                Account_Name__r.MCP_Number__c,
                                                                Additional_Info__c,
                                                                Date_of_Request__c,
                                                                Effective_Date_of_Address_Change__c,
                                                                Effective_Date_of_Transfer__c,
                                                                First_Deduction_Date__c,
                                                                Group_Policy_Transfer__c,
                                                                Is_customer_a_Flex_participant__c,
                                                                Last_Month_Paid_by_Group__c,
                                                                Last_Deduction_Date__c,
                                                                Mailing_City__c,
                                                                Mailing_State__c,
                                                                Mailing_Street__c,
                                                                Mailing_Street_2__c,
                                                                Mailing_Zip__c,
                                                                Marital_Status__c,
                                                                New_Account_Name__c,
                                                                New_Account_Name__r.MCP_Number__c,
                                                                //New_Email_Address__c,
                                                                New_Personal_Email__c,
                                                                New_Primary_Phone__c,
                                                                New_Secondary_Phone__c,
                                                                New_Work_Email__c,
                                                                Number_of_Deductions__c,
                                                                Physical_City__c,
                                                                Physical_State__c,
                                                                Physical_Street__c,
                                                                Physical_Street_2__c,
                                                                Physical_Zip__c,
                                                                Policies_Affected_by_Request_Change__c,
                                                                Policyholder__c,
                                                                Policyholder_Customer_Number__c,
                                                                Reason_for_Leaving_Employment__c,
                                                                Requesting_Agent_Id__c,
                                                                Request_Number__c,
                                                                Status__c,
                                                                LastModifiedById,
                                                                LastModifiedDate
                                                            FROM Change_Request__c
                                                            WHERE Request_Number__c =: Rnum AND Policyholder__c =: h.Id];
                
                if(existingRequests.size() != 0)
                {
                    for(Change_Request__c r : existingRequests)
                    {
                        if(r.RecordTypeId == AddressChangeId)
                        {
                            AddressChange = r;
                            if(r.Status__c == 'Submitted')
                                AddressChangeSubmitted = true;
                        }
                        if(r.RecordTypeId == ContactChangeId)
                        {
                            ContactChange = r;
                            if(r.Status__c == 'Submitted')
                                ContactChangeSubmitted = true;
                        }
                        if(r.RecordTypeId == EmployerChangeId)
                        {
                            EmployerTransfer = r;
                            
                            purchProducts = getPurchasedProducts();
                            if(r.Policies_Affected_by_Request_Change__c != null)
                            {
                                List<String> policiesAffected = r.Policies_Affected_by_Request_Change__c.split(', \n');
                                for(cProduct p : purchProducts)
                                {
                                    for(String policy : policiesAffected)
                                    {
                                        if(policy.contains(p.PurchasedProduct.Product_Family__c + ' - ' + p.PurchasedProduct.Product_Description__c))
                                            p.selected = true;
                                    }
                                }
                            }
                            
                            if(r.Status__c == 'Submitted')
                                EmployerTransferSubmitted = true;
                        }
                        if(r.RecordTypeId == BeneficiaryChangeId)
                        {
                            BeneficiaryChange = r;
                            if(r.Status__c == 'Submitted')
                                BeneficiaryChangeSubmitted = true;
                        }
                        rTypeIds.add(r.RecordTypeId);
                    }
                    if(rTypeIds.size() > 0)
                    {
                        selectedTypes = new List<cRecordType>();
                        List<RecordType> rTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id IN: rTypeIds Order By Name asc];
                        if(rTypes.size() > 0)
                        {
                            for(RecordType r : rTypes)
                            {
                                selectedTypes.add(new cRecordType(r));
                            }
                        }
                    }
                }
            }
        }
        else
        {
            List<Purchased_Product__c> pProduct = [SELECT Id, Product_Family__c, Product_Description__c, Account__c, Monthly_Premium__c, Annualized_Premium__c FROM Purchased_Product__c WHERE Policyholder__c =: holder.Id LIMIT 1];
            if(pProduct.size() > 0)
                holderAccountId = pProduct[0].Account__c;
            String RecordTypeNamesFromComponent = ApexPages.currentPage().getParameters().get('RecordTypeNames');
            system.debug('Record Type Names From Component: ' + RecordTypeNamesFromComponent);
            if(RecordTypeNamesFromComponent != null || RecordTypeNamesFromComponent != '')
                createNewRequests(RecordTypeNamesFromComponent);
        }        
        
        disableSubmitButton = DisableButtons();
        activeTabNum = SetActiveTab('');
    }
    
    public boolean DisableButtons()
    {
        List<Change_Request__c> r = new List<Change_Request__c>();
        
        if(AddressChange != null)
            r.add(AddressChange);
        if(EmployerTransfer != null)
            r.add(EmployerTransfer);
        if(ContactChange != null)
            r.add(ContactChange);
        if(BeneficiaryChange != null)
            r.add(BeneficiaryChange);
        if(ConservationRequest != null)
            r.add(ConservationRequest);
        
        boolean allSubmitted = true;
        if(r.size() > 0)
        {
            for(Change_Request__c cr : r)
            {
                if(cr.Status__c != 'Submitted')
                    allSubmitted = false;
            } 
        }
        else
            allSubmitted = false;
        
        
        return allSubmitted;
    }
    
    public List<cProduct> getPurchasedProducts()
    {
        if(purchProducts == null)
        {
            purchProducts = new List<cProduct>();
            for(Purchased_Product__c p: [SELECT Id, 
                                         		Product_Family__c, 
                                         		Product_Description__c, 
                                         		Account__c, 
                                         		Monthly_Premium__c, 
                                         		Annualized_Premium__c 
                                         FROM Purchased_Product__c 
                                         WHERE Policyholder__c =: holder.Id
                                         AND (Policy_Status__c = 'Active' OR Lapse_Date__c = LAST_N_MONTHS:3)])
            {
                purchProducts.add(new cProduct(p));
            }
        }
        
        return purchProducts;
    }
    
    public List<cProduct> getSelectedProducts()
    {        
        if(purchProducts == null)
        {            
            for(cProduct p : getPurchasedProducts())
            {
                if(p.selected)
                    selectedProducts.add(p);
            }
        }
        
        return selectedProducts;        
    }
    
    public List<cRecordType> getRecordTypes()
    {
        if(recordTypeSelection == null) {
            recordTypeSelection = new List<cRecordType>();
            for(RecordType r: [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Change_Request__c' AND DeveloperName <> 'Conservation' AND DeveloperName <> 'Beneficiary_Change']) 
            {
                recordTypeSelection.add(new cRecordType(r));
            }
        }
        return recordTypeSelection;
    }
    
    public void createNewRequests(String RecordTypeNames)
    {
        selectedTypes = new List<cRecordType>();
        
        for(cRecordType r : getRecordTypes())
        {
            if(RecordTypeNames.contains(r.rt.Name))
                selectedTypes.add(r);
        }
        
        System.debug('These are the selected Record Types...');
        System.debug('Selected Types: ' + selectedTypes.size());
        
        Decimal size = getSize();
        
        List<Change_Request__c> newRequests = new List<Change_Request__c>();
        Change_Request__c request;
        for(cRecordType rec : selectedTypes)
        {
            request = new Change_Request__c();
            request.Policyholder__c = holder.Id;
            request.RecordTypeId = rec.rt.Id;
            request.Status__c = 'Pending';
            request.Request_Number__c = size;
            
            if(rec.rt.DeveloperName == 'Employer_Transfer')
            {
                request.Account_Name__c = holderAccountId;
                EmployerTransfer = request;
            }
            else if(rec.rt.DeveloperName == 'Address_Change')
                AddressChange = request;
            else if(rec.rt.DeveloperName == 'Beneficiary_Change')
                BeneficiaryChange = request;
            else if(rec.rt.DeveloperName == 'Phone_Email_Change')
                ContactChange = request;
        } 
    }
    
    public void EmployerTransferSubmitLogic()
    {
        if(EmployerTransfer.Account_Name__c == null)
        {
            EmployerTransfer.Account_Name__c.addError('Required');
            isError = true;
        }
        if(EmployerTransfer.New_Account_Name__c == null)
        {
            EmployerTransfer.New_Account_Name__c.addError('Required');
            isError = true;
        }
        if(EmployerTransfer.Last_Deduction_Date__c == null)
        {
            EmployerTransfer.Last_Deduction_Date__c.addError('Required');
            isError = true;
        }
        if(EmployerTransfer.Group_Policy_Transfer__c == null)
        {
            EmployerTransfer.Group_Policy_Transfer__c.addError('Required');
            isError = true;
        }
        
        productsError = true;
        for(cProduct d : getPurchasedProducts())
        {
            if(d.selected)
            {
                productsError = false;
            }
        }
    }
    
    public void EmployerTransferSaveLogic()
    {
        boolean firstrun = true;

        for(cProduct d : getPurchasedProducts())
        {
            if(d.selected)
            {
                if(d.PurchasedProduct.Annualized_Premium__c == null)
                    d.PurchasedProduct.Annualized_Premium__c = 0.00;

                String affectedPolicyInfo = d.PurchasedProduct.Product_Family__c + ' - ' + d.PurchasedProduct.Product_Description__c + ' - $' + d.PurchasedProduct.Annualized_Premium__c + ' ANNUALLY';

                if(!firstrun)
                {
                    EmployerTransfer.Policies_Affected_by_Request_Change__c += ', \n';
                    EmployerTransfer.Policies_Affected_by_Request_Change__c += affectedPolicyInfo;
                }
                else
                    EmployerTransfer.Policies_Affected_by_Request_Change__c = affectedPolicyInfo;

                firstrun = false;
            }                
        }
        system.debug('Policies: ' + EmployerTransfer.Policies_Affected_by_Request_Change__c);
    }
    
    public pageReference SaveAndSubmitEmployerTransfer()
    {
        isError = false;
        EmployerTransferSaveLogic();
        EmployerTransferSubmitLogic();
        
        lastFormSubmitted = '';
        
        if(!isError && !productsError)
        {
            EmployerTransfer.Status__c = 'Submitted';
            EmployerTransferSubmitted = true;
            EmployerTransfer.Date_of_Request__c = system.today();
            upsert EmployerTransfer;
            EmployerTransfer = queryChangeRequest(EmployerTransfer.Id);
            lastFormSubmitted = 'Employer Transfer';
            
            removeUserFromPublicGroup(removeJobId);
        } 
        
        activeTabNum = SetActiveTab('Employer Transfer');
        disableSubmitButton = DisableButtons();
        return null;
    }
    
    public PageReference SaveAddressChange()
    {
        upsert AddressChange;
        AddressChange = queryChangeRequest(AddressChange.Id);
        activeTabNum = SetActiveTab('Address Change');
        return null;
    }
    
    public PageReference SaveAndSubmitAddressChange()
    {
        try
        {
            AddressChange.Status__c = 'Submitted';
            AddressChangeSubmitted = true;
            AddressChange.Date_of_Request__c = system.today();
            upsert AddressChange;
            AddressChange = queryChangeRequest(AddressChange.Id);
            lastFormSubmitted = 'Address Change';
        }
        catch(Exception ex)
        {
            AddressChange.Status__c = 'Pending';
            AddressChangeSubmitted = false;
            AddressChange.Date_of_Request__c = null;
            ApexPages.addMessages(ex);
            lastFormSubmitted = '';
        }
        
        activeTabNum = SetActiveTab('Address Change');
        disableSubmitButton = DisableButtons();
        return null;
    }
    
    public PageReference SaveContactChange()
    {
        upsert ContactChange;
        ContactChange = queryChangeRequest(ContactChange.Id);
        activeTabNum = SetActiveTab('Phone/Email Change');
        return null;
    }
    
    public PageReference SaveAndSubmitContactChange()
    {
        try
        {
            ContactChange.Status__c = 'Submitted';
            ContactChangeSubmitted = true;
            ContactChange.Date_of_Request__c = system.today();
            upsert ContactChange;
            ContactChange = queryChangeRequest(ContactChange.Id);
            lastFormSubmitted = 'Phone/Email Change';
        }
        catch(Exception ex)
        {
            ContactChange.Status__c = 'Pending';
            ContactChangeSubmitted = false;
            ContactChange.Date_of_Request__c = null;
            ApexPages.addMessages(ex);
            lastFormSubmitted = '';
        }
        
        activeTabNum = SetActiveTab('Phone/Email Change');
        disableSubmitButton = DisableButtons();
        return null;
    }
    
    public PageReference SaveConservation()
    {
        upsert ConservationRequest;
        ConservationRequest = queryChangeRequest(ConservationRequest.Id);
        return null;
    }
    
    public PageReference SaveAndSubmitConservation()
    {
        isError = false;
        ConservationSubmitLogic();
        lastFormSubmitted = '';
        
        if(!isError)
        {
            ConservationRequest.Status__c = 'Submitted';
            ConservationRequestSubmitted = true;
            ConservationRequest.Date_of_Request__c = system.today();
            upsert ConservationRequest;
            ConservationRequest = queryChangeRequest(ConservationRequest.Id);
            lastFormSubmitted = 'Conservation';
        }
        
        disableSubmitButton = DisableButtons();
        return null;
    }
    
    public void ConservationSubmitLogic()
    {
        if(ConservationRequest.Last_Month_Paid_by_Group__c == null)
        {
            ConservationRequest.Last_Month_Paid_by_Group__c.addError('Required');
            isError = true;
        }
        if(ConservationRequest.Reason_for_Leaving_Employment__c == null)
        {
            ConservationRequest.Reason_for_Leaving_Employment__c.addError('Required');
            isError = true;
        }
    }
    
    public PageReference saveAll()
    {
        if(AddressChange != null)
        {
            upsert AddressChange;
            AddressChange = queryChangeRequest(AddressChange.Id);
        }
        if(EmployerTransfer != null)
        {
            EmployerTransferSaveLogic();
            upsert EmployerTransfer;
            EmployerTransfer = queryChangeRequest(EmployerTransfer.Id);
        }
        if(ContactChange != null)
        {
            upsert ContactChange;
            ContactChange = queryChangeRequest(ContactChange.Id);
        }
        if(BeneficiaryChange != null)
        {
            upsert BeneficiaryChange;
            BeneficiaryChange = queryChangeRequest(BeneficiaryChange.Id);
        }
        if(ConservationRequest != null)
        {
            upsert ConservationRequest;
            ConservationRequest = queryChangeRequest(ConservationRequest.Id);
        }
        
        return null;
    }
    
    public PageReference submitAll()
    {
        List<Change_Request__c> submitRequests = new List<Change_Request__c>();
        isError = false;
        
        if(AddressChange != null)
        {
            try
            {
                AddressChange.Status__c = 'Submitted';
                AddressChangeSubmitted = true;
                AddressChange.Date_of_Request__c = system.today();
                upsert AddressChange;
                AddressChange = queryChangeRequest(AddressChange.Id);
            }
            catch(Exception ex)
            {
                AddressChange.Status__c = 'Pending';
                AddressChangeSubmitted = false;
                AddressChange.Date_of_Request__c = null;
                ApexPages.addMessages(ex);
                activeTabNum = SetActiveTab('Address Change');
            }
        }
            
        if(EmployerTransfer != null)
        {
            isError = false;
            EmployerTransferSaveLogic();
            EmployerTransferSubmitLogic();
                
            if(!isError)
            {
                EmployerTransfer.Status__c = 'Submitted';
                EmployerTransferSubmitted = true;
                EmployerTransfer.Date_of_Request__c = system.today();
                upsert EmployerTransfer;
                EmployerTransfer = queryChangeRequest(EmployerTransfer.Id);
                removeUserFromPublicGroup(removeJobId);
            }
            else
               activeTabNum = SetActiveTab('Employer Transfer'); 
        }
            
        if(ContactChange != null)
        {
            try
            {
                ContactChange.Status__c = 'Submitted';
                ContactChangeSubmitted = true;
                ContactChange.Date_of_Request__c = system.today();
                upsert ContactChange;
                ContactChange = queryChangeRequest(ContactChange.Id);
            }
            catch(Exception ex)
            {
                ContactChange.Status__c = 'Pending';
                ContactChangeSubmitted = false;
                ContactChange.Date_of_Request__c = null;
                ApexPages.addMessages(ex);
                activeTabNum = SetActiveTab('Phone/Email Change');
            }
        }
            
        if(BeneficiaryChange != null)
        {
            BeneficiaryChange.Status__c = 'Submitted';
            BeneficiaryChangeSubmitted = true;
            BeneficiaryChange.Date_of_Request__c = system.today();
            upsert BeneficiaryChange;
            BeneficiaryChange = queryChangeRequest(BeneficiaryChange.Id);
        }
            
        if(ConservationRequest != null)
        {
            isError = false;
            ConservationSubmitLogic();
            
            if(!isError)
            {
                ConservationRequest.Status__c = 'Submitted';
                ConservationRequestSubmitted = true;
                ConservationRequest.Date_of_Request__c = system.today();
                upsert ConservationRequest;
                ConservationRequest = queryChangeRequest(ConservationRequest.Id);
            }
            else
                activeTabNum = SetActiveTab('Conservation');
        }
        
        if(!isError)
        {
            //return new PageReference('/' + holder.Id);
            disableSubmitButton = DisableButtons();
            lastFormSubmitted = 'All';
            return null;
        }
        
        return null;
    }
    
    public Decimal getSize()
    {
        decimal s;
        
        AggregateResult[] aggs = [SELECT MAX(Request_Number__c) max FROM Change_Request__c WHERE Policyholder__c =: holder.Id];
        s = (Decimal)aggs[0].get('max');
        
        if(s != null)
            s = s += 1;
        else
            s = 1;
        
        return s;
    }
    
    public Integer setActiveTab(String TabName)
    {
        Integer num = 0;
        
        if(selectedTypes != null)
        {
            for(Integer i = 0; i < selectedTypes.size(); i++)
            {
                if(selectedTypes[i].rt.Name == TabName)
                    num = i;
            }
        }
        
        return num;
    }
    
    private Change_Request__c queryChangeRequest(Id objId)
    {
        Change_Request__c cr = [SELECT Id,
                                    RecordTypeId,
                                    Account_Name__c,
                                    Account_Name__r.MCP_Number__c,
                                    Additional_Info__c,
                                    Date_of_Request__c,
                                    Effective_Date_of_Address_Change__c,
                                    Effective_Date_of_Transfer__c,
                                    First_Deduction_Date__c,
                                    Group_Policy_Transfer__c,
                                    Is_customer_a_Flex_participant__c,
                                    Last_Month_Paid_by_Group__c,
                                    Last_Deduction_Date__c,
                                    Mailing_City__c,
                                    Mailing_State__c,
                                    Mailing_Street__c,
                                    Mailing_Street_2__c,
                                    Mailing_Zip__c,
                                    Marital_Status__c,
                                    New_Account_Name__c,
                                    New_Account_Name__r.MCP_Number__c,
                                    //New_Email_Address__c,
                                    New_Personal_Email__c,
                                    New_Primary_Phone__c,
                                    New_Secondary_Phone__c,
                                    New_Work_Email__c,
                                    Number_of_Deductions__c,
                                    Physical_City__c,
                                    Physical_State__c,
                                    Physical_Street__c,
                                    Physical_Street_2__c,
                                    Physical_Zip__c,
                                    Policies_Affected_by_Request_Change__c,
                                    Policyholder__c,
                                    Policyholder_Customer_Number__c,
                                    Reason_for_Leaving_Employment__c,
                                    Requesting_Agent_Id__c,
                                    Request_Number__c,
                                    Status__c,
                                    LastModifiedById,
                                    LastModifiedDate
                                FROM Change_Request__c
                                WHERE Id =: objId];
        return cr;
    }
    
    public static string getPublicGroupName()
    {
        String publicGroupName = '';
        
        User loggedInUser = [SELECT Id, AFA_Division__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        if(loggedInUser.AFA_Division__c == 'AFES')
            publicGroupName = 'AFES_Employer_Transfer';
        
        if(loggedInUser.AFA_Division__c == 'AWD')
            publicGroupName = 'AWD_Employer_Transfer';
        
        return publicGroupName;
    }
    
    @remoteAction
    public static String addUserToPublicGroup()
    {
        system.debug('Adding User To Gorup');
        String publicGroupName = getPublicGroupName();
        
        if(publicGroupName != '')
        {
            Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName =: publicGroupName LIMIT 1];
            
            if(publicGroup != null)
            {
                GroupMember groupMemberToInsert = new GroupMember(GroupId = publicGroup.Id, UserOrGroupId = UserInfo.getUserId());
                insert groupMemberToInsert;
            }
        }
        
        if(String.isBlank(removeJobId))
            scheduleRemoveUserJob();
        
        return removeJobId;
    }
    
    @RemoteAction
    public static void removePermissions(String jobId)
    {
        removeUserFromPublicGroup(jobId);
    }
    
    @future
    public static void removeUserFromPublicGroup(String jobId)
    {
        system.debug('Removing User From Gorup');
        String publicGroupName = getPublicGroupName();
        
        if(publicGroupName != '')
        {
            Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName =: publicGroupName LIMIT 1];
            List<GroupMember> membersToDelete = [SELECT Id FROM GroupMember WHERE GroupId =: publicGroup.Id AND UserOrGroupId =: UserInfo.getUserId()];
            if(membersToDelete.size() > 0)
                delete membersToDelete;
        }
        
        // if this ran, then delete the scheduled job
        if(string.isNotBlank(jobId))
        {
            system.abortJob(jobId);
        }
            
    }
    
    public static string scheduleRemoveUserJob()
    {
        RemoveUsersFromEmployerTransferGroup removeJob = new RemoveUsersFromEmployerTransferGroup();
        DateTime dt = system.now().addMinutes(30);
        String sch = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        removeJobId = system.schedule(guid, sch, removeJob);
        
        return removeJobId;
    }
    
    @AuraEnabled
    public static Change_Request__c newConservationRequest(String policyholderId)
    {
        Decimal size = getSize(policyholderId);
        
        Change_Request__c ConservationRequest = new Change_Request__c();
        ConservationRequest.Policyholder__c = policyholderId;
        ConservationRequest.RecordTypeId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Conservation').getRecordTypeId();
        ConservationRequest.Status__c = 'Pending';
        ConservationRequest.Request_Number__c = size;
        
        return ConservationRequest;
    }
    
    @AuraEnabled
    public static void SaveConservation(Change_Request__c cRequest)
    {
        upsert cRequest;
    }
    
    @AuraEnabled
    public static void SaveandSubmitConservation(Change_Request__c cRequest)
    {
        cRequest.Status__c = 'Submitted';
        cRequest.Date_of_Request__c = system.today();
        upsert cRequest;
    }
    
    // Static overloaded method to use from the Conservation Request Component
    public static Decimal getSize(Id policyholderId)
    {
        decimal s;
        
        AggregateResult[] aggs = [SELECT MAX(Request_Number__c) max FROM Change_Request__c WHERE Policyholder__c =: policyholderId];
        s = (Decimal)aggs[0].get('max');
        
        if(s != null)
            s = s += 1;
        else
            s = 1;
        
        return s;
    }
  
    public class cRecordType
    {
        public RecordType rt        {get;set;}
        public boolean selected     {get;set;}
        
        public cRecordType(RecordType r)
        {
            rt = r;
            selected = false;
        }
    }
    
    public class cProduct
    {
        public Purchased_Product__c PurchasedProduct    {get;set;}
        public boolean selected                         {get;set;}
        
        public cProduct(Purchased_Product__c p)
        {
            PurchasedProduct = p;
            selected = false;
        }
    }
}