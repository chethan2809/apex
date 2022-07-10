@isTest(isParallel=true)
private class CLCommonReciprocalRoleDBTests {

    private static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();

    @isTest
    private static void getCLCommonRelationship() {
        Test.startTest();
            List<clcommon__Reciprocal_Role__c> reciprocalRole = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String>{'Test Relationship'});
        Test.stopTest();

        System.assert(reciprocalRole != null);
        System.assert(reciprocalRole.isEmpty());
    }

    @isTest
    private static void getAllCLCommonRelationship() {
        Test.startTest();
            List<clcommon__Reciprocal_Role__c> reciprocalRole = clCommonReciprocalRoleDBInstance.getAllCLCommonRelationship();
        Test.stopTest();

        System.assert(reciprocalRole != null);
        System.assert(reciprocalRole.isEmpty());
    }
}