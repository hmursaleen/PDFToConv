/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SecretKeyController {

    @AuraEnabled
    public static String saveSecretKey(String key) {

        // Check if the user has access to the SecretKey__c object
        if (!Schema.sObjectType.SecretKey__c.isAccessible()) {
            throw new System.NoAccessException();
        }

        // Check field-level security for the Key__c field
        if (!Schema.sObjectType.SecretKey__c.fields.Key__c.isUpdateable()) {
            throw new System.NoAccessException();
        }

        // Retrieve the custom setting instance
        SecretKey__c secretKeySetting = SecretKey__c.getInstance('Secret Key');

        // If the custom setting instance does not exist
        if (secretKeySetting == null) {
            // Check if the user has permission to create SecretKey__c records
            if (!Schema.sObjectType.SecretKey__c.isCreateable()) {
                throw new System.NoAccessException();
            }

            // Create a new custom setting instance
            secretKeySetting = new SecretKey__c(Name = 'Secret Key');
        }

        // Set the API Key value
        secretKeySetting.Key__c = key;

        // Perform upsert to insert or update the custom setting
        upsert secretKeySetting;

        return 'Success';
    }
}
