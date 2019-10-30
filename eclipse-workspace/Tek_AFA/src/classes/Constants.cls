public class Constants {
    
    /**********************************************************
     * This class is to make use of commonly queried or 
     * used variables throughout the code base without contant 
     * querying in every class.
     * 
     * Make use of static variables that will live through the 
     * execution context.  So if a variable is not set upon use,
     * set it and it will remain available until the end of the
     * execution context. 
     * 
     * Thank you for your cooperation:
     * Jessica Riffe
     ***********************************************************/
    
    // Account Record Types
    public static final ID ACCOUNT_CUSTOMER_ACCOUNT;
    public static final ID ACCOUNT_PROSPECT;
    public static final ID ACCOUNT_ASSOCIATION;
    
    // Opportunity Record Types
    // Enrollment Opportunity
    public static final ID OPPORTUNITY_AWD_ENROLLMENT;
    public static final ID OPPORTUNITY_AFES_ENROLLMENT;
    
    // New Group Opportunity
    public static final ID OPPORTUNITY_NEW_GROUP;
    public static final ID OPPORTUNITY_AWD_NEW_GROUP;
    public static final ID OPPORTUNITY_AFES_NEW_GROUP;
    
    // AFAS Opportunity
    public static final ID OPPORTUNITY_AFAS;
    
    // Enrollment Forms
    public static final ID ENROLLMENT_FORM_MASTER;
    
    // Asset Record Types
    public static final ID ASSET_HCR_SERVICES;
    public static final ID ASSET_EXPENSE_MANAGEMENT_SERVICES;
    
    public static final ID COLLEAGUE_COLLEAGUE;
    public static final ID COLLEAGUE_TEAM_OR_DISTRICT;
    
    public static final ID PLATFORM_SETUP_AFES_FORM;
    public static final ID PLATFORM_SETUP_AWD_FORM;
    public static final ID PLATFORM_SETUP_DVR;
    public static final ID PLATFORM_SETUP_RETURN_DATA_FILE; 
    
    public static final ID STANDING_PRT;
    public static final ID STANDING_CONVENTION;
    
    public static final ID BILL_MODES_PRODUCT_BILLING;
    public static final ID BILL_MODES_FLEX_BILLING;

    public static final ID SIGNATURE_SERVICE_EXCHANGE_AGREEMENT;
    
    public static final ID PROPOSAL_GENERIC;

    static {
        ACCOUNT_CUSTOMER_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    }
    
    static {
        ACCOUNT_PROSPECT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
    }
    
    static {
        ACCOUNT_ASSOCIATION = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Association').getRecordTypeId();
    }
    
    static {
        OPPORTUNITY_AWD_ENROLLMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AWD Enrollment').getRecordTypeId();
    }
    
    static {
        OPPORTUNITY_AFES_ENROLLMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AFES Enrollment').getRecordTypeId();
    }
    
    static {
        OPPORTUNITY_NEW_GROUP = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Group').getRecordTypeId();
    }
    
    static {
        OPPORTUNITY_AWD_NEW_GROUP = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AWD New Group').getRecordTypeId();
    }
    
    static {
        OPPORTUNITY_AFES_NEW_GROUP = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AFES New Group').getRecordTypeId();
    }
    
    static {
        OPPORTUNITY_AFAS = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AFAS Opportunity').getRecordTypeId();
    }
    
    static {
        ENROLLMENT_FORM_MASTER = Schema.SObjectType.Enrollment_Form__c.getRecordTypeInfosByName().get('Master').getRecordTypeId();
    }
    
    static {
        ASSET_HCR_SERVICES = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('HCR Services').getRecordTypeId();
    }
    
    static {
        ASSET_EXPENSE_MANAGEMENT_SERVICES = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Expense Management Services').getRecordTypeId();
    }
    
    static {
        COLLEAGUE_COLLEAGUE = Schema.SObjectType.Colleague__c.getRecordTypeInfosByName().get('Colleague').getRecordTypeId();
    }
    
    static {
        COLLEAGUE_TEAM_OR_DISTRICT = Schema.SObjectType.Colleague__c.getRecordTYpeInfosByName().get('Team/District').getRecordTYpeId();
    }
    
    static {
        PLATFORM_SETUP_AFES_FORM = Schema.SObjectType.Platform_Setup__c.getRecordTypeInfosByName().get('AFES Form').getRecordTypeId();
    }
    
    static {
        PLATFORM_SETUP_AWD_FORM = Schema.SObjectType.Platform_Setup__c.getRecordTypeInfosByName().get('AWD Form').getRecordTypeId();
    }
    
    static {
        PLATFORM_SETUP_DVR = Schema.SObjectType.Platform_Setup__c.getRecordTypeInfosByName().get('DVR').getRecordTypeId();
    }
    
    static {
        PLATFORM_SETUP_RETURN_DATA_FILE = Schema.SObjectType.Platform_Setup__c.getRecordTypeInfosByName().get('Return Data File').getRecordTypeId(); 
    }
    
    static {
        STANDING_PRT = Schema.SObjectType.Standing__c.getRecordTypeInfosByName().get('PRT Standing').getRecordTypeId();
    }
    
    static {
        STANDING_CONVENTION = Schema.SObjectType.Standing__c.getRecordTypeInfosByName().get('Convention Standing').getRecordTypeId();
    }
    
    static {
        BILL_MODES_PRODUCT_BILLING = Schema.SObjectType.Bill_Mode__c.getRecordTypeInfosByName().get('Product Billing').getRecordTypeId();
        BILL_MODES_FLEX_BILLING = Schema.SObjectType.Bill_Mode__c.getRecordTypeInfosByName().get('Flex Billing').getRecordTypeId();
    }
    
    static {
        SIGNATURE_SERVICE_EXCHANGE_AGREEMENT = schema.SObjectType.Enrollment_Form__c.getRecordTypeInfosByName().get('Service Exchange Agreement').getRecordTypeId();
    }
    
    static {
        PROPOSAL_GENERIC = schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('Generic Proposal').getRecordTypeId();
    }
}