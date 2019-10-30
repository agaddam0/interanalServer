@isTest
public class AccountAssessmentDetailsExtTest {
    
    public static testMethod void Should_Return_Split_Char(){        
        System.assert('ϟ' == AccountAssessmentDetailsExt.getSplitChar());
    }
    
    public static testMethod void Should_Return_Users_Id_From_Role_Id(){
        List<Id> role_ids =  new List<Id>();
        role_ids.add('00Ej0000000Do1AEFF');
        AccountAssessmentDetailsExt.getUsers(role_ids);
    }
    
    public static testMethod void Should_Return_Stars_From_Account_List(){
        List<Account> accounts = new List<Account>();
        Account act = new Account();
        act.Id = '001V000000P3WrAIFF';
        accounts.add(act);
        AccountAssessmentDetailsExt.getStarsFromAccounts(accounts); 
    }
    
    public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '005';
        
    Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
    randStr += chars.substring(idx, idx+1);
    randStr += '0000003';
        
        for(Integer i = 0; i < 7; i++){
            idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
    		randStr += chars.substring(idx, idx+1);
        }
        
    return randStr; 
}
    
    public static testMethod void Should_Return_Stars_From_User_Id_List(){
        List<id> userIds = new List<id>();
        userIds.add('0050000003vfGIDKFE');
        AccountAssessmentDetailsExt.getStarsFromUsers(userIds, 0, null);        
    }

}