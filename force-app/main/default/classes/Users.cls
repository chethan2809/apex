public class Users {
    public static void setBranchFields(User userInfo) {
        userInfo.loan__Default_Branch__c = GeneralConstants.COMPANY_NAME;
        userInfo.loan__Current_Branch__c = GeneralConstants.COMPANY_NAME;
        userInfo.loan__Current_Branch_s_System_Date__c = GeneralHelper.currentSystemDate;
        userInfo.TimeZoneSidKey = GeneralConstants.TIME_ZONE_AMERICA_NEW_YORK;
    }
}