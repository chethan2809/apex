public class IndustryRatingProfileDB extends DBManager {

    public List<CAN_Industry_Rating_Profile__c> getIndustryProfiles() {
        return [
            SELECT Id, Name, Description__c, Digit_Code__c, Industry_Rating__c, Excluded_For_Renewal__c
            FROM CAN_Industry_Rating_Profile__c
        ];
    }

    public List<CAN_Industry_Rating_Profile__c> getIndustryProfilesById(List<String> sicIds) {
        return [
            SELECT Id, Name, Description__c, Digit_Code__c, Industry_Rating__c, Excluded_For_Renewal__c
            FROM CAN_Industry_Rating_Profile__c
            WHERE Digit_Code__c IN : sicIds
        ];
    }
}