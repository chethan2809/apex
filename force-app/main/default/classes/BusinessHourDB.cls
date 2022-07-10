public class BusinessHourDB extends DBManager {
    public List<BusinessHours> getOrgActiveBusinessHours() {
        return  [SELECT Id FROM BusinessHours WHERE IsActive = true AND IsDefault = true LIMIT 1];
    }
}