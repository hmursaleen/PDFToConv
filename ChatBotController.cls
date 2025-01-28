/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class ChatBotController {
    /**
     * @description Represents the bot's response to the user's query.
     */
    global class BotResponse {
        @InvocableVariable(
            label='Bot Response'
            description='The answer returned from bot'
        )
        global String answer;
    }
	
    /**
     * @description Sends the user's queries to the external chatbot API and retrieves the response.
     * @param queries The user's queries.
     * @return List<BotResponse> The response from the chatbot.
     */
    @InvocableMethod(label='Send Message' description='Send users queries')
    global static List<BotResponse> sendMessage(List<String> queries) {
         List<BotResponse> botRes = new List<BotResponse>();
        BotResponse obj = new BotResponse();
        botRes.add(obj);

        try {
            String endpoint;
            if (Schema.sObjectType.API_Configuration__mdt.isAccessible() && 
        Schema.sObjectType.API_Configuration__mdt.fields.Endpoint__c.isAccessible()) {
        
        API_Configuration__mdt config = [SELECT Endpoint__c FROM API_Configuration__mdt WHERE DeveloperName='Chabot_API_Config' LIMIT 1];
        endpoint = config.Endpoint__c;
        
    } else {
        throw new System.NoAccessException();
    }
			
            PDFtoConv__SecretKey__c secretKey = PDFtoConv__SecretKey__c.getInstance('Secret Key');
            PDFtoConv__KnowledgeBase__c article = PDFtoConv__KnowledgeBase__c.getInstance('Knowledge Article');

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');

            req.setHeader('x-api-key', secretKey.Key__c);
            req.setHeader('Content-Type', 'application/json');

            String requestBody = '{"sourceId": "' + article.File_Source_Id__c + '", "messages": [{"role": "user", "content": "' + queries[0] + '. Please do not use information from elsewhere, like internet, and answer solely on the basis of the pdf that is provided. If you are not confident about an answer, clearly state that and do not provide pretentious answer. ' + '"}]}';
            req.setBody(requestBody);

            // Send the request and handle the response
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (responseBody.containsKey('content')) {
                    botRes[0].answer = (String) responseBody.get('content');
                } else {
                    botRes[0].answer = 'Error: Response does not contain content';
                }
            } else {
                //botRes[0].answer = 'Error: ' + res.getStatus() + ' ' + res.getStatusCode();
                botRes[0].answer = 'Error: HTTP ' + res.getStatusCode() + ' (' + res.getStatus() + ')';

            }
        }

        catch (Exception e) {
    botRes[0].answer = 'Exception during chatbot API call: ' + e.getMessage();
}


        return botRes;
    }

    @AuraEnabled
    public static String getBotResponse(String query) {
        List<String> queries = new List<String>{ query };
        List<BotResponse> responses = sendMessage(queries);
      
    	 return responses[0].answer;
    }
    
     
}