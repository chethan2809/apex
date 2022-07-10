public with sharing class AccountContactSearchCtrl {
    public AccountContactSearchCtrl() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String actName) {
        List<Account> accountList = new List<Account>();
        if(actName!='') {
            String accountName = '%' + actName + '%';
            accountList = [select id,name from Account where name like:accountName];
            return accountList;
        }
        return accountList;
    }
}