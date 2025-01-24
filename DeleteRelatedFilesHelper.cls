public with sharing class DeleteRelatedFilesHelper {
	  public static void checkContentDocumentPermissions() {
        // Check if the user has read access to ContentDocumentLink
        if (!Schema.sObjectType.ContentDocumentLink.isAccessible() || 
            !Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()) {
            throw new System.NoAccessException();
        }

        // Check if the user has access to ContentDocument and delete permission
        if (!Schema.sObjectType.ContentDocument.isAccessible() || 
            !Schema.sObjectType.ContentDocument.isDeletable()) {
            throw new System.NoAccessException();
        }
    }
}