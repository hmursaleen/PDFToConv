/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class PostInstallClass implements InstallHandler {    
    // This method will be executed after the package installation
    global void onInstall(InstallContext context) {
        System.debug('Post installation script started.');

        // Check FLS before querying User fields
        if (!Schema.sObjectType.User.fields.Email.isAccessible() || 
            !Schema.sObjectType.User.fields.Name.isAccessible()) {
            throw new System.NoAccessException();
        }

        // Query current user information
        User currentUser = [SELECT Id, Email, Name 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];

        // Prepare data for the API request
        Map<String, String> req = new Map<String, String>();
        req.put('OrgID', context.organizationId());
        req.put('Email', currentUser.Email);
        req.put('Username', currentUser.Name);
        String orgData = JSON.serialize(req);

        // Trigger asynchronous callout to fetch and save API key
        getAPI(orgData);
    }
    
    @future(callout=true)
    public static void getAPI(String orgData) {    
        try { 
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            String url = 'https://rut.my.salesforce-sites.com/services/apexrest/getAPIKey';
            request.setEndpoint(url);

            // Set the HTTP method to POST
            request.setMethod('POST');
            
            // Set the Content-Type header to application/json
            request.setHeader('Content-Type', 'application/json');
            
            // Prepare the body with orgId in JSON format
            String requestBody = orgData;
            request.setBody(requestBody);
            
            // Send the HTTP request and get the response
            HttpResponse response = http.send(request);
            
            // Check if the response status is OK
            if (response.getStatusCode() == 200) {
                String apiKey = response.getBody();
                
                // Ensure response is not empty before saving
                if (String.isNotBlank(apiKey)) {
                    SecretKeyController.saveSecretKey(apiKey);
                    System.debug('API key saved successfully.');
                } else {
                    System.debug('Error: Received empty API key from endpoint.');
                }
            } else {
                System.debug('Error: Failed to retrieve API key. Status: ' + response.getStatus() + ', Body: ' + response.getBody());
            }
            
            System.debug('Post installation script completed successfully.');
        } catch (Exception e) {
            System.debug('Error during post installation: ' + e.getMessage());
        }
    }
}