@isTest(isParallel=true)
private class CasesTests {
    @isTest
    private static void createCase() {

        String subject = 'NCOA Hits';
        String description = 'NCOA';
        String type = 'Customer Care';
        Id ownerId = TestUtility.getFakeId(Group.getSObjectType());

        Test.startTest();
            Case actualCase = Cases.createCase(subject, description, type, ownerId);
        Test.stopTest();

        System.assert(actualCase != Null);
        System.assertEquals(subject, actualCase.Subject);
        System.assertEquals(description, actualCase.Description);
        System.assertEquals(type, actualCase.Type);
        System.assertEquals(ownerId, actualCase.OwnerId);
    }
}