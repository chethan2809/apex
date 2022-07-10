@isTest(isParallel=true)
private class PermissionSetDBTests{

    private static PermissionSetDB permissionSetDBInstance = new PermissionSetDB();

    @isTest
    private static void getPermissionSetsByNamesTest() {

        Test.startTest();
            List<PermissionSet> permissionSetList = permissionSetDBInstance.getPermissionSetsByNames(new set<String> {'SMB_Portal'});
        Test.stopTest();

        System.assert(permissionSetList != null);
    }
}