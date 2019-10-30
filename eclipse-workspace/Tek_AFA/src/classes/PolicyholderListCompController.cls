public with Sharing class PolicyholderListCompController {

    @AuraEnabled
    public static List<Policyholder__c> getPolicyholders(Id acctId, String alphaFilter, String keyword, String bdate, Boolean sortAsc)
    {        
    	String queryString = 'SELECT Id, ' +
                             'First_Name__c, ' +
                             'Last_Name__c, ' +
                             'Birthdate__c, ' +
                             'Status__c, ' +
                             'Name ' + 
                             'FROM Policyholder__c ' +
            		         'WHERE Id IN (Select Policyholder__c from Purchased_Product__c WHERE Account__c = :acctId) ';


        if (String.isEmpty(alphaFilter) || alphaFilter == 'Other') 
        { 
            if (String.isNotEmpty(keyword)) 
            {
                queryString += ' AND (Last_Name__c LIKE \'%' + String.escapeSingleQuotes(keyword) + '%\')';
            }
            
            if (String.isNotEmpty(bdate))
            {
                queryString += ' AND (Birthdate__c = ' + (String.valueOf(Date.valueOf(bDate))) + ')';
            }
        } 
        else if (alphaFilter != 'All')
        {
            queryString += ' AND Last_Name__c LIKE \'' + String.escapeSingleQuotes(alphaFilter) + '%\'';
        }

        if (sortAsc == null || sortAsc == true)
        {
            queryString += ' ORDER BY Last_Name__c ASC';
        }
        else
        {
            queryString += ' ORDER BY Last_Name__c DESC';
        }

        return (List<Policyholder__c>)Database.query(queryString);
    }
}