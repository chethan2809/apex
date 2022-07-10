public class AccountTriggerHandler {

    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    @TestVisible
    private static UCCFilingDB uccFilingDBInstance = new UCCFilingDB();
    @TestVisible
    private static UserDB userDBInstance = new UserDB();

    public void beforeInsert(List<Account> newAccountList) {
        for(Account account : newAccountList) {
            Accounts.setAccountFieldsOnBeforeInsert(account);
        }
    }

    public void afterInsert(Map<Id, Account> newAccountMap) {
        for(Account account : newAccountMap.values()) {
            Account accountRecord = new Account(Id = account.Id);
            accountRecord.Merchant_ID__c = ((account.Legacy_AccountID__c == null) ? account.Merchant_ID_Auto_Number__c : account.Legacy_AccountID__c);
            accountDBInstance.addUpdate(accountRecord);

            clcommon__Document_Definition__c documentDefinition;
            if(account.loan__Borrower__c || account.Type == Accounts.BORROWER) {
                documentDefinition = OriginationHelper.documentDefinitionByName.get(GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT);
            } else if(account.Type == Accounts.GUARANTOR) {
                documentDefinition = OriginationHelper.documentDefinitionByName.get(GeneralConstants.DOCUMENT_TYPE_EXPERIAN_CONSUMER_REPORT);
            }

            if(documentDefinition != null) {
                clcommon__Document_Category__c documentCategory = DocumentCategories.createDocumentCategory(documentDefinition);
                documentCategory.clcommon__Account__c = account.Id;
                documentCategoryDBInstance.addInsert(documentCategory);
            }

        }
        accountDBInstance.executeUpdates();
        documentCategoryDBInstance.executeInserts();
    }

    public void beforeUpdate(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap)
    {
        for (Account newAccount : newAccountMap.values()) {
            Account oldAccount = oldAccountMap.get(newAccount.Id);
            Accounts.setAccountFieldsOnBeforeUpdate(newAccount, oldAccount);
        }
    }

    public void afterUpdate(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Map<Id, Id> borrowerAccountOwnerIDMap = new Map<Id, Id>();
        Map<Id, Id> guarantorAccountOwnerIDMap = new Map<Id, Id>();
        Set<Id> negativeCANHistoryAccountIds = new Set<Id>();
        Set<Id> negativeCANHistoryGuarantorAccountIds = new Set<Id>();
        Set<Id> allAccountIds = new Set<Id>();
        Set<Id> allGuarantorAccountIds  = new Set<Id>();
        Set<Id> uccAccountIds  = new Set<Id>();
        Map<Id, Id> brokerAccountPAMIdMap = new  Map<Id, Id>();

        for (Account newAccount : newAccountMap.values()) {
            Account oldAccount = oldAccountMap.get(newAccount.Id);
            if(newAccount.OwnerId != oldAccount.OwnerId && newAccount.Type == Accounts.BORROWER) {
                borrowerAccountOwnerIDMap.put(newAccount.Id, newAccount.OwnerId);
                allAccountIds.add(newAccount.Id);
            }
            if(Accounts.isCANNegativeHistory(newAccount, oldAccount)) {
                negativeCANHistoryAccountIds.add(newAccount.Id);
                allAccountIds.add(newAccount.Id);
                Account negativeHistoryAccount = Accounts.setNegativeHistoryAccountFields(newAccount, oldAccount);
                if(negativeHistoryAccount != null) {
                    accountDBInstance.addUpdate(negativeHistoryAccount);
                }
            }
            if(newAccount.Partner_Account_Manager__c != oldAccount.Partner_Account_Manager__c && newAccount.Type == Accounts.BROKER){
                brokerAccountPAMIdMap.put(newAccount.Id, newAccount.Partner_Account_Manager__c);
            }

            if(oldAccount.UCC_Order_Number__c == null && newAccount.UCC_Order_Number__c != null && newAccount.UCC_Status__c != GeneralConstants.UCC_STATUS_ACTIVE
                && (newAccount.Legacy_Active_Contract__c && newAccount.EIS_Extend_UCC__c)
            ) {
                UCC_Filing_Detail__c uccFiling = UCCFilings.createUCCRecord(newAccount);
                if(newAccount.Legacy_Active_Contract__c) {
                    uccFiling.Approved__c = true;
                }
                uccAccountIds.add(newAccount.Id);
                uccFilingDBInstance.addInsert(uccFiling);
            }
        }
        uccFilingDBInstance.executeInserts();

        if(!uccAccountIds.isEmpty()) {
            UCCFilingManager.getOrderInformationAsync(uccAccountIds);
        }

        Id guarantorRelationshipId = GeneralHelper.reciprocalRoleIdByName.get(Accounts.GUARANTOR);

        if(!allAccountIds.isEmpty()) {
            for(clcommon__Relationship__c clCommonRelationShip : clCommonRelationshipDBInstance.getGuarantorsByBorrowerIds(
                allAccountIds, new Set<Id> {guarantorRelationshipId})
            ) {
                if(negativeCANHistoryAccountIds.contains(clCommonRelationShip.clcommon__Entity__c)) {
                    negativeCANHistoryGuarantorAccountIds.add(clCommonRelationShip.clcommon__Related_Entity__c);
                    allGuarantorAccountIds.add(clCommonRelationShip.clcommon__Related_Entity__c);
                }
                if(borrowerAccountOwnerIDMap.containsKey(clCommonRelationShip.clcommon__Entity__c)) {
                    Id borrowerAccountId = clCommonRelationship.clcommon__Entity__c;
                    Id guarantorAccountId = clCommonRelationship.clcommon__Related_Entity__c;
                    if(borrowerAccountOwnerIDMap.containsKey(borrowerAccountId)){
                        guarantorAccountOwnerIDMap.put(guarantorAccountId, borrowerAccountOwnerIDMap.get(borrowerAccountId));
                        allGuarantorAccountIds.add(guarantorAccountId);
                    }
                }
            }
        }

        if(!allGuarantorAccountIds.isEmpty()) {
            for(Contact guarantorContact : contactDBInstance.getContactsByAccountId(allGuarantorAccountIds)) {
                Id guarantorAccountId = guarantorContact.AccountId;
                if(negativeCANHistoryGuarantorAccountIds.contains(guarantorAccountId)) {
                    guarantorContact.Do_Not_Sync_With_SFMC__c = true;
                    contactDBInstance.addUpdate(guarantorContact);
                }
                if(guarantorAccountOwnerIDMap.containsKey(guarantorAccountId)) {
                    Account accountObj = new Account(Id = guarantorAccountId);
                    accountObj.OwnerId = guarantorAccountOwnerIDMap.get(guarantorAccountId);
                    accountDBInstance.addUpdate(accountObj);
                }
            }
        }

        if(!brokerAccountPAMIdMap.isEmpty()) {
            for(User userRecord : userDBInstance.getUserByAccountIds(brokerAccountPAMIdMap.keySet())){
                userRecord.Partner_Account_Manager__c = brokerAccountPAMIdMap.get(userRecord.AccountId);
                userDBInstance.addUpdate(userRecord);
            }

            userDBInstance.executeUpdates();
        }

        contactDBInstance.executeUpdates();
        accountDBInstance.executeUpdates();
    }
    private class AccountTriggerHandlerException extends Exception {}
}