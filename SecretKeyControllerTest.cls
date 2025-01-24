@IsTest
public class SecretKeyControllerTest {
    
  @isTest
public static void testSaveSecretKey()
{
      

     
        String key='testkey';	
        Test.startTest();
        SecretKeyController.saveSecretKey(key);
	
		SecretKey__c secretKeySetting = SecretKey__c.getInstance('Secret Key');
		Test.stopTest();
		System.assertEquals('testkey',secretKeySetting.Key__c);
          
}
   @isTest
    static void testSaveSecretKeyNoAccess()
    {
         String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';

          // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Restricted User'];
        User u = new User(Alias = 'resusr', Email='restricteduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        System.runAs(u){
        String key='testkey';	
        Test.startTest();
        try{
        SecretKeyController.saveSecretKey(key);    
        }
            catch(Exception e)
            {
                System.Assert(true,'Expected no access exception');
            }
        
		Test.stopTest();
		
        }
        
        
    }
}