/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class KnowledgeDocumentController {
    @AuraEnabled
    public static List<ContentVersion> getAllKnowledgeBase() {
        // Check field-level security
        if (!Schema.sObjectType.Knowledge_Base_Document__c.fields.Id.isAccessible()) {
            throw new System.NoAccessException();
        }

        List<Knowledge_Base_Document__c> knowledgeBaseDocuments = [
            SELECT Id
            FROM Knowledge_Base_Document__c
        ];

        if (knowledgeBaseDocuments.isEmpty()) {
            return new List<ContentVersion>();
        }

        Set<Id> knowledgeDocId = new Map<Id, Knowledge_Base_Document__c>(knowledgeBaseDocuments).keySet();

        // Check access for ContentDocumentLink
        if (!Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()) {
            throw new System.NoAccessException();
        }

        List<Id> tempsId = new List<Id>();
        if (!knowledgeDocId.isEmpty()) {
            List<ContentDocumentLink> lsOfCDL = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :knowledgeDocId
            ];
            for (ContentDocumentLink tempLoop : lsOfCDL) {
                tempsId.add(tempLoop.ContentDocumentId);
            }
        } else {
            throw new System.NullPointerException();
        }

        if (tempsId.isEmpty()) {
            return new List<ContentVersion>();
        }

        // Check field-level security for ContentVersion
        if (
            !Schema.sObjectType.ContentVersion.fields.Id.isAccessible() ||
            !Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible() ||
            !Schema.sObjectType.ContentVersion.fields.FileExtension.isAccessible()
        ) {
            throw new System.NoAccessException();
        }

        return [
            SELECT Id, ContentDocumentId, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :tempsId AND isLatest = TRUE
        ];
    }

    @AuraEnabled
    public static String getVersionData(String contentVersionId) {
        // Check field-level security
        if (!Schema.sObjectType.ContentVersion.fields.VersionData.isAccessible()) {
            throw new System.NoAccessException();
        }

        if (contentVersionId == null) {
            throw new System.NullPointerException();
        }

        ContentVersion cv = [
            SELECT VersionData
            FROM ContentVersion
            WHERE Id = :contentVersionId
            LIMIT 1
        ];

        return EncodingUtil.base64Encode(cv.VersionData);
    }

    @AuraEnabled
    public static void savePDF(String base64Strings) {
        // Check access for ContentVersion fields
        if (
            !Schema.sObjectType.ContentVersion.fields.Title.isAccessible() ||
            !Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible()
        ) {
            throw new System.NoAccessException();
        }

        List<ContentVersion> files = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Knowledge Articles'
        ];

        try {
            Blob completePdfBlob = EncodingUtil.base64Decode(base64Strings);

            if (!files.isEmpty()) {
                // Check if the user has delete access to ContentDocument
                if (!Schema.sObjectType.ContentDocument.isDeletable()) {
                    throw new System.NoAccessException();
                }

                List<ContentDocument> docs = [
                    SELECT Id
                    FROM ContentDocument
                    WHERE Id = :files[0].ContentDocumentId WITH SECURITY_ENFORCED
                ];

                // Ensure access to the ContentDocument object
                if (!Schema.sObjectType.ContentDocument.isAccessible() || 
                    !Schema.sObjectType.ContentDocument.isDeletable()) {
                    throw new System.NoAccessException();
                }

                else delete docs;
            }

            // Check create access for ContentVersion fields
            if (
                !Schema.sObjectType.ContentVersion.fields.Title.isCreateable() ||
                !Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() ||
                !Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()
            ) {
                throw new System.NoAccessException();
            }

            // Create a new ContentVersion record
            ContentVersion newFile = new ContentVersion();
            newFile.Title = 'Knowledge Articles';
            newFile.PathOnClient = 'Knowledge Articles.pdf';
            newFile.VersionData = completePdfBlob;
            insert newFile;

            generateURL(newFile.Id);

        } catch (Exception e) {
            throw new AuraHandledException('Error saving complete PDF: ' + e.getMessage());
        }
    }

    private static void generateURL(String cv) {
        // Check create access for ContentDistribution fields
        if (
            !Schema.sObjectType.ContentDistribution.fields.Name.isCreateable() ||
            !Schema.sObjectType.ContentDistribution.fields.ContentVersionId.isCreateable() ||
            !Schema.sObjectType.ContentDistribution.fields.PreferencesAllowViewInBrowser.isCreateable() ||
            !Schema.sObjectType.ContentDistribution.fields.PreferencesLinkLatestVersion.isCreateable() ||
            !Schema.sObjectType.ContentDistribution.fields.PreferencesNotifyOnVisit.isCreateable() ||
            !Schema.sObjectType.ContentDistribution.fields.PreferencesPasswordRequired.isCreateable() ||
            !Schema.sObjectType.ContentDistribution.fields.PreferencesAllowOriginalDownload.isCreateable()
        ) {
            throw new System.NoAccessException();
        }

        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Knowledge Articles';
        cd.ContentVersionId = cv;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;
    }

    @AuraEnabled(Cacheable=true)
    public static boolean checkSync() {
        // Check field-level security for Knowledge_Document_Syncing__c
        if (
            !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.IsSynced__c.isAccessible() ||
            !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.Name.isAccessible()
        ) {
            throw new System.NoAccessException();
        }

        List<Knowledge_Document_Syncing__c> isSynced = [
            SELECT IsSynced__c
            FROM Knowledge_Document_Syncing__c
            WHERE Name = 'Knowledge Document Sync Check'
        ];

        return isSynced[0].IsSynced__c;
    }

    @AuraEnabled
    public static void setSync() {
        // Check field-level security for Knowledge_Document_Syncing__c
        if (
            !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.IsSynced__c.isAccessible() ||
            !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.Name.isAccessible()
        ) {
            throw new System.NoAccessException();
        }

        List<Knowledge_Document_Syncing__c> syncRecords = [
            SELECT Id, IsSynced__c, Name
            FROM Knowledge_Document_Syncing__c
            WHERE Name = 'Knowledge Document Sync Check'
        ];

        if (syncRecords.size() > 0) {
            if (
                !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.IsSynced__c.isUpdateable() ||
                !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.Name.isUpdateable()
            ) {
                throw new System.NoAccessException();
            }

            syncRecords[0].IsSynced__c = true;
            update syncRecords;
        } else {
            if (
                !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.IsSynced__c.isCreateable() ||
                !Schema.sObjectType.Knowledge_Document_Syncing__c.fields.Name.isCreateable()
            ) {
                throw new System.NoAccessException();
            }

            Knowledge_Document_Syncing__c newSyncRecord = new Knowledge_Document_Syncing__c(
                IsSynced__c = true,
                Name = 'Knowledge Document Sync Check'
            );
            insert newSyncRecord;
        }
    }
}
