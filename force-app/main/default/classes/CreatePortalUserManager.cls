public class CreatePortalUserManager
{
    private static UserDB userDBInstance = new UserDB();
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    private static ContactDB contactDBInstance = new ContactDB();
    private static ProfileDB profileDBInstance = new ProfileDB();
    private static PermissionSetDB permissionSetDBInstance = new PermissionSetDB();
    private static List<User> newUserList = new List<User>();

    public static void createCommunityUser(Set<Id> contactIds, String ProfileName, String PermissionSetName)
    {
        try {
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.EmailHeader.triggerUserEmail = true;
            dmlOptions.EmailHeader.triggerAutoResponseEmail = true;
            List<Profile> profileList = profileDBInstance.getProfileIdByNames(new set<String> {ProfileName});
            if(profileList.isEmpty()) {
                throw new CreatePortalUserManagerException('There is no profile found with name' + ProfileName);
            }
            List<Contact> contactList = contactDBInstance.getContactsByIds(contactIds);
            List<User> contactUserList = userDBInstance.getUsersByContactIds(contactIds);
            Set<Id> contactUserIds = new set<Id>();
            for (User contactUser : contactUserList) {
                contactUserIds.add(contactUser.ContactId);
            }
            for(Contact contactRecord : contactList)
            {
                if(!contactUserIds.contains(contactRecord.Id)) {
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
                        TimeZoneSidKey = 'America/New_York',
                        Username = contactRecord.Email,
                        CommunityNickname = nickName,
                        ProfileId = profileList[0].Id,
                        IsActive = CAN_General_Settings__c.getInstance().Activate_Merchant_User__c != false ? true : false
                    );
                    newUser.setOptions(dmlOptions);
                    newUserList.add(newUser);
                }
            }
            if(!newUserList.isEmpty()) {
                userDBInstance.addUpserts(newUserList);
                userDBInstance.executeUpserts();
            }
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    'user creation error : ', e.getMessage(), e.getStackTraceString(),
                    null, 'Error', null, true
                );
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
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

    private class CreatePortalUserManagerException extends Exception {}
}