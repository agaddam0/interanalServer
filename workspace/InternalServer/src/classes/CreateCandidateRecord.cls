/************************************************************
 
 Name: CreateCandidateRecord
 Type: Apex Class  
 Purpose: Apex Class  for  lightning component 
          CreateCandidateRecordController.cmp
 ***********************************************************/
public with sharing class CreateCandidateRecord {

    /**
   * Create a new candidate Record
   *
   * @param Candidate__c candidate  candidate record to be inserted
   * 
   */
    @AuraEnabled
    public static void createRecord (Candidate__c candidate){
        
        try{
            System.debug('CreateCandidateRecord::createRecord::candidate'+candidate);
            
            if(candidate != null){
                insert candidate;
               
            }
            
        } catch (Exception ex){
        
            
        }
        
    }    
}