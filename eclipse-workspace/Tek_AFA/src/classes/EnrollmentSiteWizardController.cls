public with sharing class EnrollmentSiteWizardController {
    @AuraEnabled
    public static AccountEnrollmentSitesInfo getAccountEnrollmentSitesInfo(String accountId, String opportunityId) {
        AccountEnrollmentSitesInfo info = new AccountEnrollmentSitesInfo();
        info.EnrollmentSites =
        [SELECT Id,
                Name,
                Physical_Street_Address__c,
                Physical_City__c,
                Physical_State__c,
                Physical_Zip__c,
                (SELECT Id,
                        Name,
                        Start_Date__c,
                        End_Date__c,
                        Start_Time__c,
                        End_Time__c,
                        Show_In_Build_Time_To_Enroll_Email__c
                   FROM Enrollment_Site_Dates__r
                  WHERE Enrollment_Opportunity__c = :opportunityId)
           FROM Enrollment_Site__c
          WHERE Account__c = :accountId
         ORDER BY Name];

        info.Account =
        [SELECT Id,
                Name
           FROM Account
          WHERE Id = :accountId];
        
        return info;
    }

    @AuraEnabled
    public static Id addNewEnrollmentSite(Enrollment_Site__c newEnrollmentSite) {
        insert newEnrollmentSite;
        
        return newEnrollmentSite.Id;
    }

    @AuraEnabled
    public static void updateEnrollmentSite(Enrollment_Site__c enrollmentSiteToUpdate) {
        update enrollmentSiteToUpdate;
    }
    
    @AuraEnabled
    public static Id addNewEnrollmentSiteDate(Enrollment_Site_Date__c newEnrollmentSiteDate) {
        insert newEnrollmentSiteDate;
        
        return newEnrollmentSiteDate.Id;
    }

    @AuraEnabled
    public static void updateEnrollmentSiteDate(Enrollment_Site_Date__c updatedEnrollmentSiteDate) {
        update updatedEnrollmentSiteDate;
    }
    
    @AuraEnabled
    public static void deleteEnrollmentSiteDate(Id enrollmentSiteIdToDelete) {
        delete new Enrollment_Site_Date__c(Id = enrollmentSiteIdToDelete);
    }

    public class AccountEnrollmentSitesInfo {
        @AuraEnabled
        public Account Account { get; set; }

        @AuraEnabled
        public List<Enrollment_Site__c> EnrollmentSites { get; set; }
    }
}