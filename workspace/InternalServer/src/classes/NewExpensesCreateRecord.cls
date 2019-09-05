public class NewExpensesCreateRecord{

    @AuraEnabled
    public static string createRecord1 (Expense__c newExpense){
        
        try{
            System.debug('CreateCandidateRecord::createRecord::candidate'+newExpense);
            
            if(newExpense!= null){
                insert newExpense;
            }
            
        } catch (Exception ex){
            
        }
        return newExpense.name;
    }  
}