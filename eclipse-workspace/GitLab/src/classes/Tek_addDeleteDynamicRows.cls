public with sharing class Tek_addDeleteDynamicRows {

    @AuraEnabled
    public static void insertAcclist(List<account> accList){
        system.debug('values'+acclist);
        List<account> acc = new list<account>();
        insert acclist;
        
    }
    
}