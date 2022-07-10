global class PortalCreateUserAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static UserDB userDBInstance = new UserDB();

    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
        clcommon.Response response = new clcommon.Response();
        try{
            String contactId = (String)argumentsFromPortal.get('contactId');
            String profileName = 'BorrowerOLB';
            Id profileId = [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].id;
            User u = new User();
            Contact con = [SELECT Id, firstName, lastName, email,AccountId FROM Contact WHERE Id = :contactId];
            Id accId = [SELECT Id
                        FROM Account
                        WHERE Id = :con.AccountId Limit 1].Id;
            //create user
            u.Username = con.email;
            u.Email = con.email;
            u.contactId = con.id;
            u.CommunityNickname = con.id;
            u.FirstName = con.firstName;
            u.LastName = con.lastName;
            u.profileId  = profileId;
            u.TimeZoneSidKey = 'America/New_York';
            String userId = Site.createPortalUser(u, accId, null,true);
            String[] permissionSets = LABEL.Portal_Permission_Sets.split(';');
            List<PermissionSet> permissionSetList = [SELECT Id, Name FROM PermissionSet where name In :permissionSets];
            List<PermissionSetAssignment> permissionSetAssgnToBeInserted = new List<PermissionSetAssignment>();
            for(PermissionSet ps : permissionSetList){
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId);
                permissionSetAssgnToBeInserted.add(psa);
            }
            insert permissionSetAssgnToBeInserted;
            //Query recently created User
            u = [SELECT Id,ContactId
                                FROM User
                                WHERE Username =:con.email];
            userId = u.id;
            Map<String,Object> fields = new Map<String,Object>();
            fields.put('UserId',userId);
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        }catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    'PortalCreateUserAPI', e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
        }
        return response;
    }

    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}