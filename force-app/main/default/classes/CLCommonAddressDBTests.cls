@isTest(isParallel=true)
private class CLCommonAddressDBTests {

    private static CLCommonAddressDB clcommonAddressDBInstance = new CLCommonAddressDB();

    @isTest
    private static void getAddresses() {
        Id addressId = TestUtility.getFakeId(clcommon__Address__c.getSObjectType());
        Set<Id> addressIds = new Set<Id>();
        addressIds.add(addressId);

        Test.startTest();
            List<clcommon__Address__c> addressList = clcommonAddressDBInstance.getAddresses(addressIds);
        Test.stopTest();

        System.assert(addressList != null);
        System.assert(addressList.isEmpty());
    }
}