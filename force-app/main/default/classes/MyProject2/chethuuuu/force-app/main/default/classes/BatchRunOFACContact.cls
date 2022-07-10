public with sharing class BatchRunOFACContact implements Database.Batchable<sObject>, Database.AllowsCallouts {

    String sQuery = System.label.BatchOFACContact;

    public BatchRunOFACContact(){

    }
    public BatchRunOFACContact(String query) {
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

        for(Contact oContact : (List<Contact>) scope) {
            ofacchecker.WSOFACScreeningService.OFACRequestWrapper oReqWrapper = new ofacchecker.WSOFACScreeningService.OFACRequestWrapper();
            oReqWrapper.sFirstname = oContact.FirstName;
            oReqWrapper.sLastName = oContact.LastName;
            //oReqWrapper.sEntityName = oAccount.Name;
            oReqWrapper.sName = oContact.Name;
            oReqWrapper.sType = 'Individual';
            oReqWrapper.sParentRecordId = oContact.Id;
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