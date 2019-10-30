@isTest
public class RemoveUsersFromTransferGroupTest {
	        
    static testMethod void RemoveUserFromGroup()
    {
        Test.startTest();
        
        RemoveUsersFromEmployerTransferGroup removeJob = new RemoveUsersFromEmployerTransferGroup();
        DateTime dt = system.now().addMinutes(30);
        String sch = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String removeJobId = system.schedule('Remove Job Test', sch, removeJob);
        
        system.assertNotEquals(null, removeJobId);
        
        Test.stopTest();
        
        List<Id> publicGroupIds = new List<Id>(new Map<Id, Group>(
            [SELECT Id FROM Group 
             WHERE DeveloperName = 'AFES_Employer_Transfer' 
             OR DeveloperName = 'AWD_Employer_Transfer']).keySet());
        
        List<GroupMember> membersToDelete = [SELECT Id FROM GroupMember WHERE GroupId IN :publicGroupIds AND SystemModstamp < : System.now().addMinutes(-30)];
        
        System.assertEquals(0, membersToDelete.size());
    }
}