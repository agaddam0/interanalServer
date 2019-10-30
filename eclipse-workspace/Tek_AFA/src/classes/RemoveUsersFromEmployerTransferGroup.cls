global class RemoveUsersFromEmployerTransferGroup implements Schedulable {

    /******************************************************
     * This class is to delete any missed or remaining users
     * from the Public Group AWD_Employer_Transfer and AFES_Employer_Transfer
     * that were created more than 30 minutes ago
     * ****************************************************/
    
    global void execute(SchedulableContext SC) {
        
        List<Id> publicGroupIds = new List<Id>(new Map<Id, Group>(
            [SELECT Id FROM Group 
             WHERE DeveloperName = 'AFES_Employer_Transfer' 
             OR DeveloperName = 'AWD_Employer_Transfer']).keySet());
        
        DateTime lastThirty = System.now().addMinutes(-30);
        
        List<GroupMember> membersToDelete = [SELECT Id, SystemModstamp FROM GroupMember WHERE GroupId IN :publicGroupIds AND SystemModstamp < : lastThirty];
        
        if(membersToDelete.size() > 0)
            delete membersToDelete;
    }
}