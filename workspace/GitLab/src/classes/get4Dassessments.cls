public class get4Dassessments {
    @AuraEnabled 
    public static account getAssessments(){
        return (account) Database.query( ' SELECT Name, email FROM account LIMIT 1 ' )[0];
    }

    @AuraEnabled 
    public static account saveAssessment(account assessment){
        upsert assessment;
        return assessment;
    }  

}