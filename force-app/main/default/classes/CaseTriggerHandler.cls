public class CaseTriggerHandler {

    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static CLCommonAddressDB clcommonAddressDBInstance = new CLCommonAddressDB();
    @TestVisible
    private static BankAccountDB bankAccountDBInstance = new BankAccountDB();
    @TestVisible
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    @TestVisible
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();

    public void afterUpdate(List<Case> newCase,Map<Id,Case> oldCaseMap){
        Map<Id,Id> adddressIdByAccountId = new Map<Id,Id>();
        Map<Id,Id> bankAccountIdByAccountId = new Map<Id,Id>();
        Map<Id, Id> caseIdsMap = new Map<Id, Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Case caseVar : newCase){
            if(
                (caseVar.Type == PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE || caseVar.Type == PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE) &&
                (caseVar.Status == PortalConstants.APPROVED_CASE || caseVar.Status == PortalConstants.REJECTED_CASE)
            ) {
                accountIds.add(caseVar.AccountId);
                caseIdsMap.put(caseVar.AccountId, caseVar.Id);
            }
            if(caseVar.Type == PortalConstants.CASE_TYPE_BUSINESS_ADDRESS_CHANGE && caseVar.Status == PortalConstants.APPROVED_CASE
            && oldCaseMap.get(caseVar.Id).Status != PortalConstants.APPROVED_CASE){
                adddressIdByAccountId.put(caseVar.New_Address__c,caseVar.AccountId);
            }
            else if(caseVar.Type == PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE && caseVar.Status == PortalConstants.APPROVED_CASE
            && oldCaseMap.get(caseVar.Id).Status != PortalConstants.APPROVED_CASE){
                bankAccountIdByAccountId.put(caseVar.Bank_Account__c,caseVar.AccountId);
            }
        }
        if(!adddressIdByAccountId.isEmpty()){
            List<clcommon__Address__c> addressList = clcommonAddressDBInstance.getAddresses(adddressIdByAccountId.keySet());
            for(clcommon__Address__c address : addressList){
                Account account = new Account();
                address.genesis__Active__c = false;
                account.Id = adddressIdByAccountId.get(address.Id);
                account.BillingBuildingNumber__c = address.clcommon__Address_Line_2__c;
                account.BillingStreet = address.clcommon__Street_Address__c;
                account.BillingCity = address.clcommon__City__c;
                account.BillingState = address.clcommon__State_Province__c;
                account.BillingCountry = address.clcommon__Country__c;
                account.BillingPostalCode = address.clcommon__Zip_Code__c;
                accountDBInstance.addUpdate(account);
                clcommonAddressDBInstance.addUpdate(address);
            }
            try {
                accountDBInstance.executeUpdates();
                clcommonAddressDBInstance.executeUpdates();
            }catch(Exception e){
                ErrorLogs.createErrorLog('Case Update Account Address', e.getMessage(), e.getStackTraceString(),null, 'Error', null, true);
            }
        }
        if(!bankAccountIdByAccountId.isEmpty()){
            List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getBankAccountsbyId(bankAccountIdByAccountId.keySet());
            if(!bankAccountList.isEmpty()){
                List<loan__Bank_Account__c> oldBankAccountsList = bankAccountDBInstance.getAllActiveBankAccountsByAccountIds(bankAccountIdByAccountId.values());
                for(loan__Bank_Account__c oldBankAccount : oldBankAccountsList){
                    oldBankAccount.loan__Active__c = false;
                    bankAccountDBInstance.addUpdate(oldBankAccount);
                }
                for(loan__Bank_Account__c newBankAccount : bankAccountList){
                    newBankAccount.loan__Active__c = true;
                    bankAccountDBInstance.addUpdate(newBankAccount);
                }
                try {
                    bankAccountDBInstance.executeUpdates();
                }catch(Exception e){
                    ErrorLogs.createErrorLog('Case Update Bank Account', e.getMessage(), e.getStackTraceString(),null, 'Error', null, true);
                }
            }
        }
        if(!accountIds.isEmpty()){
            Set<Id> guarantorAccountIds = new Set<Id>();
            Map<Id, Id> guarantorAccountIdsMap = new Map<Id, Id>();
            List<clcommon__Relationship__c> relatedPrimaryGuarantorsList = getGuarantorAccountIdsSet(accountIds);
            for(clcommon__Relationship__c relation : relatedPrimaryGuarantorsList){
                guarantorAccountIds.add(relation.clcommon__Related_Entity__c);
                guarantorAccountIdsMap.put(relation.clcommon__Related_Entity__c, relation.clcommon__Entity__c);
            }
            if(!guarantorAccountIds.isEmpty()){ 
                List<Contact> contactList = contactDBInstance.getRelatedGuarantorContactsByAccId(guarantorAccountIds);
                EmailNotificationHelper.sendMerchantEmailNotification(caseIdsMap, contactList, guarantorAccountIdsMap);
            }
        }
    }

    private List<clcommon__Relationship__c> getGuarantorAccountIdsSet(Set<Id> accountIds){

        List<clcommon__Relationship__c> relatedPrimaryGuarantorsList = new List<clcommon__Relationship__c>();
        try{
            List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
            List<clcommon__Reciprocal_Role__c> guarantorRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {Leads.GUARANTOR});
            Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;
            relatedPrimaryGuarantorsList = clCommonRelationshipDBInstance.getPrimaryGuarantorDetailsByBorrowerId
                                                                                            (accountIds,
                                                                                            new Set<Id> {guarantorRelationshipId});
            }
        catch(Exception e){
            ErrorLogs.createErrorLog('Get Guarantor Accounts', e.getMessage(), e.getStackTraceString(),null, 'Error', null, true);
        }
    return relatedPrimaryGuarantorsList;
    }
}