@isTest
public class DeleteRelatedFileTest {
    
  @isTest
	static void testDeleteRelatedFiles() {
           Knowledge_Document_Syncing__c kdSync = new Knowledge_Document_Syncing__c(Name='Knowledge Document Sync Check', IsSynced__c=false);
        insert kdSync;   
   Knowledge_Base_Document__c testDoc = new Knowledge_Base_Document__c(Name = 'Test Document');
    insert testDoc;

    ContentVersion contentVersion = new ContentVersion(
        Title = 'Test File',
        VersionData = Blob.valueOf('Test Content'),
        PathOnClient = 'TestFile.pdf'
    );
    insert contentVersion;
    
    ContentDocumentLink contentLink = new ContentDocumentLink(
        LinkedEntityId = testDoc.Id,
        ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId
    );
    insert contentLink;

    Test.startTest();
    delete testDoc;
    Test.stopTest();

    List<ContentDocument> remainingDocuments = [
        SELECT Id FROM ContentDocument WHERE Id = :contentLink.ContentDocumentId
    ];
    System.assertEquals(0, remainingDocuments.size());
}
    
   /* @isTest
    static void testNoAccessExceptionForRestrictedUser() {
        // Create a new user with restricted access
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Restricted User' LIMIT 1];
       

          Knowledge_Base_Document__c testDoc = new Knowledge_Base_Document__c(Name = 'Test Document');
    insert testDoc;

    ContentVersion contentVersion = new ContentVersion(
        Title = 'Test File',
        VersionData = Blob.valueOf('Test Content'),
        PathOnClient = 'TestFile.pdf'
    );
    insert contentVersion;
    
    ContentDocumentLink contentLink = new ContentDocumentLink(
        LinkedEntityId = testDoc.Id,
        ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId
    );
    insert contentLink;

        // Run the test logic as the restricted user
        Test.startTest();
        User restrictedUser = new User(
            Alias = 'test3',
            Email = 'testuser3@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted3',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = restrictedProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'japigir200@nalwan.com'
        );
        insert restrictedUser;
       System.runAs(restrictedUser) {
            try {
                // Explicitly call the helper method to trigger NoAccessException
                   delete testDoc;
                System.assert(false, 'Expected NoAccessException not thrown.');
            } catch (System.NoAccessException e) {
                System.assertEquals('No access to ContentDocumentLink object or its fields.', e.getMessage());
            }
        }
        Test.stopTest();
    }*/
    
}