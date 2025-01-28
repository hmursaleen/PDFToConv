/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Ingest {
    
    @AuraEnabled
    public static void uploadPDF() {
        // Check for access on PDFtoConv__SecretKey__c
        if (!Schema.sObjectType.PDFtoConv__SecretKey__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Secret Key.');
        }
        
        PDFtoConv__SecretKey__c apiKey = PDFtoConv__SecretKey__c.getInstance('Secret Key');
        if (apiKey == null || String.isBlank(apiKey.KEY__c)) {
            throw new AuraHandledException('Secret Key is missing. Please set the Secret key by following the instructions on the instruction page.');
        }

        // Check for access on PDFtoConv__KnowledgeBase__c
        if (!Schema.sObjectType.PDFtoConv__KnowledgeBase__c.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Knowledge Base.');
        }
        
        PDFtoConv__KnowledgeBase__c article = PDFtoConv__KnowledgeBase__c.getInstance('Knowledge Article');
        if (article == null) {
            article = new PDFtoConv__KnowledgeBase__c();
            article.Name = 'Knowledge Article';
        } else if (String.isNotBlank(article.File_Source_Id__c)) {
            deletePDF(article.File_Source_Id__c);
        }

        // Check if ContentVersion object is accessible
        if (!Schema.sObjectType.ContentVersion.isAccessible()) {
            System.debug('Insufficient permissions to access ContentVersion.');
            return;
        }
        
        // Retrieve the latest ContentVersion with the title 'Knowledge Articles'
        List<ContentVersion> cntDocs = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Knowledge Articles'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (cntDocs.isEmpty()) {
            System.debug('ContentVersion record for Knowledge Articles not found.');
            return;
        }
        ContentVersion cntDoc = cntDocs[0];

        // Check if ContentDistribution object is accessible
        if (!Schema.sObjectType.ContentDistribution.isAccessible()) {
            System.debug('Insufficient permissions to access ContentDistribution.');
            return;
        }

        List<ContentDistribution> cntDists = new List<ContentDistribution>();
        if (cntDoc.ContentDocumentId != null) {
            cntDists = [
                SELECT DistributionPublicUrl, PdfDownloadUrl, ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentDocumentId = :cntDoc.ContentDocumentId
                LIMIT 1
            ];
        } else {
            throw new NullPointerException();
        }
        if (cntDists.isEmpty()) {
            System.debug('ContentDistribution record not found.');
            return;
        }
        ContentDistribution cntDist = cntDists[0];
        Http http = new Http();

        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.chatpdf.com/v1/sources/add-url');
        req.setMethod('POST');

        // Set headers
        req.setHeader('x-api-key', apiKey.KEY__c);
        req.setHeader('Content-Type', 'application/json');

        // Set the body
        String requestBody = '{"url": "' + cntDist.ContentDownloadUrl + '"}';
        req.setBody(requestBody);

        // Send the request, and return a response
        HttpResponse res;
        try {
            res = http.send(req);

            // Handle response
            if (res.getStatusCode() == 200) {
                // Parse JSON response
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (responseBody.containsKey('sourceId')) {
                    article.File_Source_Id__c = (String) responseBody.get('sourceId');
                    
                    // Check if the user has create or update permissions before performing DML
                    if (Schema.sObjectType.PDFtoConv__KnowledgeBase__c.isCreateable() &&
                        Schema.sObjectType.PDFtoConv__KnowledgeBase__c.isUpdateable()) {
                        upsert article;
                        System.debug('Source ID: ' + (String) responseBody.get('sourceId'));
                    } else {
                        System.debug('Insufficient permissions to create or update Knowledge Base.');
                    }
                } else {
                    System.debug('Error: Response does not contain Source ID');
                }
            } else {
                System.debug('Error: ' + res.getStatus() + ' ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void deletePDF(String fileSourceId) {
        // Check for access on PDFtoConv__SecretKey__c
        if (!Schema.sObjectType.PDFtoConv__SecretKey__c.isAccessible()) {
            System.debug('Insufficient permissions to access Secret Key for delete.');
            return;
        }
        
        PDFtoConv__SecretKey__c apiKey = PDFtoConv__SecretKey__c.getInstance('Secret Key');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.chatpdf.com/v1/sources/delete');
        req.setMethod('POST');

        req.setHeader('x-api-key', apiKey.KEY__c);
        req.setHeader('Content-Type', 'application/json');

        String requestBody = '{"sources":  ["' + fileSourceId + '"] }';
        req.setBody(requestBody);
        
        HttpResponse res;
        try {
            res = http.send(req);
            System.debug('Delete Response: ' + res);
        } catch (Exception e) {
            System.debug('Delete Exception: ' + e.getMessage());
        }
    }
}