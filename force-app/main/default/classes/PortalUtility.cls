global Class PortalUtility{
    
    public static genesis__applications__c fetchApplication(String applicationId){
        List<genesis__Applications__c> appList = [select id,genesis__Account__c, genesis__status__c  from genesis__applications__c where Id =: applicationId limit 1];
        if(appList.isEmpty())
            return null;
        return appList[0];
    }
    
    public static List<Map<String,Object>> fetchUploadedDocuments(genesis__applications__c app, String partyName){
        Map<String,List<Map<String,Object>>> documentListMap = new Map<String,List<Map<String,Object>>>();
        Map<String,List<Map<String,Object>>> finaldocumentAttachmentListMap = new Map<String,List<Map<String,Object>>>();
        Map<String,Object> categoryMap = new Map<String,Object>();
        Map<String,Object> fields = new Map<String,Object>();
        List<Map<String,Object>> categoryMapList = new List<Map<String,Object>>();
        List<Map<String,Object>> fieldListMap = new List<Map<String,Object>>();
        Map<String,List<Map<String,Object>>> Map_attachmentfieldListMap = new Map<String,List<Map<String,Object>>>();
        Map<String,List<Map<String,Object>>> Map_docCatfieldListMap = new Map<String,List<Map<String,Object>>>();
        Map<String,Map<String,Object>> docCatfieldListMap = new Map<String,Map<String,Object>>();
        
        List<Map<String,Object>> finalListMap = new List<Map<String,Object>>();
        Map<Id,List<clcommon__Category_Attachment_Association__c>> docAttachmentListMap = new Map<Id,List<clcommon__Category_Attachment_Association__c>>();
            List<clcommon__Document_Category__c> docCatList = [select id,clcommon__Category_Name__c,clcommon__Status__c,(select id,Name,clcommon__Attachment_Id__c,clcommon__Document_Category__c  from clcommon__DocCat_Attachment_Associations__r) from clcommon__Document_Category__c where genesis__Application__c = :app.Id And clcommon__Parent_Document_Category__r.clcommon__Category_Name__c =: partyName];
            
            for(clcommon__Document_Category__c docCat : docCatList ){
                categoryMap = new Map<String,Object>();
                categoryMap.put('CategoryId',docCat.Id);
                categoryMap.put('Category_Name',docCat.clcommon__Category_Name__c);
                categoryMap.put('Type','Category');
                categoryMap.put('Category_Status',docCat.clcommon__Status__c);
                categoryMap.put('IsActive',null);
           
                if(!docCat.clcommon__DocCat_Attachment_Associations__r.isEmpty()){
                    categoryMap.put('HasAttachment',true);
                    categoryMap.put('Attachment_Id', docCat.clcommon__DocCat_Attachment_Associations__r[0].clcommon__Attachment_Id__c);
                    categoryMap.put('Attachment_Name',docCat.clcommon__DocCat_Attachment_Associations__r[0].Name);
                }else{
                    categoryMap.put('HasAttachment',false);
                    categoryMap.put('Attachment_Id', null);
                    categoryMap.put('Attachment_Name',null);
                }    
                docCatfieldListMap.put(docCat.Id,categoryMap);
            }
            Integer i=0;
            for(clcommon__Document_Category__c docCat : docCatList ){
                if(docCatfieldListMap.containsKey(docCat.Id)){
                    finalListMap.add(docCatfieldListMap.get(docCat.Id));
                } 
            } 
        return finalListMap;
    }
    
    public static clcommon.Response setResponse(String status, String errorCode, String errorMessage){
        clcommon.Response res = new clcommon.Response();
        res.status = status;
        res.errorCode = errorCode;
        res.errorMessage = errorMessage;
        return res;  
    }
    
    public static clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}