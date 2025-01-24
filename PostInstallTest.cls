@isTest
private class PostInstallTest {
 
    @isTest
    static void testSuccessfulInstallation() {
        Test.testInstall(new PostInstallClass(), new Version(1,0), true);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true));
        
        Test.startTest();
        
        PostInstallClass installScript = new PostInstallClass();
        
        TestInstallContext mockContext = new TestInstallContext();
        
        installScript.onInstall(mockContext);
        
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testFailedInstallation() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        
        Test.startTest();
        
        PostInstallClass installScript = new PostInstallClass();
        
        TestInstallContext mockContext = new TestInstallContext();
        
        installScript.onInstall(mockContext);
        
        Test.stopTest();
        
    }
    
    public class TestInstallContext implements System.InstallContext {
        public ID organizationId() { 
            return UserInfo.getOrganizationId(); 
        }
        public ID installerId() { 
            return UserInfo.getUserId(); 
        }
        public Boolean isUpgrade() { 
            return false; 
        }
        public Boolean isPush() { 
            return false; 
        }
        public Version previousVersion() { 
            return null; 
        }
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Boolean isSuccess;
        
        public MockHttpResponseGenerator(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            System.assertEquals('POST', req.getMethod());
            System.assertEquals('application/json', req.getHeader('Content-Type'));
            System.assertEquals('https://rut.my.salesforce-sites.com/services/apexrest/getAPIKey', req.getEndpoint());
            
            if (isSuccess) {
                res.setStatusCode(200);
                res.setBody('MOCK_API_KEY_12345');
            } else {
                res.setStatusCode(500);
                res.setBody('Error processing request');
            }
            
            return res;
        }
    }

}