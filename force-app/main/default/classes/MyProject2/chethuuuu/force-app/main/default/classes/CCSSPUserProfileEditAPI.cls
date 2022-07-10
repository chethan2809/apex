global class CCSSPUserProfileEditAPI implements clcommon.PortalCustomRemoteAPI1 {
  //DB Instances
  public static AccountDB accountDBInstance = new AccountDB();
  public static ContactDB contactDBInstance = new ContactDB();
  public static CaseDB caseDBInstance = new CaseDB();
  public static UserDB userDBInstance = new UserDB();
  public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

  global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> argumentsFromPortal) {
      String errorOriginText = '';
      SavePoint dbSavePoint = Database.setSavePoint();
      clcommon.Response response = new clcommon.Response();
        try {
            if(argumentsFromPortal.containsKey(PortalConstants.PROFILE_EDIT_TYPE)){
                String editType = (String)argumentsFromPortal.get(PortalConstants.PROFILE_EDIT_TYPE);
                String loanStatus = (String)argumentsFromPortal.get('loanStatus');
                Id contactId = (Id)argumentsFromPortal.get('contactId');
                Boolean isValid = false;
                if(argumentsFromPortal.containsKey(PortalConstants.PROFILE_EDIT_CONTACT_ID_PARAM)){
                  if(argumentsFromPortal.containsKey(PortalConstants.PROFILE_EDIT_ACCOUNT_ID_PARAM)){
                    string accountId = String.valueOf(argumentsFromPortal.get('accountId'));
                    isValid = PortalSecurityUtil.validateUserByBorrowerAccountId(accountId);
                  }
                  else{
                    List<User> userList = userDBInstance.getUsersByContactIds(new Set<Id>{contactId});
                    if(!userList.isEmpty()){
                      isValid = true;
                    }
                    else{
                      isValid = false;
                    }
                  }
                  if(isValid){
                    List<Contact> contactRecords = contactDBInstance.getContactMailingAddressAndMobilePhoneByContactIds(new Set<Id>{contactId});
                    if(editType.equals(PortalConstants.PROFILE_EDIT_TYPE_HOME_ADDRESS)){
                      errorOriginText = PortalConstants.PROFILE_EDIT_TYPE_HOME_ADDRESS;
                      Contact oldContactRecord = contactRecords[0];
                      String oldAddress = oldContactRecord.MailingBuildingNumber__c == null?'':oldContactRecord.MailingBuildingNumber__c + ' ' + oldContactRecord.MailingStreet + '\n';
                      oldAddress = oldAddress + oldContactRecord.MailingCity + ' ' + oldContactRecord.MailingState + '\n';
                      oldAddress = oldAddress + oldContactRecord.MailingCountry + ' ' + oldContactRecord.MailingPostalCode;
                      String mailingState = String.valueOf(argumentsFromPortal.get('mailingState'))!=null ? String.valueOf(argumentsFromPortal.get('mailingState')) : '';
                      mailingState = mailingState.trim().replaceAll('\\s+','_');
                      State_Name_Vs_State_Code_Mapping__mdt stateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(mailingState);
                      if(stateCodeMapping != null){
                        mailingState = stateCodeMapping.short_code__c;
                      }
                      contactRecords[0].MailingBuildingNumber__c = String.valueOf(argumentsFromPortal.get('mailingBuildingNumber'))!=null ? String.valueOf(argumentsFromPortal.get('mailingBuildingNumber')) : '';
                      contactRecords[0].MailingStreet = String.valueOf(argumentsFromPortal.get('mailingStreet'))!=null ? String.valueOf(argumentsFromPortal.get('mailingStreet')) : '';
                      contactRecords[0].MailingCity = String.valueOf(argumentsFromPortal.get('mailingCity'))!=null ? String.valueOf(argumentsFromPortal.get('mailingCity')) : '';
                      contactRecords[0].MailingState = mailingState;
                      contactRecords[0].MailingCountry = String.valueOf(argumentsFromPortal.get('mailingCountry'))!=null ? String.valueOf(argumentsFromPortal.get('mailingCountry')) : '';
                      contactRecords[0].MailingPostalCode = String.valueOf(argumentsFromPortal.get('mailingPostalCode'))!=null ? String.valueOf(argumentsFromPortal.get('mailingPostalCode')) : '';
                      contactDBInstance.addUpdate(contactRecords[0]);
                      contactDBInstance.executeUpdates();

                      response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                      response.errorMessage = null;
                    }
                    else if(editType.equals(PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_ADDRESS)){
                      errorOriginText = PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_ADDRESS;
                      string accountId = String.valueOf(argumentsFromPortal.get('accountId'));
                      Set<Id> accountIdSet = new Set<ID>{accountId};
                      List<Account> account = accountDBInstance.getAccountByIds(accountIdSet);
                      clcommon__Address__c addressRecord = new clcommon__Address__c();
                      addressRecord.Name = account[0].Name + '- New Address';

                      String billingStreet = String.valueOf(argumentsFromPortal.get('billingState'))!=null ? String.valueOf(argumentsFromPortal.get('billingState')) : '';
                      billingStreet = billingStreet.trim().replaceAll('\\s+','_');
                      State_Name_Vs_State_Code_Mapping__mdt stateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(billingStreet);
                      if(stateCodeMapping != null){
                        billingStreet = stateCodeMapping.short_code__c;
                      }
                      addressRecord.clcommon__Account__c = String.valueOf(accountId)!=null ? String.valueOf(accountId) : '';
                      addressRecord.clcommon__Address_Line_2__c = String.valueOf(argumentsFromPortal.get('billingBuildingNumber'))!=null ? String.valueOf(argumentsFromPortal.get('billingBuildingNumber')) : '';
                      addressRecord.clcommon__Street_Address__c = String.valueOf(argumentsFromPortal.get('billingStreet'))!=null ? String.valueOf(argumentsFromPortal.get('billingStreet')) : '';
                      addressRecord.clcommon__City__c = String.valueOf(argumentsFromPortal.get('billingCity'))!=null ? String.valueOf(argumentsFromPortal.get('billingCity')) : '';
                      addressRecord.clcommon__State_Province__c = billingStreet;
                      addressRecord.clcommon__Country__c = String.valueOf(argumentsFromPortal.get('billingCountry'))!=null ? String.valueOf(argumentsFromPortal.get('billingCountry')) : '';
                      addressRecord.clcommon__Zip_Code__c = String.valueOf(argumentsFromPortal.get('billingPostalCode'))!=null ? String.valueOf(argumentsFromPortal.get('billingPostalCode')) : '';
                      addressRecord.genesis__Active__c = true;
                      Database.SaveResult srList = Database.insert(addressRecord, false);
                      Id newAddressId = srList.Id;
                      response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                      response.errorMessage = null;

                      //Fetching the assignment rules on case
                      AssignmentRule AR = new AssignmentRule();
                      AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                      //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                      Database.DMLOptions dmlOpts = new Database.DMLOptions();
                      dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                      dmlOpts.EmailHeader.TriggerUserEmail = true;
                      dmlOpts.EmailHeader.triggerAutoResponseEmail = true;

                      errorOriginText = PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_ADDRESS + ' - Case';
                      Case conCase = new Case();
                      conCase.AccountId = accountId;
                      conCase.New_Address__c = newAddressId;
                      conCase.Status = PortalConstants.NEW_CASE;
                      conCase.Type = PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE;
                      conCase.Origin = PortalConstants.CASE_ORIGIN;
                      conCase.Priority = PortalConstants.CASE_PRIORITY;
                      conCase.Description = PortalConstants.CASE_BUSINESS_ADDRESS_CHANGE_DESC;
                      conCase.New_Address_Text__c = addressRecord.clcommon__Address_Line_2__c == null?'':addressRecord.clcommon__Address_Line_2__c + ' ' + addressRecord.clcommon__Street_Address__c + 
                                                    '\n' + addressRecord.clcommon__City__c + ',\n' + addressRecord.clcommon__State_Province__c +
                                                    ' ' + addressRecord.clcommon__Country__c + ' ' + addressRecord.clcommon__Zip_Code__c;
                      if(conCase !=null){
                        conCase.setOptions(dmlOpts);
                        caseDBInstance.addInsert(conCase);
                        caseDBInstance.executeInserts();
                      }
                      response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                      response.errorMessage = null;
                    }
                    else if(editType.equals(PortalConstants.PROFILE_EDIT_TYPE_CONTACT_PHONE)){
                      errorOriginText = PortalConstants.PROFILE_EDIT_TYPE_CONTACT_PHONE;
                      Contact oldContactRecord = contactRecords[0];
                      String oldPhone = oldContactRecord.MobilePhone;
                      contactRecords[0].MobilePhone = String.valueOf(argumentsFromPortal.get('mobilePhone'))!=null ? String.valueOf(argumentsFromPortal.get('mobilePhone')) : '';
                      contactDBInstance.addUpdate(contactRecords[0]);
                      contactDBInstance.executeUpdates();
                      response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                      response.errorMessage = null;
                    }
                    else if(editType.equals(PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_PHONE)){
                      errorOriginText = PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_PHONE;
                      string accountId = String.valueOf(argumentsFromPortal.get('accountId'));
                      Account accountRecord = accountDBInstance.getAccountNameAndPhoneNumberById(accountId);
                      Account oldAccountRecord = accountRecord;
                      String oldAccountPhone = oldAccountRecord.Phone;
                      accountRecord.Phone = String.valueOf(argumentsFromPortal.get('businessPhone'))!=null ? String.valueOf(argumentsFromPortal.get('businessPhone')) : '';
                      accountDBInstance.addUpdate(accountRecord);
                      accountDBInstance.executeUpdates();
                      response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                      response.errorMessage = null;
                    }
                  }
                  else{
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                      PortalConstants.PROFILE_EDIT_TYPE, PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                      null, ErrorLogs.ERROR, null, true);
                      errorLogDBInstance.addInsert(errorLog);
                      errorLogDBInstance.executeInserts();
                      response.status = clcommon.Constants.API_EXCEPTION;
                      response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                  }
                }
            }
       }
       catch (Exception e) {
          Database.rollback(dbSavePoint);
          Error_Log__c errorLog = ErrorLogs.createErrorLog (
              errorOriginText, e.getMessage(), e.getStackTraceString(), null, ErrorLogs.ERROR, null, true);
          insert errorLog;
          response.status = PortalConstants.API_RESPONSE_STATUS_FAILED;
          response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
      }
      return response;
 }
}