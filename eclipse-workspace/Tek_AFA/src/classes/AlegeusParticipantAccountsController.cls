public with sharing class AlegeusParticipantAccountsController {
    @AuraEnabled
    public static EmployerInfo getEmployerInfo(Id accountId) {
        EmployerInfo info = new EmployerInfo();
        
        info.Employer = getAccountById(accountId);
        
        return info;
    }
    
    @AuraEnabled
    public static ParticipantAccountsInfo getParticipantAccountsInfo(String participantId, Id accountId, String planYear) {
        ParticipantAccountsInfo info = new ParticipantAccountsInfo();

        AlegeusService service = new AlegeusService();
        info.Context = service.getParticipantAccounts(accountId, participantId, planYear);
        info.buildPlanYearGroups();

        return info;
    }

    private static Account getAccountById(Id accountId) {
        return
        [SELECT Id,
                Name,
                Employer_Code__c,
                MCP_Number__c
           FROM Account
          WHERE Id = :accountId];
    }

    public class ParticipantAccountsInfo {
        @AuraEnabled
        public AlegeusService.ParticipantAccountsResponse Context { get; set; }
        
        @AuraEnabled
        public List<ParticipantAccountsGroup> PlanYearGroups { get; set; }
        
        public ParticipantAccountsInfo() {
            PlanYearGroups = new List<ParticipantAccountsGroup>();
        }
        
        public void buildPlanYearGroups() {
            Map<String, ParticipantAccountsGroup> planYearGroupsMap = new Map<String, ParticipantAccountsGroup>();
            
            for (AlegeusService.ParticipantAccount account : Context.Accounts) {
                ParticipantAccountsGroup planYearGroup = planYearGroupsMap.get(account.PlanYear);
                
                if (planYearGroup == null) {
                    planYearGroup = new ParticipantAccountsGroup();
                    planYearGroup.PlanYear = account.PlanYear;

                    planYearGroupsMap.put(account.PlanYear, planYearGroup);
                }

                planYearGroup.Accounts.add(account);
            }
            
            PlanYearGroups = planYearGroupsMap.values();
            PlanYearGroups.sort();
        }
    }
    
    public class ParticipantAccountsGroup implements Comparable {
        @AuraEnabled
        public String PlanYear { get; set; }
        
        @AuraEnabled
        public List<AlegeusService.ParticipantAccount> Accounts { get; set; }
        
        public ParticipantAccountsGroup() {
            Accounts = new List<AlegeusService.ParticipantAccount>();
        }

        public Integer compareTo(Object compareTo) {
            ParticipantAccountsGroup compareToGroup = (ParticipantAccountsGroup)compareTo;

            if (PlanYear == 'Current') {
                return -1;
            }

            if (compareToGroup.PlanYear == 'Current') {
                return 1;
            }

            return PlanYear.compareTo(compareToGroup.PlanYear);
        }
    }
    
    public class EmployerInfo {
        @AuraEnabled
        public Account Employer { get; set; }
    }
}