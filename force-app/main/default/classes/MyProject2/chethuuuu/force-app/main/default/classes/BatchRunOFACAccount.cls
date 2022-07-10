public with sharing class BatchRunOFACAccount implements Database.Batchable<sObject>, Database.AllowsCallouts {

    String sQuery = System.label.BatchOFACAccount;

    public BatchRunOFACAccount(){

    }
    public BatchRunOFACAccount(String query) {
        if(String.isNotBlank(query)) {
            sQuery = query;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(sQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        ofacchecker.WSOFACScreeningService.OFACResponseWrapper oOFACResponseWrapper = null;
        Integer delayInMilliseconds;

        for(Account oAccount : (List<Account>) scope) {
            ofacchecker.WSOFACScreeningService.OFACRequestWrapper oReqWrapper = new ofacchecker.WSOFACScreeningService.OFACRequestWrapper();
            //oReqWrapper.sFirstname = oAccount.FirstName;
            //oReqWrapper.sLastName = oAccount.LastName;
            oReqWrapper.sEntityName = oAccount.Name;
            oReqWrapper.sName = oAccount.Name;
            oReqWrapper.sType = 'Entity';
            oReqWrapper.sParentRecordId = oAccount.Id;
            oOFACResponseWrapper = ofacchecker.WSOFACScreeningService.callOFACService(oReqWrapper);
        }

        if( oOFACResponseWrapper != null &&
           oOFACResponseWrapper.oOFAC != null
          ) {
              ofacchecker.Utility.storeOFACData(oOFACResponseWrapper.oOFAC, oOFACResponseWrapper.listOFACResults);
              ofacchecker.Utility.populateOFACMatchResults(new Set<Id>{oOFACResponseWrapper.oOFAC.Id});
          }

        //this is to handle the Throttling limit
        ofacchecker__OFAC_Settings__c oSetting = ofacchecker__OFAC_Settings__c.getInstance('ThrottlingTimeLimit');
        Long startingTime = System.now().getTime(); // Num milliseconds
        if(oSetting != null){
            delayInMilliseconds = String.isNotBlank(oSetting.ofacchecker__Value__c) ? Integer.valueOf(oSetting.ofacchecker__Value__c) : 750; // Half-second delay
        }
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {}
    }

    public void finish(Database.BatchableContext BC) {
        //Schedule the next run of the Batch
    }

}