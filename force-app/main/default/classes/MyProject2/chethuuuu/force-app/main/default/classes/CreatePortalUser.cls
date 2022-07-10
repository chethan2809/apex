public class CreatePortalUser
{
    private static UserDB userDBInstance = new UserDB();
    private static ProfileDB profileDBInstance = new ProfileDB();
    private static PermissionSetDB permissionSetDBInstance = new PermissionSetDB();
    public static void createCommunityUser(List<Contact> contactList, String ProfileName, String PermissionSetName)
    {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.EmailHeader.triggerUserEmail = true;
        dmlOptions.EmailHeader.triggerAutoResponseEmail = true;
        List<User> newUserList = new List<User>();
        List<Profile> profileList = profileDBInstance.getProfileIdByNames(new set<String> {ProfileName});
        if(profileList.isEmpty()) {
            throw new CreatePortalUserException('There is no profile found with name' + ProfileName);
        }
        for(Contact contactRecord : contactList)
        {
            string nickName = contactRecord.Email != null ? contactRecord.Email.substring(0, contactRecord.email.indexOf('@')):'';
            nickName += DateTime.now().getTime();
            User newUser = new User (
                Alias = contactRecord.LastName.substring(0,2),
                Email = contactRecord.Email,
                EmailEncodingKey = 'UTF-8',
                FirstName = contactRecord.FirstName,
                LastName = contactRecord.LastName,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ContactId = contactRecord.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username = contactRecord.Email,
                CommunityNickname = nickName,
                ProfileId = profileList[0].Id,
                IsActive = true
            );
            newUser.setOptions(dmlOptions);
            newUserList.add(newUser);
        }
        try {
            userDBInstance.addUpserts(newUserList);
            userDBInstance.executeUpserts();
        } catch (Exception e) {
            system.debug('user creation error : ' + e.getMessage());
        }

        if(PermissionSetName != null)
        {
            List<PermissionSet> permissionSetList = permissionSetDBInstance.getPermissionSetsByNames(new set<String> {PermissionSetName});
            List<PermissionSetAssignment> permissionSetAssignedToBeInserted = new List<PermissionSetAssignment>();
            for(User newUser : newUserList)
            {
                for(PermissionSet permissionSet : permissionSetList) {
                    PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(PermissionSetId = permissionSet.Id, AssigneeId = newUser.Id);
                    permissionSetAssignedToBeInserted.add(permissionSetAssignment);
                }
            }
            permissionSetDBInstance.addUpserts(permissionSetAssignedToBeInserted);
            permissionSetDBInstance.executeUpserts();
        }
    }

    private class CreatePortalUserException extends Exception {}
}