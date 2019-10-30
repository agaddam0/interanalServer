public class ReserviceSetupController {
    
    @AuraEnabled
    public static Enrollment_Form__c getCurrentEnrollmentForm(String opportunityId) {
        List<Enrollment_Form__c> currentEnrollmentForm = [SELECT Id, 
                                                          Enrollment_Opportunity__c, 
                                                          Enrollment_Opportunity__r.Account.Name, 
                                                          Enrollment_Opportunity__r.AccountId
                                                          FROM Enrollment_Form__c
                                                          WHERE Enrollment_Opportunity__c =: opportunityId
                                                          AND RecordType.Name = 'Master'
                                                          ORDER By CreatedDate DESC];
        
        if(currentEnrollmentForm.size() > 0)
            return currentEnrollmentForm[0];
        else
            return null;
    }
    
    @AuraEnabled
    public static void SaveObject(sObject objectData) 
    {
        update objectData;
    }
    
    @AuraEnabled
    public static String RequestEdit(String opportunityId)
    {
        String requestEditMessage = '';
        
        Platform_Setup__c platform = [SELECT Request_Edit__c, Status__c FROM Platform_Setup__c
                                      WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: opportunityId];
        
        if(platform.Status__c == 'Submitted')
        {
            platform.Status__c = 'In Progress';
        }
        else if(platform.Status__c != 'In Progress')
        {
            platform.Request_Edit__c = true;
            requestEditMessage = ' - Request To Edit Sent';
        }
        
        update platform;
        
        return requestEditMessage;
    }
    
    @AuraEnabled
    public static Boolean s125Check(String accountId) {
        Integer planDateCount = Database.countQuery('SELECT COUNT() FROM Plan_Date__c WHERE Account__c = :accountId');
        
        List<String> BenefitCodeList = new List<String>{'URM', 'DDC', 'LPF', 'HSA', 'HRA'};
        Integer eligibleCoverageCount = Database.countQuery('SELECT COUNT() FROM Eligible_Coverage__c WHERE planDateRecord__r.Account__c = :accountId AND BenefitCode__c IN :BenefitCodeList');
        
        if(eligibleCoverageCount < 1 && planDateCount > 0)
            return true;
        
        return false;
    }
    
    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId)
    {
        String soql = util.getCreatableFields('Opportunity');
        soql += ', Account.Name, Account.MCP_Number__c, Account.Owner.Name, Administrative_Contact__r.Name, Administrative_Contact__r.Phone';
        soql += ', Administrative_Contact__r.Email, Account.AFenroll_Pay_Groups__c';
        soql += ' FROM Opportunity';
        soql += ' WHERE Id = \'' + opportunityId + '\'';        
        List<Opportunity> enrollmentOpps = Database.query(soql);
        
        return enrollmentOpps[0];
    }
    
    public static Opportunity getLatestOpportunityFromAccount(String accountId)
    {
        String soql = util.getCreatableFields('Opportunity');
        soql += ', Account.Name, Account.MCP_Number__c, Owner.Name, Administrative_Contact__r.Name, Administrative_Contact__r.Phone';
        soql += ', Administrative_Contact__r.Email, Account.AFenroll_Pay_Groups__c';
        soql += ' FROM Opportunity';
        soql += ' WHERE AccountId = \'' + accountId + '\'';
		soql += ' ORDER BY LastModifiedDate DESC LIMIT 1';       
        List<Opportunity> enrollmentOpps = Database.query(soql);
        
        return enrollmentOpps[0];
    }
    
    @testVisible
    private static Platform_Setup__c getPlatformSetupForm(String opportunityId)
    {
        String soql = util.getCreatableFields('Platform_Setup__c');
        soql += ' FROM Platform_Setup__c';
        soql += ' WHERE Enrollment_Form__r.Enrollment_Opportunity__c = \'' + opportunityId + '\'';
        soql += ' AND RecordType.Name LIKE \'% Form\'';
        List<Platform_Setup__c> platformSetupForms = Database.query(soql);
        
        return platformSetupForms[0];
    }
    
    private static Enrollment_Form__c getEnrollmentForm(String opportunityId)
    {
        String soql = util.getCreatableFields('Enrollment_Form__c');
        soql += ' , Division__c';
        soql += ' FROM Enrollment_Form__c';
        soql += ' WHERE Enrollment_Opportunity__c = \'' + opportunityId + '\'';
        soql += ' AND RecordType.Name = \'Master\'';
        List<Enrollment_Form__c> enrollmentForms = Database.query(soql);
        
        return enrollmentForms[0];
    }
    
    private static Account getAccount(String accountId)
    {
        String soql = util.getCreatableFields('Account');
        soql += ' FROM Account';
        soql += ' WHERE Id = \'' + accountId + '\'';
        List<Account> accounts = Database.query(soql);
        
        return accounts[0];
    }
    
    @AuraEnabled
    public static Boolean checkSignificantChanges(String opportunityId) 
    {
        Opportunity o = [SELECT Significant_Setup_Changes__c FROM Opportunity WHERE Id=: opportunityId];
        
        return o.Significant_Setup_Changes__c;
    }
    
    @AuraEnabled
    public static SetupFormData getSetupFormData(String opportunityId) {
        
        Platform_Setup__c platformSetupForm = getPlatformSetupForm(opportunityId);
        
        Opportunity enrollmentOpp = getOpportunity(opportunityId);
        
        Enrollment_Form__c enrollmentForm = getEnrollmentForm(opportunityId);
        
        Account customerAccount = getAccount(enrollmentOpp.AccountId);
        
        return new SetupFormData(platformSetupForm, enrollmentOpp, enrollmentForm, customerAccount);
    }
    
    @AuraEnabled
    public static SetupFormData getSetupFormDataFromAccountId(String accountId)
    {
        Account customerAccount = getAccount(accountId);
        Opportunity enrollmentOpp = getLatestOpportunityFromAccount(accountId);
        Platform_Setup__c platformSetupForm = getPlatformSetupForm(enrollmentOpp.Id);
        Enrollment_Form__c enrollmentForm = getEnrollmentForm(enrollmentOpp.Id);
        
        return new SetupFormData(platformSetupForm, enrollmentOpp, enrollmentForm, customerAccount); 
    }
    
    @AuraEnabled
    public static void AddRemoveDVRProduct(Boolean addDVR, String enrollmentFormId)
    {
        Product_Catalog__c DVRcatalogEntry = new Product_Catalog__c();
        try
        {
            DVRcatalogEntry = [SELECT Id, Name, Product_Family__c, Type__c, Allowed_To_Be_Added_To_Enrollment__c 
                               FROM Product_Catalog__c 
                               WHERE Name = 'Dependent Verification Review'
                               AND Status__c = 'Active'];
            
            system.debug('### J1: ' + DVRcatalogEntry);
            
            List<Marketed_Product__c> DVRsInEnrollment = [SELECT Id 
                                                          FROM Marketed_Product__c 
                                                          WHERE Enrollment__c =: enrollmentFormId
                                                          AND Products__c =: DVRcatalogEntry.Id];
            
            system.debug('### J2: ' + DVRsInEnrollment);
            
            if(addDVR && DVRsInEnrollment.isEmpty())
            {
                Marketed_Product__c newDVRproduct = new Marketed_Product__c();
                newDVRproduct.Enrollment__c = enrollmentFormId;
                newDVRproduct.Products__c = DVRcatalogEntry.Id;
                
                insert newDVRproduct;
            }
            else
                delete DVRsInEnrollment;
        } 
        catch (QueryException e) 
        {
            system.debug('No Active DVR Catalog Entry');
        }
        catch (Exception e)
        {
            system.debug('Something went wrong: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<EnrollmentPath> getEnrollmentPaths(String division, String pathValue) {
        List<Enrollment_Path__c> enrollmentPaths =
            [SELECT Id,
             Name,
             Below_Minimum_Employee_Message__c,
             Below_Employee_Minimum_Reason_Required__c,
             Default_When_Less_Than_Employee_Minimum__c,
             Description__c,
             Employee_Minimum__c,
             Lead_Time__c,
             Level__c,
             Recommended__c,
             Recommended_Text__c,
             Status__c,
             Sub_Name__c,
             Summary__c,
             Platform_Setup_Field_Set__c
             FROM Enrollment_Path__c
             WHERE Division__c = :division
             AND Status__c = 'Active'
             ORDER BY Display_Order__c];
        
        List<EnrollmentPath> enrollmentPathList = new List<EnrollmentPath>();
        
        for(Enrollment_Path__c path : enrollmentPaths) {
            enrollmentPathList.add(new EnrollmentPath(path, pathValue));
        }
        
        return enrollmentPathList;
    }
    
    @AuraEnabled
    public static List<Product_Catalog__c> getCatalogForIndividualProductsVersion2(String enrollmentFormId, String division)
    {
        List<Product_Catalog__c> products = [Select Id, Tax_Treatment__c, Plan_Status__c, Name, aor__c,Carrier__c,Product_Description__c, Is_Tax_Treatment_Editable__c, Product_Family__c, Employer_Benefits_Site_Eligible__c, Rider__c
                                             from Product_Catalog__c
                                             where Status__c = 'Active' and (Division_Availability__c = 'Both' or Division_Availability__c = :division)
                                             and Chassis__c = 'Individual'
                                             and Id not in (select products__c from Marketed_Product__c where Enrollment__c = :enrollmentFormId)
                                             and Allowed_To_Be_Added_To_Enrollment__c = true
                                             order by order__c];
        
        return products;
    }
    
    @AuraEnabled
    public static List<Product_Catalog__c> getCatalogForImportProductsVersion2(String enrollmentFormId, String division)
    {
        List<Product_Catalog__c> products = [Select Id, Tax_Treatment__c, Plan_Status__c, Name, aor__c,Carrier__c,Product_Description__c, Is_Tax_Treatment_Editable__c, Product_Family__c, Employer_Benefits_Site_Eligible__c, Rider__c
                                             from Product_Catalog__c
                                             where Status__c = 'Active' and (Division_Availability__c = 'Both' or Division_Availability__c = :division)
                                             and Type__c = 'Import'
                                             and Id not in (select products__c from Marketed_Product__c where Enrollment__c = :enrollmentFormId)
                                             and Allowed_To_Be_Added_To_Enrollment__c = true
                                             order by order__c];
        
        return products;
    }
    
    @AuraEnabled
    public static List<Marketed_Product__c> retrieveImportProductsVersion2(String enrollmentFormId)
    {
        List<Marketed_Product__c> products = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                                              products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                                              Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                                              products__r.Employer_Benefits_Site_Eligible__c
                                              From Marketed_Product__c 
                                              WHERE enrollment__c = :enrollmentFormId AND products__r.Type__c = 'Import'
                                              AND products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                                              AND Plan_Status__c = 'New'
                                              order by products__r.Order__c];
        
        return products;
    }
    
    @AuraEnabled
    public static List<Marketed_Product__c> retrieveIndividualProductsVersion2(String enrollmentFormId)
    {
        List<Marketed_Product__c> products = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                                              products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                                              Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                                              products__r.Employer_Benefits_Site_Eligible__c
                                              From Marketed_Product__c 
                                              where enrollment__c = :enrollmentFormId and products__r.Chassis__c = 'Individual'
                                              and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                                              AND Plan_Status__c = 'New'
                                              order by products__r.Order__c];
        
        return products;
    }
    
    @AuraEnabled
    public static List<Marketed_Product__c> insertImportProductsVersion2(string enrollmentFormId, List<Product_Catalog__c> products)
    {
        List<Marketed_Product__c> productsToInsert = new List<Marketed_Product__c>();
        
        for(Product_Catalog__c item : products)
        {
            Marketed_Product__c newProduct = new Marketed_Product__c();
            newProduct.Enrollment__c = enrollmentFormId;
            newProduct.Products__c = item.Id;
            newProduct.Tax_Treatment__c = item.Tax_Treatment__c;
            newProduct.Plan_Status__c = item.Plan_Status__c;
            newProduct.Include_on_Employer_Benefits_Site__c = item.Employer_Benefits_Site_Eligible__c == true;
            newProduct.AOR__c = item.AOR__c;
            newProduct.Carrier__c = item.Carrier__c;
            newProduct.Product_Description__c = item.Product_Description__c;
            productsToInsert.add(newProduct);
        }
        
        if(productsToInsert.size() > 0)
        {
            insert productsToInsert;
        }
        
        return retrieveImportProductsVersion2(enrollmentFormId);
    }
    
    @AuraEnabled
    public static List<Marketed_Product__c> removeImportProductVersion2(String productId, String enrollmentFormId)
    {
        Marketed_Product__c product = [SELECT Id FROM Marketed_Product__c WHERE Id =: productId];
        
        delete product;
        
        return retrieveImportProductsVersion2(enrollmentFormId);
    }
    
    @AuraEnabled
    public static List<Marketed_Product__c> insertIndividualProductsVersion2(string enrollmentFormId, List<Product_Catalog__c> products)
    {
        List<Marketed_Product__c> productsToInsert = new List<Marketed_Product__c>();
        
        for(Product_Catalog__c item : products)
        {
            Marketed_Product__c newProduct = new Marketed_Product__c();
            newProduct.Enrollment__c = enrollmentFormId;
            newProduct.Products__c = item.Id;
            newProduct.Tax_Treatment__c = item.Tax_Treatment__c;
            newProduct.Plan_Status__c = item.Plan_Status__c;
            newProduct.Include_on_Employer_Benefits_Site__c = item.Employer_Benefits_Site_Eligible__c == true;
            productsToInsert.add(newProduct);
        }
        
        if(productsToInsert.size() > 0)
        {
            insert productsToInsert;
        }
        
        return retrieveIndividualProductsVersion2(enrollmentFormId);
    }
    
    @AuraEnabled
    public static List<Marketed_Product__c> removeIndividualProductVersion2(String productId, String enrollmentFormId)
    {
        Marketed_Product__c product = [SELECT Id FROM Marketed_Product__c WHERE Id =: productId];
        
        delete product;
        
        return retrieveIndividualProductsVersion2(enrollmentFormId);
    }

    @AuraEnabled
    public static void upsertCoreBenefitForm(Core_Benefit_Form__c benefitForm)
    {
        upsert benefitForm;
    }

    @AuraEnabled
    public static void deleteCoreBenefitForm(String benefitFormId)
    {
        Core_Benefit_Form__c benefitToDelete = [SELECT Id FROM Core_Benefit_Form__c WHERE Id =: benefitFormId];

        delete benefitToDelete;
    }
    
    @AuraEnabled
    public static void submitReserviceForm(String opportunityId)
    {
        Enrollment_Form__c enrollmentForm = new Enrollment_Form__c();
        
        String soql = util.getCreatableFields('Enrollment_Form__c');
        soql += ' , Division__c';
        soql += ' FROM Enrollment_Form__c';
        soql += ' WHERE Enrollment_Opportunity__c = \'' + opportunityId + '\'';
        soql += ' AND RecordType.Name = \'Master\'';
        List<Enrollment_Form__c> enrollmentForms = Database.query(soql);
        
        if(!enrollmentForms.isEmpty())
        {
            enrollmentForm = enrollmentForms[0];
            enrollmentForm.Status__c = 'Confirmed';
            update enrollmentForm;
        }
        
        Platform_Setup__c platformSetup = new Platform_Setup__C();
        
        soql = util.getCreatableFields('Platform_Setup__c');
        soql += ' FROM Platform_Setup__c';
        soql += ' WHERE Enrollment_Form__r.Enrollment_Opportunity__c = \'' + opportunityId + '\'';
        soql += ' AND RecordType.Name LIKE \'% Form\'';
        List<Platform_Setup__c> platformSetupForms = Database.query(soql);
        
        if(!platformSetupForms.isEmpty())
        {
            platformSetup = platformSetupForms[0];
            platformSetup.Status__c = 'Submitted';
            update platformSetup;
        }
            
    }
    
    @AuraEnabled
    public static String getPreEnrollmentMarketingFormId(String opportunityId)
    {
        if(HasPreenrollmentSetupFormAccess)
        {
            List<Pre_Enrollment_Marketing_Form__c> preEnrollmentMarketingForm = [SELECT Id FROM Pre_Enrollment_Marketing_Form__c 
                                                                                 WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: opportunityId];
            
            if(!preEnrollmentMarketingForm.isEmpty())
                return preEnrollmentMarketingForm[0].Id;
        }
        
        return null;
    }
    
    private static Boolean hasPreenrollmentSetupFormAccessPriv = null;
    public static Boolean HasPreenrollmentSetupFormAccess {
        get {
            if (hasPreenrollmentSetupFormAccessPriv == null) {
                SetupEntityAccess[] preenrollmentAccessSettings =
                    [SELECT Id
                     FROM SetupEntityAccess
                     WHERE SetupEntityId IN (SELECT Id
                                             FROM ApexPage
                                             WHERE NamespacePrefix = '' AND Name = 'PreenrollmentMarketingSetupForm')
                     AND ParentId IN (SELECT PermissionSetId
                                      FROM PermissionSetAssignment
                                      WHERE AssigneeId = :UserInfo.getUserId())
                     LIMIT 1];
                
                hasPreenrollmentSetupFormAccessPriv = preenrollmentAccessSettings.size() > 0;
            }
            
            return hasPreenrollmentSetupFormAccessPriv;
        }
    }
    
    public class SetupFormData {
        @AuraEnabled
        public Platform_Setup__c PlatformSetupForm {get; set;}
        
        @AuraEnabled
        public Opportunity EnrollmentOpportunity {get; set;}
        
        @AuraEnabled
        public Enrollment_Form__c EnrollmentForm {get; set;}
        
        @AuraEnabled
        public Account CustomerAccount {get; set;}
        
        public SetupFormData(Platform_Setup__c platform, Opportunity opp, Enrollment_Form__c eForm, Account account){
            PlatformSetupForm = platform;
            EnrollmentOpportunity = opp;
            EnrollmentForm = eForm;
            CustomerAccount = account;
        }
    }
    
    public class EnrollmentPath {
        @AuraEnabled
        public Enrollment_Path__c EnrollmentPath {get; set;}
        
        @AuraEnabled
        public Boolean Selected {get; set;}
        
        public EnrollmentPath(Enrollment_Path__c path, String pathValue){
            EnrollmentPath = path;
            
            if(path.Id == pathValue)
                Selected = true;
        }
    }
}