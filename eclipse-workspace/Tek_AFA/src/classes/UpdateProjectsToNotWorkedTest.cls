@isTest
public with sharing class UpdateProjectsToNotWorkedTest {
    
    private static void runUpdateProjectsToNotWorked() {
        Test.startTest();
        Database.executeBatch(new UpdateProjectsToNotWorked());
        Test.stopTest();
    }
    
    private static Project__c getProjectById(Id projectId) {
        return
        [SELECT Id,
                Name,
                Status__c
           FROM Project__c
          WHERE Id = :projectId];
    }
    
    private static void assertProjectStatusIsNotWorked(Id projectId) {
        Project__c project = getProjectById(projectId);
        
        system.assertEquals('Not Worked', project.Status__c, 'The project status was not updated to "Not Worked".');
    }
    
    private static void assertProjectStatusIsNew(Id projectId) {
        Project__c project = getProjectById(projectId);
        
        system.assertEquals('New', project.Status__c, 'The project status is not "New".');
    }
    
    @isTest
    static void updateProjects_noProjectsToUpdate_expectNoErrorsTest() {
        runUpdateProjectsToNotWorked();
    }
    
    @isTest
    static void updateProjects_oneProjectUntouchedAndEffectiveDateofAFAProductsIs31DaysInPast_expectStatusToNotWorkedTest() {
        Opportunity opp = OpportunityTestData.Instance.withEffectiveDateOfAFAProducts(Date.Today().addDays(-31))
                                                      .insertAFESOpportunity();

        Project__c untouchedProject = ProjectTestData.Instance.withOpportunity(opp.Id)
                                                              .withStatus('New')
                                                              .insertProject();

        runUpdateProjectsToNotWorked();
        
        assertProjectStatusIsNotWorked(untouchedProject.Id);
    }
    
    @isTest
    static void updateProjects_oneProjectUntouchedAndEffectiveDateofAFAProductsIsNotToday_expectStatusRemainsNewTest() {
        Date effectiveDateIsNotToday = Date.Today().addDays(1);
        
        Opportunity opp = OpportunityTestData.Instance.withEffectiveDateOfAFAProducts(effectiveDateIsNotToday)
                                                      .insertAFESOpportunity();

        Project__c untouchedProject = ProjectTestData.Instance.withOpportunity(opp.Id)
                                                              .withStatus('New')
                                                              .insertProject();

        runUpdateProjectsToNotWorked();
        
        assertProjectStatusIsNew(untouchedProject.Id);
    }
    
    @isTest
    static void updateProjects_oneProjectUntouchedAndNoOpportunity_expectStatusRemainsNewTest() {
        Project__c untouchedProject = ProjectTestData.Instance.withStatus('New')
                                                              .insertProject();

        runUpdateProjectsToNotWorked();
        
        assertProjectStatusIsNew(untouchedProject.Id);
    }
}