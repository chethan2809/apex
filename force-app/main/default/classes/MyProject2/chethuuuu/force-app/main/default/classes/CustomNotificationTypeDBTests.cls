@isTest
private class CustomNotificationTypeDBTests {

    private static CustomNotificationTypeDB customNotificationTypeDBInstance = new CustomNotificationTypeDB();

    @isTest
    private static void customNotificationTypeIdByName() {

        Test.startTest();
            List<CustomNotificationType> notificationType = customNotificationTypeDBInstance.customNotificationTypeIdByName();
        Test.stopTest();

        System.assert(notificationType != null);
    }
}