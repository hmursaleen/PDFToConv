/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class ChatBotControllerTest {

    @isTest
    static void testSendMessage_SuccessfulResponse() {
        // Arrange
        String expectedAnswer = 'This is a sample bot response.';

        // Mock the custom settings
        PDFtoConvTest__SecretKey__c secretKey = new PDFtoConvTest__SecretKey__c(Name = 'Secret Key', Key__c = 'test-api-key');
        insert secretKey;

        PDFtoConvTest__KnowledgeBase__c article = new PDFtoConvTest__KnowledgeBase__c(Name = 'Knowledge Article', File_Source_Id__c = 'test-source-id');
        insert article;

        // Mock HTTP Callout
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"content": "' + expectedAnswer + '"}');
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Act
        List<String> queries = new List<String>{ 'Test query' };
        List<ChatBotController.BotResponse> responses = ChatBotController.sendMessage(queries);

        // Assert
        System.assertNotEquals(null, responses);
        System.assertEquals(1, responses.size());
        System.assertEquals(expectedAnswer, responses[0].answer);
        Test.stopTest();
    }

    @isTest
    static void testSendMessage_ErrorResponse() {
        // Arrange
        PDFtoConvTest__SecretKey__c secretKey = new PDFtoConvTest__SecretKey__c(Name = 'Secret Key', Key__c = 'test-api-key');
        insert secretKey;

        PDFtoConvTest__KnowledgeBase__c article = new PDFtoConvTest__KnowledgeBase__c(Name = 'Knowledge Article', File_Source_Id__c = 'test-source-id');
        insert article;

        // Mock HTTP Callout
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{}');
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Act
        List<String> queries = new List<String>{ 'Test query' };
        List<ChatBotController.BotResponse> responses = ChatBotController.sendMessage(queries);

        // Assert
        System.assertNotEquals(null, responses);
        System.assertEquals(1, responses.size());
        System.assert(responses[0].answer.contains('Error'));
        Test.stopTest();
        
        
    }
    @isTest
    static void testSendMessage_NoResponse()
    {
        PDFtoConvTest__SecretKey__c secretKey = new PDFtoConvTest__SecretKey__c(Name = 'Secret Key', Key__c = 'test-api-key');
        insert secretKey;

        PDFtoConvTest__KnowledgeBase__c article = new PDFtoConvTest__KnowledgeBase__c(Name = 'Knowledge Article', File_Source_Id__c = 'test-source-id');
        insert article;
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{}');
        HttpCalloutMock mock= new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        List<String> queries = new List<String>{ 'Test query' };
        List<ChatBotController.BotResponse> responses= ChatBotController.sendMessage(queries);

        // Assert


        System.assertEquals('Error: Response does not contain content',responses[0].answer);
        Test.stopTest();
    }

    @isTest
    static void testSendMessage_ExceptionHandling() {
        // Arrange
        PDFtoConvTest__SecretKey__c secretKey = new PDFtoConvTest__SecretKey__c(Name = 'Secret Key', Key__c = 'test-api-key');
        insert secretKey;

        // Simulate missing KnowledgeBase setting to trigger exception
        // No KnowledgeBase inserted here

        // Mock HTTP Callout
        Test.startTest();
        HttpCalloutMock mock = new MockHttpResponseGenerator(new HttpResponse());
        Test.setMock(HttpCalloutMock.class, mock);

        // Act
        List<String> queries = new List<String>{ 'Test query' };
        List<ChatBotController.BotResponse> responses = ChatBotController.sendMessage(queries);

        // Assert
        System.assertNotEquals(null, responses);
        System.assertEquals(1, responses.size());
        System.assert(responses[0].answer.contains('Exception'));
        Test.stopTest();
    }

    @isTest
    static void testGetBotResponse() {
        // Arrange
        String query = 'Test query';
        String expectedAnswer = 'This is a sample bot response.';

        // Mock the custom settings
        PDFtoConvTest__SecretKey__c secretKey = new PDFtoConvTest__SecretKey__c(Name = 'Secret Key', Key__c = 'test-api-key');
        insert secretKey;

        PDFtoConvTest__KnowledgeBase__c article = new PDFtoConvTest__KnowledgeBase__c(Name = 'Knowledge Article', File_Source_Id__c = 'test-source-id');
        insert article;

        // Mock HTTP Callout
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"content": "' + expectedAnswer + '"}');
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Act
        String botResponse = ChatBotController.getBotResponse(query);

        // Assert
        System.assertEquals(expectedAnswer, botResponse);
        Test.stopTest();
    }
    @isTest
    static void testGetBotNoResponse() {
        // Arrange
        String query = 'Test query';
        String expectedAnswer = 'This is a sample bot response.';

        // Mock the custom settings
        PDFtoConvTest__SecretKey__c secretKey = new PDFtoConvTest__SecretKey__c(Name = 'Secret Key', Key__c = 'test-api-key');
        insert secretKey;

        PDFtoConvTest__KnowledgeBase__c article = new PDFtoConvTest__KnowledgeBase__c(Name = 'Knowledge Article', File_Source_Id__c = 'test-source-id');
        insert article;

        // Mock HTTP Callout
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"content": ""}');
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Act
        String botResponse = ChatBotController.getBotResponse(query);

        // Assert
        System.assertEquals('', botResponse);
        Test.stopTest();
    }

    /**
     * Mock HTTP Callout Class
     */
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}