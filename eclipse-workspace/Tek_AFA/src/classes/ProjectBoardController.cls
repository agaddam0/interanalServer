public with sharing class ProjectBoardController {
    public static final String PROJECT_STATUS_IN_PROGRESS = 'In Progress';
    public static final String PROJECT_STATUS_NEW = 'New';
    
    @AuraEnabled
    public static ProjectBoard getProjectBoard() {
        ProjectBoard projBoard = new ProjectBoard();
        
        projBoard.RecentlyViewedProjects = getMyRecentlyViewedProjects();
        projBoard.MyPinnedProjects = getMyPinnedProjects();
        
        return projBoard;
    }
    
    @AuraEnabled
    public static List<Project> getMyRecentlyViewedProjects() {
        List<Project__c> recentlyViewedProjectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE LastViewedDate != null
            AND LastViewedDate >= YESTERDAY
          ORDER BY Name];
            
        List<Project> recentlyViewedProjects = buildProjects(recentlyViewedProjectRecords);
        
        return recentlyViewedProjects;
    }
    
    @AuraEnabled
    public static List<Project> getMyPinnedProjects() {
        String projectPrefix = Schema.SObjectType.Project__c.getKeyPrefix();
        String projectMinValue = projectPrefix + '000000000000';
        String projectMaxValue = projectPrefix + 'zzzzzzzzzzzz';

        List<Task> pinnedProjectTasks =
        [SELECT Id,
                WhatId
           FROM Task
          WHERE Pinned__c = true
            AND WhatId >= :projectMinValue
            AND WhatId <= :projectMaxValue
            AND OwnerId = :UserInfo.getUserId()];

        List<Project> pinnedProjects = new List<Project>();
        
        if (pinnedProjectTasks.size() == 0) {
            return pinnedProjects;
        }
        
        Set<Id> projectIds = CollectionUtil.getLookupIds(pinnedProjectTasks, 'WhatId');
        
        List<Project__c> pinnedProjectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c
           FROM Project__c
          WHERE Id in :projectIds
          ORDER BY Name];

        for (Project__c pinnedProjectRecord : pinnedProjectRecords) {
            Project p = new Project();
            p.Record = pinnedProjectRecord;
            p.Pinned = true;
            
            pinnedProjects.add(p);
        }
        
        return pinnedProjects;
    }
    
    @AuraEnabled
    public static List<Project> getAllOpenProjects() {
        List<Project__c> allOpenProjectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE Percent_Complete__c != 100
             OR Status__c = :PROJECT_STATUS_IN_PROGRESS
          ORDER BY Name];
          
        List<Project> allOpenProjects = buildProjects(allOpenProjectRecords);
        
        return allOpenProjects;
    }
    
    @AuraEnabled
    public static List<Project> getMyOpenProjects() {
        List<Project__c> myOpenProjectsFromTasks =
        [SELECT Id,
                Name
           FROM Project__c
          WHERE Id in (SELECT Project__c
                         FROM Task__c
                        WHERE Assignee__c = :UserInfo.getUserId()
                          AND Complete__c = false
                          AND Status__r.Display_on_Task_Board__c = true)];
        
        
        List<Project__c> myOpenProjectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE Id in :myOpenProjectsFromTasks
             OR (OwnerId = :UserInfo.getUserId() AND
                 Status__c = :PROJECT_STATUS_IN_PROGRESS)
          ORDER BY Name];
          
        List<Project> myOpenProjects = buildProjects(myOpenProjectRecords);
        
        return myOpenProjects;
    }

    @AuraEnabled
    public static List<Project> getMyAssignedProjects() {
        List<Project__c> myOpenAssignedProjectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE OwnerId = :UserInfo.getUserId()
            //AND Status__c = :PROJECT_STATUS_IN_PROGRESS
          ORDER BY Name];
          
        List<Project> myOpenAssignedProjects = buildProjects(myOpenAssignedProjectRecords);
        
        return myOpenAssignedProjects;
    }
    
    @AuraEnabled
    public static List<Project> getAccountProjects(Id accountId) {
        List<Project> accountProjects = new List<Project>();
        
        if (accountId == null) {
            return accountProjects;
        }

        List<Project__c> accountProjectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE Opportunity__r.AccountId = :accountId
          ORDER BY Percent_Complete__c];
          
        accountProjects = buildProjects(accountProjectRecords);

        return accountProjects;
    }
    
    @AuraEnabled
    public static void toggleProjectPinnedness(Id projectId) {
        Project__c proj = getProjectById(projectId);
        
        if (proj.Tasks != null && proj.Tasks.size() > 0) {
            delete proj.Tasks;
            return;
        }
        
        Task pinnedTask = new Task(
            WhatId = projectId,
            Pinned__c = true,
            Subject = 'Pinned Project',
            Status = 'Completed'
        );
        
        insert pinnedTask;
    }

    @AuraEnabled
    public static SearchResult searchForRecords(String searchText) {
        SearchResult result = new SearchResult();
        
        if (String.isNotBlank(searchText)) {
	        result.Projects = searchProjects(searchText);
	        result.Accounts = searchAccounts(searchText);
        }
        
        return result;
    }
    
    @AuraEnabled
    public static void queryProjectForViewing(Id projectId) {
        Project__c viewedProject = getProjectById(projectId);
    }

    private static Project__c getProjectById(Id projectId) {
        return
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE Id = :projectId
          FOR VIEW];
    }
    
    private static List<Project> searchProjects(String searchText) {
        String containsSearchText = '%' + searchText + '%';
        
        List<Project__c> projectRecords =
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.Enrollment_Start_Date__c,
                Opportunity__r.Enrollment_End_Date__c,
                Opportunity__r.Effective_Date_of_AFA_Products__c,
                (SELECT Id
                   FROM Tasks
                  WHERE Pinned__c = true
                    AND OwnerId = :UserInfo.getUserId())
           FROM Project__c
          WHERE Name like :containsSearchText
         ORDER BY Name
          LIMIT 10];
        
        return buildProjects(projectRecords);
    }
    
    private static List<Account> searchAccounts(String searchText) {
        String containsSearchText = '%' + searchText + '%';
        
        List<Account> accounts =
        [SELECT Id,
                Name
           FROM Account
          WHERE Name like :containsSearchText
         ORDER BY Name
          LIMIT 10];
        
        return accounts;
    }
    
    private static List<Project> buildProjects(List<Project__c> projectRecords) {
        List<Project> projects = new List<Project>();
        
        for (Project__c projectRecord : projectRecords) {
            Project p = new Project();
            p.Record = projectRecord;
            p.Pinned = projectRecord.Tasks != null && projectRecord.Tasks.size() > 0;
            
            projects.add(p);
        }
        
        return projects;
    }
    
    public class ProjectBoard {
        @AuraEnabled
        public List<Project> RecentlyViewedProjects { get; set; }
        
        @AuraEnabled
        public List<Project> MyPinnedProjects { get; set; }
        
        public ProjectBoard() {
            RecentlyViewedProjects = new List<Project>();
            MyPinnedProjects = new List<Project>();
        }
    }
    
    public class Project {
        @AuraEnabled
        public Project__c Record { get; set; }

        @AuraEnabled
        public Boolean Pinned { get; set; }
    }
    
    public class SearchResult {
        @AuraEnabled
        public List<Project> Projects { get; set; }
        
        @AuraEnabled
        public List<Account> Accounts { get; set; }
        
        public SearchResult() {
            Projects = new List<Project>();
            Accounts = new List<Account>();
        }
    }
}