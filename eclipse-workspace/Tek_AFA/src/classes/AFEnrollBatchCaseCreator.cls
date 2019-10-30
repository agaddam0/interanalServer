global with sharing class AFEnrollBatchCaseCreator implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    global void execute(SchedulableContext SC) {
        AFEnroll_Settings__c afEnrollSettings = AFEnroll_Settings__c.getInstance();
        
        Integer batchSize = afEnrollSettings != null && afEnrollSettings.Create_Case_Batch_Size__c != null
                            ? (Integer) afEnrollSettings.Create_Case_Batch_Size__c : 99;

        Database.executeBatch(new AFEnrollBatchCaseCreator(), batchSize);
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        String afEnrollPlatformSetupRecordsQuery =
        'SELECT Id, ' +
               'Name, ' + 
               'Enrollment_Form__r.Enrollment_Opportunity__r.Id, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Account.Name, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Account.MCP_Number__c, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Additional_MCPs__c, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Path__c, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Path__r.Name, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Effective_Date_of_AFA_Products__c, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_End_Date__c, ' +
               'Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Agent_ID__c, ' +
               'S125OtherSvcPlanStartDate__c, ' +
               'S125OtherSvcPlanEndDate__c, ' +
               'Owner.Name ' +
        '  FROM Platform_Setup__c' +
        ' WHERE Create_AFEnroll_Case__c = true';
        
        return Database.getQueryLocator(afEnrollPlatformSetupRecordsQuery);
    }

    global void execute(Database.BatchableContext bc, List<Platform_Setup__c> platformSetupRecords) {
        AFEnrollService service = new AFEnrollService();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        service.InsertLogsWhenComplete = false;

        for (Platform_Setup__c ps : platformSetupRecords) {
            AFEnrollService.SaveEnrollmentCaseRequest caseRequest = buildSaveEnrollmentCaseRequest(ps);
            AFEnrollService.SaveEnrollmentCaseResponse caseResponse = service.saveEnrollmentCase(caseRequest);

            if (caseResponse.Success) {
                ps.Enrollment_Form__r.Enrollment_Opportunity__r.AFEnroll_Case_Id__c = caseResponse.AFEnrollCaseId;
            }
            else {
                ps.Enrollment_Form__r.Enrollment_Opportunity__r.AFEnroll_Case_Error__c = caseResponse.Message;
            }

            oppsToUpdate.add(ps.Enrollment_Form__r.Enrollment_Opportunity__r);
        }

        update oppsToUpdate;

        IntegrationLogger.Instance.insertLogs();
    }
    
    global void finish(Database.BatchableContext bc) { }
    
    private AFEnrollService.SaveEnrollmentCaseRequest buildSaveEnrollmentCaseRequest(Platform_Setup__c ps) {
        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.DedupeAdditionalMCPs = true;
        
        Opportunity enrollmentOpp = ps.Enrollment_Form__r.Enrollment_Opportunity__r;
        Account acct = enrollmentOpp.Account;

        request.MCPNumber = acct.MCP_Number__c;
        request.AdditionalMCPsCommaSeparated = enrollmentOpp.Additional_MCPs__c;
        request.AccountName = acct.Name;
        
        if (enrollmentOpp.Enrollment_Path__c != null) {
            request.EnrollmentPath = enrollmentOpp.Enrollment_Path__r.Name;
        }
        
        request.EffectiveDateOfAFAProducts = enrollmentOpp.Effective_Date_of_AFA_Products__c;
        request.EnrollmentStartDate = enrollmentOpp.Enrollment_Start_Date__c;
        request.EnrollmentEndDate = enrollmentOpp.Enrollment_End_Date__c;
        request.AgentId = enrollmentOpp.Assigned_Account_Manager__r.Agent_ID__c;
        request.PlatformOwnerName = ps.Owner.Name;
        request.PlanStartDate = ps.S125OtherSvcPlanStartDate__c;
        request.PlanEndDate = ps.S125OtherSvcPlanEndDate__c;
        
        return request;
    }
}