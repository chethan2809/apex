global class PortalInitAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
                
        // Init parameter.
        String applicationId;
        String borrowerContactId;  
        STRING borrowerAccountId; 
        String coborrowerContactId;  
        STRING coborrowerAccountId;
        STRING portalStage;   
        STRING portalSubstage;
        STRING loanType;  
        String collateralId;
        String applicationCollateralId;
        Decimal loanAmount;    
        String collateralName;
        String purpose;
        Boolean isSSOUser;
        String businessAccountId;
        String assetClass;
        String status;
                
        clcommon.Response response = new clcommon.Response();
        genesis__Applications__c app = new genesis__Applications__c();
                
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        try {
            applicationId = (String)argumentsFromPortal.get('applicationId');
            String loggedInUserId = UserInfo.getUserId();
            //query user
            List<User> loggedInUser = [Select Id,
                                              AccountId,
                                              UserType,
                                              FederationIdentifier,
                                              ContactId
                                            From User
                                        Where Id = :loggedInUserId
                                        Limit 1]; 
            if(loggedInUser != null && loggedInUser.size() > 0){
                if(!String.Isblank(loggedInUser[0].AccountId)){    
                    borrowerContactId = loggedInUser[0].ContactId;
                    borrowerAccountId = loggedInUser[0].AccountId;  
                   
                    if(String.isNotBlank(loggedInUser[0].FederationIdentifier)){
                        isSSOUser = true;
                    }else{
                        isSSOUser = false;
                    }
                    if(applicationId != null){
                    
                        //query recent application of the borrower.
                        List<genesis__Applications__c> appList = [Select Id,Name,
                                                                         Portal_Stage__c,
                                                                         Portal_Sub_Stage__c,
                                                                         genesis__Asset_Class__c,
                                                                         genesis__CL_Purpose__r.Name,
                                                                         genesis__Loan_Amount__c,
                                                                         genesis__Status__c,
                                                                         (Select Id,clcommon__Type__r.Name,
                                                                                 clcommon__Account__c,
                                                                                 clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                                 clcommon__Contact__c
                                                                            From genesis__Parties__r )
                                                                    From genesis__Applications__c
                                                                   Where Id = :applicationId
                                                                   Order By CreatedDate desc limit 1];
                        
                        system.debug('-appList-'+appList);
                        if(appList != null && appList.size() > 0){
                            applicationId =  appList[0].Id;
                            portalStage = appList[0].Portal_Stage__c;
                            portalSubStage = appList[0].Portal_Sub_Stage__c;
                            purpose = appList[0].genesis__CL_Purpose__r.Name;
                            
                            loanAmount = appList[0].genesis__Loan_Amount__c;
                            assetClass = appList[0].genesis__Asset_Class__c;
                            status = appList[0].genesis__Status__c;
                            Integer numberOfCoborrowers = 0;
                            if(appList[0].genesis__Parties__r != null && 
                               appList[0].genesis__Parties__r.size() > 0){
                                List<clcommon__Party__c> partyList = appList[0].genesis__Parties__r;
                                for(clcommon__Party__c party : partyList){
                                    if(party.clcommon__Contact__c == null){
                                       if(party.clcommon__Type__r.Name.equalsIgnoreCase(GeneralConstants.PARTY_TYPE_BORROWER)){
                                           businessAccountId = party.clcommon__Account__c;
                                       }
                                    }else if(party.clcommon__Type__r.Name.equalsIgnoreCase(CustomConstants.CO_BORROWER) || party.clcommon__Type__r.Name.equalsIgnoreCase(CustomConstants.COSIGNER)){
                                        numberOfCoborrowers++;
                                        coborrowerContactId = party.clcommon__Contact__c;
                                        coborrowerAccountId = party.clcommon__Account__c; 
                                    }
                                }
                                if(numberOfCoborrowers != 1){
                                    coborrowerContactId = null;
                                    coborrowerAccountId = null;
                                }
                                //coborrowerContactId = appList[0].genesis__Parties__r[0].clcommon__Contact__c;
                                //coborrowerAccountId = appList[0].genesis__Parties__r[0].clcommon__Account__c; 
                            }
                        }
                    }
                    /*else{
                        response.Status = 'SUCCESS';
                        return response; 
                    }*/
                } else{
                    
                }   
            }else{
                return getErrorResponse(PortalConstants.ERROR_MESSAGE);  
                     
            }
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            //response = getErrorResponse('Something went wrong.');
            response = getErrorResponse(e.getMessage() + '---'+e.getStackTraceString());
            return response;
        }
        String userIdNew = UserInfo.getUserId();         
        Map<String,Object> fields = new Map<String,Object>();
        fields.put('applicationId',applicationId);
        fields.put('borrowerContactId',borrowerContactId); 
        fields.put('borrowerAccountId',borrowerAccountId); 
        fields.put('coborrowerContactId',coborrowerContactId);         
        fields.put('coborrowerAccountId',coborrowerAccountId); 
        fields.put('portalStage',portalStage);         
        fields.put('portalSubstage',portalSubStage); 
        fields.put('purpose',purpose);      
        fields.put('loggedInUserId',userIdNew); 
        fields.put('collateralId',collateralId);        
        fields.put('applicationCollateralId',applicationCollateralId); 
        fields.put('loanAmount',loanAmount); 
        fields.put('isSSOUser',isSSOUser); 
        fields.put('collateralName',collateralName); 
        fields.put('businessAccountId',businessAccountId);  
        fields.put('assetClass',assetClass); 
        fields.put('status',status); 
                
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
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