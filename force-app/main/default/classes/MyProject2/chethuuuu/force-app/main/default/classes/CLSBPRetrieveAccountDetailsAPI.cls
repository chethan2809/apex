global class CLSBPRetrieveAccountDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        Map<String,Object> fields = new Map<String,Object>();
        List<User> userLog;
        String idValue;       
        try{
            if (argumentsFromPortal.containskey('clickRecordId') && argumentsFromPortal.get('clickRecordId') != null) {
                idValue = String.valueOf(argumentsFromPortal.get('accountId'));
            }else{
                throw new CustomException('ACCOUNT_ID_IS_MISSING');
            }
            
            
            List<Account> accountDetails = [SELECT id,Name,
                                            Phone,
                                            Website,
                                            clcommon__Legal_Entity_Type__c,
                                            Industry,
                                            clcommon__Email__c,
                                            BillingAddress,
                                            ShippingAddress,
                                            BillingCity,
                                            BillingState,
                                            BillingStreet,
                                            BillingPostalCode,
                                            BillingCountry,
                                            ShippingCity,
                                            ShippingState,
                                            ShippingStreet,
                                            ShippingPostalCode,
                                            ShippingCountry,
                                            clcommon__Legal_Entity_Type__r.Name
                                            FROM Account
                                            WHERE id =: idValue];
            if(accountDetails != null && accountDetails.size() > 0){
                fields.put('Name',accountDetails[0].Name);
                fields.put('clcommon__Legal_Entity_Type__c',accountDetails[0].clcommon__Legal_Entity_Type__c);
                fields.put('Industry',accountDetails[0].Industry);
                fields.put('Phone',accountDetails[0].Phone);
                fields.put('clcommon__Email__c',accountDetails[0].clcommon__Email__c);
                fields.put('Website',accountDetails[0].Website);                
                fields.put('ShippingStreet',accountDetails[0].ShippingStreet);
                fields.put('ShippingCity',accountDetails[0].ShippingCity);
                fields.put('ShippingState',accountDetails[0].ShippingState);
                fields.put('ShippingCountry',accountDetails[0].ShippingCountry);
                fields.put('ShippingPostalCode',accountDetails[0].ShippingPostalCode);                
                fields.put('BillingStreet',accountDetails[0].BillingStreet);
                fields.put('BillingCity',accountDetails[0].BillingCity);
                fields.put('BillingState',accountDetails[0].BillingState);
                fields.put('BillingCountry',accountDetails[0].BillingCountry);
                fields.put('BillingPostalCode',accountDetails[0].BillingPostalCode); 
                fields.put('AccountId',accountDetails[0].Id);
                fields.put('ExistingAccountType','Business');
            }
            List<Contact> contactDetails = [SELECT id,Name,
                                            AccountId,
                                            Salutation,
                                            FirstName,
                                            LastName,
                                            Birthdate,
                                            Phone,
                                            MobilePhone,
                                            Email,
                                            clcommon__Years_At_Current_Address__c,
                                            clcommon__Months_at_current_address__c,
                                            ints__Driver_License__c
                                            From Contact
                                            Where Id =: idValue];
            
            if(contactDetails != null && contactDetails.size() > 0){                
                fields.put('Salutation',contactDetails[0].Salutation);
                fields.put('FirstName',contactDetails[0].FirstName);
                fields.put('LastName',contactDetails[0].LastName);
                fields.put('Birthdate',String.valueOf(contactDetails[0].Birthdate));
                fields.put('Phone',contactDetails[0].Phone);                
                fields.put('MobilePhone',contactDetails[0].MobilePhone);
                fields.put('Email',contactDetails[0].Email);
                fields.put('ContactId',contactDetails[0].Id);
                fields.put('AccountId',contactDetails[0].AccountId);
                fields.put('clcommon__Years_At_Current_Address__c',contactDetails[0].clcommon__Years_At_Current_Address__c);
                fields.put('clcommon__Months_at_current_address__c',contactDetails[0].clcommon__Months_at_current_address__c);
                fields.put('ints__Driver_License__c',contactDetails[0].ints__Driver_License__c);
                fields.put('ExistingAccountType','Individual');
            } 
            List<clcommon.PortalCustomRemoteActionRecord> records = new List<clcommon.PortalCustomRemoteActionRecord>();
            system.debug(fields);
            records.add ( new clcommon.PortalCustomRemoteActionRecord( 'response', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(records);
            response.status= genesis.Constants.SUCCESS;
            if(System.Test.IsRunningTest()) {
                throw new CustomException('708');
            }
            
        }catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse(CLSBPPortalConstants.SOMETHING_WENT_WRONG);
            return response;
        }
        system.debug(response);
        return response;        
    }
    
}