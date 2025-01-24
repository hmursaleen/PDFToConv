@isTest
private class PDF_UploadControllerTest {
    
    @TestSetup
    static void setupTestData() {
     
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDoc.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;
    }
    
    @isTest
    static void testSaveKnowledgeBaseDocument_Success() {
  
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        String contentDocumentId = cv.ContentDocumentId;
        
        Test.startTest();
        try {
            Id kbdId = PDF_UploadController.saveKnowledgeBaseDocument('Test KB Document', contentDocumentId);
            
          
            Knowledge_Base_Document__c kbd = [SELECT Id, Name FROM Knowledge_Base_Document__c WHERE Id = :kbdId];
            System.assertEquals('Test KB Document', kbd.Name, 'Knowledge Base Document name should match');
            
            ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType 
                                     FROM ContentDocumentLink 
                                     WHERE LinkedEntityId = :kbdId];
            System.assertEquals(contentDocumentId, cdl.ContentDocumentId, 'ContentDocumentId should match');
            System.assertEquals('I', cdl.ShareType, 'ShareType should be I');
            
        } catch (Exception e) {
            System.assert(false, 'No exception should be thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
   /* @isTest
    static void testSaveKnowledgeBaseDocument_InvalidDocument() {
        Test.startTest();
        try {
            PDF_UploadController.saveKnowledgeBaseDocument('Test KB Document', 'InvalidId');
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error Saving Knowledge Base Document'), 
                         'Error message should indicate saving failed');
        }
        Test.stopTest();
    }*/
    
    @isTest
    static void testSaveKnowledgeBaseDocument_NoAccess() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser@testorg.com' + System.currentTimeMillis()
        );
        
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        final String contentDocumentId = cv.ContentDocumentId;
        
        System.runAs(u) {
            Test.startTest();
            try {
                PDF_UploadController.saveKnowledgeBaseDocument('Test KB Document', contentDocumentId);
                System.assert(false, 'Should have thrown NoAccessException');
            } catch (System.NoAccessException e) {
                System.assert(true, 'NoAccessException was correctly thrown');
            }
            Test.stopTest();
        }
    }
    
    
}