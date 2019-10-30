@isTest
public with sharing class ProjectBoardControllerTest {
    static Project__c DefaultProject = null;
    
    static void assertEmptyProjectBoard(ProjectBoardController.ProjectBoard pb) {
        system.assert(pb != null, 'The project board is null.');
        system.assert(pb.RecentlyViewedProjects != null, 'The recently viewed projects is null.');
        system.assertEquals(0, pb.RecentlyViewedProjects.size(), 'The recently viewed projects should be empty.');

        system.assert(pb.MyPinnedProjects != null, 'The my pinned projects is null.');
        system.assertEquals(0, pb.MyPinnedProjects.size(), 'The my pinned projects should be empty.');
    }
    
    static void assertNoProjects(List<ProjectBoardController.Project> projects) {
        system.assert(projects != null, 'The projects are null.');
        system.assertEquals(0, projects.size(), 'The projects should be empty.');
    }
    
    static void assertProjectsHasOnlyDefaultProject(List<ProjectBoardController.Project> projects) {
        system.assert(projects != null, 'Projects is null.');
        system.assertEquals(1, projects.size(), 'There should be one project.');
        
        if (DefaultProject == null) {
            loadSetupData();
        }
        
        system.assertEquals(DefaultProject.Id, projects[0].Record.Id, 'The default project was not returned.');
    }
    
    static void assertEmptySearchResult(ProjectBoardController.SearchResult result) {
        system.assert(result != null, 'The search result is null.');
        
        assertNoProjects(result.Projects);
        
        system.assert(result.Accounts != null, 'The accounts list is null.');
        system.assertEquals(0, result.Accounts.size(), 'There should be no accounts.');
    }
    
    static void loadSetupData() {
        DefaultProject = getProject();
    }
    
    static Project__c getProject() {
        return
        [SELECT Id,
                Name,
                Description__c,
                Opportunity__c,
                Project_Template__c,
                Task_Display_Field_Set__c,
                Task_Edit_Field_Set__c,
                Percent_Complete__c,
                Completed_Tasks_Count__c,
                Task_Count__c,
                OwnerId,
                (SELECT Id,
                        Name
                   FROM Tasks__r)
           FROM Project__c
          FOR VIEW];
    }
    
    static void deleteDefaultProject() {
        loadSetupData();
        delete DefaultProject;
    }
    
    @testSetup
    static void setup() {
        DefaultProject = ProjectTestData.Instance.insertProject();
    }

    @isTest
    static void getProjectBoard_noProjects_expectEmptyProjectBoardTest() {
        deleteDefaultProject();
        
        ProjectBoardController.ProjectBoard pb = ProjectBoardController.getProjectBoard();
        
        assertEmptyProjectBoard(pb);
    }
    
    @isTest
    static void getAllOpenProjects_oneOpenProject_expectOpenProjectReturnedTest() {
        loadSetupData();
        List<ProjectBoardController.Project> openProjects = ProjectBoardController.getAllOpenProjects();
        
        system.assert(openProjects != null, 'The open projects is null.');
        system.assertEquals(1, openProjects.size(), 'There should be one open project.');
        system.assertEquals(DefaultProject.Id, openProjects[0].Record.Id, 'The expected open project was not returned.');
    }
    
    @isTest
    static void getAllOpenProjects_oneInProgressProjectWithNoTasks_expectOpenProjectReturnedTest() {
        loadSetupData();
        if (DefaultProject.Tasks__r.size() > 0) {
            delete DefaultProject.Tasks__r;
        }
        
        DefaultProject.Status__c = ProjectBoardController.PROJECT_STATUS_IN_PROGRESS;
        update DefaultProject;
        
        List<ProjectBoardController.Project> openProjects = ProjectBoardController.getAllOpenProjects();
        
        system.assert(openProjects != null, 'The open projects is null.');
        system.assertEquals(1, openProjects.size(), 'There should be one open project.');
        system.assertEquals(DefaultProject.Id, openProjects[0].Record.Id, 'The expected open project was not returned.');
    }
    
    @isTest
    static void getAllOpenProjects_oneNewProjectWithAllCompletedTasks_expectNoProjectsReturnedTest() {
        loadSetupData();
        if (DefaultProject.Tasks__r.size() > 0) {
            delete DefaultProject.Tasks__r;
        }
        
        Task_Status__c completeTaskStatus = TaskStatusTestData.Instance.withName('Complete')
                                                          .withOrder(2)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(true)
                                                          .insertTaskStatus();

        Task__c myCompleteTask = TaskTestData.Instance.withProject(DefaultProject.Id)
                                                      .withStatus(completeTaskStatus.Id)
                                                      .withComplete(true)
                                                      .insertTask();
        
        
        DefaultProject.Status__c = ProjectBoardController.PROJECT_STATUS_NEW;
        update DefaultProject;
        
        List<ProjectBoardController.Project> openProjects = ProjectBoardController.getAllOpenProjects();
        
        assertNoProjects(openProjects);
    }
    
    @isTest
    static void getAllOpenProjects_oneInProgressProjectWithAllCompletedTasks_expectOpenProjectReturnedTest() {
        loadSetupData();
        if (DefaultProject.Tasks__r.size() > 0) {
            delete DefaultProject.Tasks__r;
        }
        
        Task_Status__c completeTaskStatus = TaskStatusTestData.Instance.withName('Complete')
                                                          .withOrder(2)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(true)
                                                          .insertTaskStatus();

        Task__c myCompleteTask = TaskTestData.Instance.withProject(DefaultProject.Id)
                                                      .withStatus(completeTaskStatus.Id)
                                                      .withComplete(true)
                                                      .insertTask();
        
        
        DefaultProject.Status__c = ProjectBoardController.PROJECT_STATUS_IN_PROGRESS;
        update DefaultProject;
        
        List<ProjectBoardController.Project> openProjects = ProjectBoardController.getAllOpenProjects();
        
        system.assert(openProjects != null, 'The open projects is null.');
        system.assertEquals(1, openProjects.size(), 'There should be one open project.');
        system.assertEquals(DefaultProject.Id, openProjects[0].Record.Id, 'The expected open project was not returned.');
    }
    
    @isTest
    static void getMyOpenProjects_projectHasNoTasks_expectNoProjectsReturnedTest() {
        List<ProjectBoardController.Project> myOpenProjects = ProjectBoardController.getMyOpenProjects();
        
        assertNoProjects(myOpenProjects);
    }
    
    @isTest
    static void getMyOpenProjects_projectHasOneOpenTaskAssignedToMe_expectProjectReturnedTest() {
        loadSetupData();
        Task_Status__c InProgressTaskStatus = TaskStatusTestData.Instance.withName('In Progress')
                                                          .withOrder(2)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(false)
                                                          .insertTaskStatus();

        Task__c myOpenTask = TaskTestData.Instance.withProject(DefaultProject.Id)
                                                  .withStatus(InProgressTaskStatus.Id)
                                                  .insertTask();

        List<ProjectBoardController.Project> myOpenProjects = ProjectBoardController.getMyOpenProjects();
        
        assertProjectsHasOnlyDefaultProject(myOpenProjects);
    }
    
    @isTest
    static void getMyOpenProjects_projectInProgressAndOwnedByMeWithAllCompletedTasks_expectProjectReturnedTest() {
        loadSetupData();
        Task_Status__c completeTaskStatus = TaskStatusTestData.Instance.withName('Complete')
                                                          .withOrder(2)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(true)
                                                          .insertTaskStatus();

        Task__c myCompleteTask = TaskTestData.Instance.withProject(DefaultProject.Id)
                                                      .withStatus(completeTaskStatus.Id)
                                                      .withComplete(true)
                                                      .insertTask();
        
        
        DefaultProject.Status__c = ProjectBoardController.PROJECT_STATUS_IN_PROGRESS;
        DefaultProject.OwnerId = UserInfo.getUserId();
        update DefaultProject;

        List<ProjectBoardController.Project> myOpenProjects = ProjectBoardController.getMyOpenProjects();
        
        assertProjectsHasOnlyDefaultProject(myOpenProjects);
    }

    @isTest
    static void getMyAssignedProjects_noProjectsAssignedToMe_expectNoProjectsReturnedTest() {
        loadSetupData();
        
        Id currentUserId = UserInfo.getUserId();
        
        User otherAdmin =
        [SELECT Id,
                Name
           FROM User
          WHERE Profile.Name = 'System Administrator'
            AND IsActive = True
            AND Id != :currentUserId
         LIMIT 1];
         
        DefaultProject.OwnerId = otherAdmin.Id;
        update DefaultProject;
        
        system.assert(DefaultProject.OwnerId != UserInfo.getUserId(), 'The default project is assigned to me.');

        List<ProjectBoardController.Project> myAssignedProjects = ProjectBoardController.getMyAssignedProjects();

        assertNoProjects(myAssignedProjects);
    }

    @isTest
    static void getMyAssignedProjects_oneProjectAssignedToMe_expectOneProjectReturnedTest() {
        loadSetupData();

        List<ProjectBoardController.Project> myAssignedProjects = ProjectBoardController.getMyAssignedProjects();

        assertProjectsHasOnlyDefaultProject(myAssignedProjects);
    }
    
    @isTest
    static void getMyOpenProjects_projectInNewStatusAndOwnedByMeWithAllCompletedTasks_expectNoProjectsReturnedTest() {
        loadSetupData();
        Task_Status__c completeTaskStatus = TaskStatusTestData.Instance.withName('Complete')
                                                          .withOrder(2)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(true)
                                                          .insertTaskStatus();

        Task__c myCompleteTask = TaskTestData.Instance.withProject(DefaultProject.Id)
                                                      .withStatus(completeTaskStatus.Id)
                                                      .withComplete(true)
                                                      .insertTask();
        
        
        DefaultProject.Status__c = ProjectBoardController.PROJECT_STATUS_NEW;
        DefaultProject.OwnerId = UserInfo.getUserId();
        update DefaultProject;

        List<ProjectBoardController.Project> myOpenProjects = ProjectBoardController.getMyOpenProjects();
        
        assertNoProjects(myOpenProjects);
    }
    
    @isTest
    static void toggleProjectPinnedness_pinProject_expectProjectToBePinnedTest() {
        loadSetupData();
        
        List<ProjectBoardController.Project> myPinnedProjects = ProjectBoardController.getMyPinnedProjects();
        
        assertNoProjects(myPinnedProjects);
        
        ProjectBoardController.toggleProjectPinnedness(DefaultProject.Id);
        
        myPinnedProjects = ProjectBoardController.getMyPinnedProjects();
        
        assertProjectsHasOnlyDefaultProject(myPinnedProjects);
    }
    
    @isTest
    static void toggleProjectPinnedness_unpinProject_expectProjectToBeUnPinnedTest() {
        loadSetupData();
        
        // Pin Project
        ProjectBoardController.toggleProjectPinnedness(DefaultProject.Id);
        
        List<ProjectBoardController.Project> myPinnedProjects = ProjectBoardController.getMyPinnedProjects();
        
        assertProjectsHasOnlyDefaultProject(myPinnedProjects);
        
        // Unpin Project
        ProjectBoardController.toggleProjectPinnedness(DefaultProject.Id);
        
        myPinnedProjects = ProjectBoardController.getMyPinnedProjects();
        assertNoProjects(myPinnedProjects);
    }
    
    @isTest
    static void searchForRecords_emptySearchText_expectEmptySearchResultTest() {
        String emptySearchString = '';
        
        ProjectBoardController.SearchResult result = ProjectBoardController.searchForRecords(emptySearchString);
        
        assertEmptySearchResult(result);
    }

    @isTest
    static void searchForRecords_exactProjectName_expectDefaultProjectReturnedTest() {
        loadSetupData();
        
        ProjectBoardController.SearchResult result = ProjectBoardController.searchForRecords(DefaultProject.Name);
        
        assertProjectsHasOnlyDefaultProject(result.Projects);
    }
    
    @isTest
    static void getAccountProjects_nullAccountId_expectEmptyProjectsListTest() {
        Id nullAccountId = null;
        
        List<ProjectBoardController.Project> accountProjects = ProjectBoardController.getAccountProjects(nullAccountId);
        
        assertNoProjects(accountProjects);
    }
    
    @isTest
    static void getAccountProjects_accountIdGivenWithNoProjects_expectEmptyProjectsListTest() {
        Account accountWithNoProjects = AccountTestData.Instance.insertCustomerAccount();
        
        List<ProjectBoardController.Project> accountProjects = ProjectBoardController.getAccountProjects(accountWithNoProjects.Id);
        
        assertNoProjects(accountProjects);
    }
    
    @isTest
    static void getAccountProjects_accountIdGivenWithOneProject_expectDefaultProjectReturnedTest() {
        loadSetupData();
        Account accountWithProject = AccountTestData.Instance.insertCustomerAccount();
        Opportunity enrollmentOpportunity = OpportunityTestData.Instance.withAccount(accountWithProject.Id)
                                                                        .insertAFESOpportunity();

        DefaultProject.Opportunity__c = enrollmentOpportunity.Id;
        update DefaultProject;
        
        List<ProjectBoardController.Project> accountProjects = ProjectBoardController.getAccountProjects(accountWithProject.Id);
        
        assertProjectsHasOnlyDefaultProject(accountProjects);
    }
}