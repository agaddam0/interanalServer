Public class expensesRecordsDisplay{

   @AuraEnabled
   public static List<Expense__c> getExpensesRecords(){
   
     return [Select id,name,amount__c,date__c,client__c,Reimbursed__c from Expense__c];
   }

  @AuraEnabled
  public static Expense__c deleteRecords(Expense__c Expenses){
    system.debug('expenseexpense'+Expenses);
     delete Expenses;
     return Expenses;
  }
}