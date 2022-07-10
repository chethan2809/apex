@isTest(isParallel=true)
private class PartyTypeDBTests {

    private static PartyTypeDB partyTypeDBInstance = new PartyTypeDB();

    @isTest
    private static void getAllPartyTypes() {

        Test.startTest();
            List<clcommon__Party_Type__c> partyTypeList = partyTypeDBInstance.getAllPartyTypes();
        Test.stopTest();

        System.assert(partyTypeList != null);
        System.assert(partyTypeList.isEmpty());
    }
}