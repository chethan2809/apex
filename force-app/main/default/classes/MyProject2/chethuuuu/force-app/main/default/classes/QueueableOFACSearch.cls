public with sharing class QueueableOFACSearch implements Queueable,Database.AllowsCallouts{
	List<clcommon__Party__c> requestRecords;
    clcommon__Party__c oParty;
    public QueueableOFACSearch(clcommon__Party__c reqRecords) {
        this.oParty = reqRecords;
    }

    public void execute(QueueableContext queContext) {
                ofacchecker.WSOFACScreeningService.OFACResponseWrapper oResponse;
        if(oParty.clcommon__Contact__c != null){
            oResponse = runOFACService(oParty,'Individual');
        }else{
            oResponse = runOFACService(oParty,'Entity');
        }

        if(oResponse != null && oResponse.oOFAC != null){
            ofacchecker.Utility.storeOFACData(oResponse.oOFAC, oResponse.listOFACResults);
            ofacchecker.Utility.populateOFACMatchResults(new Set<Id>{oResponse.oOFAC.Id});
        }
    }

    public static ofacchecker.WSOFACScreeningService.OFACResponseWrapper runOFACService(clcommon__Party__c oParty,String sType){
        ofacchecker.WSOFACScreeningService.OFACRequestWrapper oReqWrapper = new ofacchecker.WSOFACScreeningService.OFACRequestWrapper();
        ofacchecker.WSOFACScreeningService.OFACResponseWrapper oResponseWrapper = new ofacchecker.WSOFACScreeningService.OFACResponseWrapper();

        if(oParty != null){
            String sIndividualName = oParty.Contact_First_Name__c + ' ' + oParty.Contact_Last_Name__c;
            oReqWrapper.sFirstName = oParty.Contact_First_Name__c;
            oReqWrapper.sLastName = oParty.Contact_Last_Name__c;
            oReqWrapper.sEntityName = oParty.Account_Name__c;
            oReqWrapper.sType = sType;
            oReqWrapper.sName = sType.equalsIgnoreCase('Entity') ? oParty.Account_Name__c : sIndividualName;
            system.debug(oReqWrapper.sName);
            oReqWrapper.sParentRecordId = sType.equalsIgnoreCase('Entity') ? oParty.clcommon__Account__c : oParty.clcommon__Contact__c;
            system.debug('sParentRecordId -->'+oReqWrapper.sParentRecordId);
            oResponseWrapper = ofacchecker.WSOFACScreeningService.callOFACService(oReqWrapper);
        }
        return oResponseWrapper;
    }
}