public class UserTriggerHandler {

    public void beforeInsert(List<User> userList) {
        for(User userInfo : userList) {
            Users.setBranchFields(userInfo);
        }
    }

    public void afterInsert(Map<id, User> userMap) {
        Set<Id> userIdsToUpdateUserBranchAssignment = new Set<Id>();

        for(User userInfo : userMap.values()) {
            if(userInfo.UserType == GeneralConstants.USER_TYPE_STANDARD) {
                userIdsToUpdateUserBranchAssignment.add(userInfo.Id);
            }
        }
        if(!userIdsToUpdateUserBranchAssignment.isEmpty()) {
            UserManager.createUserBranchAssignment(userIdsToUpdateUserBranchAssignment);
        }
    }
}