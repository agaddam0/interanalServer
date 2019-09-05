public class TrailObject_Utility{

    @AuraEnabled// annotation indicates this method is enable for aura component(Lightning) 
    public static string createRecord(Trail__c newTrail){
        
        try{
            System.debug('CreateCandidateRecord::createRecord::candidate'+newTrail);
            
            if(newTrail!= null){
                insert newTrail;
            }
            
        } catch (Exception ex){
            
        }
        return newTrail.name;
    }  
}