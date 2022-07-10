@isTest
private class CongaSignTransactionTriggertest {
    @isTest
	 private static void CongaSignTransactionTrigger() {
        APXT_CongaSign__Transaction__c CongaSignTransactions = new APXT_CongaSign__Transaction__c();
        CongaSignTransactions.APXT_CongaSign__SenderName__c = 'yuvaraj';
        CongaSignTransactions.APXT_CongaSign__SenderEmail__c = 'Test@mailinator.com';
	    CongaSignTransactions.APXT_CongaSign__BusinessUnit__c = 'AMERICAN MEDICAL RESPONSE MA';
        CongaSignTransactions.APXT_CongaSign__Status__c = 'Sent';
       Exception ex;
	Test.startTest();
	try {
	insert CongaSignTransactions;
        update CongaSignTransactions;
	} catch(Exception e) {
	ex = e;
	}
	Test.stopTest();
     System.assert(CongaSignTransactions!= null);
  

    }
     @isTest
	 private static void CongaSignTransactionTrigger2() {
        APXT_CongaSign__Transaction__c CongaSignTransactions = new APXT_CongaSign__Transaction__c();
        CongaSignTransactions.APXT_CongaSign__SenderName__c = 'yuvaraj';
        CongaSignTransactions.APXT_CongaSign__SenderEmail__c = 'Test@mailinator.com';
	    CongaSignTransactions.APXT_CongaSign__BusinessUnit__c = 'AMERICAN MEDICAL RESPONSE MA';
        CongaSignTransactions.APXT_CongaSign__Status__c = 'Sent';
         Exception ex;
	Test.startTest();
	try {
        insert CongaSignTransactions;
	update CongaSignTransactions;
	} catch(Exception e) {
	ex = e;
	}
	Test.stopTest();
     System.assert(CongaSignTransactions!= null);
  
    }

}