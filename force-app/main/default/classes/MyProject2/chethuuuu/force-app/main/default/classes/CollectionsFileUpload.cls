public class CollectionsFileUpload {

    @AuraEnabled
    public static void collectionsFileUpload(List<Object> listOfFiles, Id parentId) {
        Map<Id, String> attachmentIdToFileName = new Map<Id, String>();
        if(listOfFiles != null) {
            for (Object file : listOfFiles) {
                Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(file));
                Id contentVersionId = (Id) requestMap.get('contentVersionId');
                String name = (String) requestMap.get('name');
                attachmentIdToFileName.put(contentVersionId, name);
            }
            CategoryAttachAssnManager.createBulkDocumentCategoryAssociationForCollectionCase(
                attachmentIdToFileName, parentId, GeneralConstants.DOCUMENT_TYPE_COLLECTIONS
            );
        }
    }
}