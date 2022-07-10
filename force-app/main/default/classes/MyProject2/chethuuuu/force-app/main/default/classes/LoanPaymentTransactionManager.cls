public class LoanPaymentTransactionManager {
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void setAccountEverPaidDaysField(Set<Id> accountIds, Boolean isIncrement) {

        try{
            List<Account> accountList = accountDBInstance.getAccountByIdsForUpdate(accountIds);

            for (Account accountRecord : accountList) {

                if(isIncrement) {
                    accountRecord.Legacy_Ever_Paid_Days__c = accountRecord.Legacy_Ever_Paid_Days__c != null ? accountRecord.Legacy_Ever_Paid_Days__c + 1 : 0;
                    accountDBInstance.addUpdate(accountRecord);
                } else if (!isIncrement) {
                    accountRecord.Legacy_Ever_Paid_Days__c = accountRecord.Legacy_Ever_Paid_Days__c != null ? accountRecord.Legacy_Ever_Paid_Days__c - 1 : 0;
                    accountDBInstance.addUpdate(accountRecord);
                }
            }
            accountDBInstance.executeUpdates();
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'LoanPaymentTransactionManager Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
    }
}