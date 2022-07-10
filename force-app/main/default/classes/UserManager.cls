public class UserManager {
    @TestVisible
    private static UserDB userDBInstance = new UserDB();
    @TestVisible
    private static UserBranchInfoDB userBranchInfoDBInstance = new UserBranchInfoDB();
    @TestVisible
    private static LoanOfficeNameDB loanOfficeNameDBInstance = new LoanOfficeNameDB();

    public static void updateCommunityUserDetailsOnSystemDateChange(Date branchDate) {

        List<User> communityUserList = userDBInstance.getUserDetailsByProfileIds(new Set<Id> {
            GeneralHelper.profileByName.get(GeneralConstants.MERCHANT_USER_PROFILE_NAME).Id,
            GeneralHelper.profileByName.get(GeneralConstants.BROKER_USER_PROFILE_NAME).Id
        });

        for(User userRecord : communityUserList) {
            userRecord.loan__Current_Branch_s_System_Date__c = branchDate;
            userDBInstance.addUpdate(userRecord);
        }

        userDBInstance.executeUpdates();
    }

    @future
    public static void createUserBranchAssignment(Set<Id> userIds) {
        List<loan__Office_Name__c> loanOfficeNameDetails = loanOfficeNameDBInstance.getLoanOfficeName();

        if(!loanOfficeNameDetails.isEmpty()) {
            for(Id userId : userIds) {
                loan__User_Branch_Info__c userBranchInfo = new loan__User_Branch_Info__c();
                userBranchInfo.loan__Branch__c = loanOfficeNameDetails.get(0).Id;
                userBranchInfo.loan__Default_Branch__c = true;
                userBranchInfo.loan__User__c = userId;
                userBranchInfoDBInstance.addInsert(userBranchInfo);
            }

            userBranchInfoDBInstance.executeInserts();
        }
    }
}