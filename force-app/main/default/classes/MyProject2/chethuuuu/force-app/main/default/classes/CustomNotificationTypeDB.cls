public class CustomNotificationTypeDB extends DBManager {
    public List<CustomNotificationType> customNotificationTypeIdByName() {
        return [
            SELECT Id,DeveloperName
            FROM CustomNotificationType
        ];
    }
}