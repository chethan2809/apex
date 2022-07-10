public class StubPractiseClass1 {
    public static StubPractiseAccountDB stubPractiseAccountDBInstance = new StubPractiseAccountDB();
    public static StubPractiseContactDB stubPractiseContactDBInstance = new StubPractiseContactDB();
    public static void getAccountByIds(Set<Id> accountIds){
        List<AggregateResult> disbursalAggregationResultList;
        List<Account> accountList = stubPractiseAccountDBInstance.getAccountByIds(accountIds);
        System.debug('<<<Accs>>>'+accountList);
        
        List<Contact> contactList = stubPractiseContactDBInstance.getContactsByAccountIds(accountIds);
        System.debug('<<<contactList>>>'+contactList);
        
        List<Account> allAccountList = stubPractiseAccountDBInstance.getAllAccounts();
        System.debug('<<allAccountList>>'+allAccountList);
        
        disbursalAggregationResultList = stubPractiseAccountDBInstance.getAggregateByAccountIds(accountIds);
        System.debug('disbursalAggregationResultList...'+disbursalAggregationResultList);
    }
}