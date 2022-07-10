global without sharing class SMB_BusinessInfoAPI implements clcommon.PortalCustomRemoteAPI1{
    String applicationId ;
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response res;
        try{
            if(params != null){
                Map<String,Object> sObjectToFieldsMaps = new Map<String,Object>();
                Map<String, String> args = new Map<String, String>{
                        'BusinessInfo1' => 'BusinessInfo',
                        'BusinessInfo2' => 'BusinessInfo',
                        'BusinessInfo3' => 'BusinessInfo',
                        'BusinessInfo4' => 'BusinessInfo',
                        'BusinessInfo' => 'BusinessInfo'
                };
                applicationId =  String.valueOf(params.get('applicationId'));
                for(String paramKey : params.KeySet()) {
                    if(params.get(paramKey) != null && args.get(paramKey) != null){
                        Map<String, Object> portalObject = (Map<String, Object>)JSON.deserializeUntyped((String)params.get(paramKey));
                        if(sObjectToFieldsMaps.containsKey(args.get(paramKey))){
                            Map<String,Object> oldMap = (Map<String,Object>)sObjectToFieldsMaps.get(args.get(paramKey));
                            oldMap.putAll(portalObject);
                        }else{
                            sObjectToFieldsMaps.put(args.get(paramKey),portalObject);
                        }
                     }
                }
                res = setSuccessResponse(sObjectToFieldsMaps,params);
            } else {
                String errorMessage = PortalConstants.ERROR_MESSAGE_PARAM_NOT_FOUND;
                res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, errorMessage);
            }
        } catch(Exception e) {
            system.debug(e.getMessage()+'---'+e.getStackTraceString());
            clcommon__Log__c comLog = new clcommon__Log__c(clcommon__Message__c = 'SMB Portal Error: '+e.getMessage()+
                                                           ' at line: '+e.getStackTraceString(),
                                                           clcommon__Time__c = System.now());
            Insert comLog;
            res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, 'Something went wrong');
        }
        return res;
    }
    private clcommon.Response setSuccessResponse(Map<String,Object> params,Map<String,Object> paramsFromPortal){
        clcommon.Response res = new clcommon.Response();
        Map<String, Object> portalObject = (Map<String, Object>)params.get('BusinessInfo');
        for(String s : portalObject.keySet()){
            system.debug(s+'--'+portalObject.get(s));
        }
        string jsonParse = JSON.serialize(params.get('BusinessInfo'));
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(jsonParse);
        String accId=  null;
        Account acc = (Account) JSON.deserialize(jsonParse, Account.class);
        if(acc.Id == null){
            Insert acc;
        } else {
            Update acc;
            accId=acc.Id;
        }
        List<genesis__Applications__c> appList = [SELECT Id,
                                                       Name,
                                                       Portal_Stage__c,
                                                       Portal_Sub_Stage__c,
                                                       genesis__Account__c
                                                    FROM genesis__Applications__c WHERE Id =:applicationId ];
        if(appList != null && appList.size() > 0){
            appList[0].Portal_Stage__c = String.valueOf(paramsFromPortal.get('portalStage'));
            appList[0].Portal_Sub_Stage__c = String.valueOf(paramsFromPortal.get('portalSubstage'));
            appList[0].genesis__Account__c = acc.Id;
            update appList;
        }
        clcommon__Party__c party = new clcommon__Party__c();
        //Check if party is already present.
        List<clcommon__Party__c> existingPartyList = [Select Id,clcommon__Account__c,clcommon__Type__c,
                                                      clcommon__Account__r.clcommon__Legal_Entity_Type__r.name from clcommon__Party__c
                                                      Where genesis__Application__c = :applicationId];
        List<clcommon__party_Type__c> typeList = [SELECT Name,Id
                                                  FROM clcommon__party_Type__c
                                                  WHERE Name in (:CustomConstants.BORROWER,:GeneralConstants.PARTY_TYPE_GUARANTOR)];
        Map<String,String> partyTypeMap = new Map<String,String>();
        for(clcommon__party_Type__c partyType : typeList) {
            partyTypeMap.put(partyType.Name,partyType.Id);
        }
        if(accId==null){
            party.clcommon__Account__c = acc.id;
            party.genesis__Application__c = applicationId;
            if(typeList!= null && typeList.size() > 0){
                party.clcommon__Type__c = partyTypeMap.get(CustomConstants.BORROWER);
            }
            insert party;
        }
        if(existingPartyList!= null && existingPartyList.size() > 0) {
            List<clcommon__Party__c> borrowerPartyList1 = new List<clcommon__Party__c>();
            for(clcommon__Party__c borrowerParty1 : existingPartyList) {
                if(borrowerParty1.clcommon__Account__r.clcommon__Legal_Entity_Type__r.name!=null && borrowerParty1.clcommon__Account__r.clcommon__Legal_Entity_Type__r.name.equals('Individual')) {
                    if(partyTypeMap!= null && partyTypeMap.size() > 0) {
                        borrowerPartyList1.add(borrowerParty1);
                    }
                }
            }
            if(borrowerPartyList1!=null && borrowerPartyList1.size()>0) {
                update borrowerPartyList1;
            }
        }
        Map<String,Object> fields = new Map<String,Object>();
        fields.put('businessAccountId',acc.id);
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        res.status = clcommon.Constants.SUCCESS;
        return res;
    }
}