@isTest(isParallel=true)
private class DisclosureDefinitionDBTests {

    private static DisclosureDefinitionDB disclosureDefinitionDBInstance = new DisclosureDefinitionDB();

    @isTest
    private static void getDisclosureDefinition() {
        Test.startTest();
            List<clcommon__Disclosure_Definition__c> disclosureDefinitionList = disclosureDefinitionDBInstance.getDisclosureDefinition();
        Test.stopTest();

        System.assert(disclosureDefinitionList != null);
        System.assert(disclosureDefinitionList.isEmpty());
    }
}