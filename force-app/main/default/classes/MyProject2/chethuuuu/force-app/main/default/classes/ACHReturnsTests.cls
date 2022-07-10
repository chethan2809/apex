@isTest
private class ACHReturnsTests {

    @isTest
    private static void parseACHReturnEntryDetail() {
        List<String> achContentList = new List<String>();
        achContentList.add('6260260731890000012345       0000065950LAI000000028   OTOOLE HOUSEHOLD ');
        Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();

        Test.startTest();
            ACHReturns.parseACHReturns(achContentList, last7DigitLPTAndReasonCodeByLoanName);
        Test.stopTest();

        System.assertEquals(null, last7DigitLPTAndReasonCodeByLoanName.get('LAI-00000028'));
    }

    @isTest
    private static void parseACHReturnAddenda() {
        List<String> achContentList = new List<String>();
        achContentList.add('799R01026073180000067      22147365 ');
        Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();

        Test.startTest();
            ACHReturns.parseACHReturns(achContentList, last7DigitLPTAndReasonCodeByLoanName);
        Test.stopTest();

        System.assertEquals('R010000067', last7DigitLPTAndReasonCodeByLoanName.get(null));
    }

    @isTest
    private static void buildACHReturnList() {
        loan__Loan_Payment_Transaction__c loanPaymentTransaction = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{"Name" : "LPT-000000067" }', loan__Loan_Payment_Transaction__c.class
        );
        loanPaymentTransaction.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList = new List<loan__Loan_Payment_Transaction__c> {loanPaymentTransaction};
        String jsonLPT = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(loanPaymentTxnList, false) + '}';

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "loan__Loan_Payment_Transactions__r" : ' + jsonLPT + '}', loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c> {clContract};

        Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();
        last7DigitLPTAndReasonCodeByLoanName.put('LAI-00000018', 'R010000067');
        List<String> errorMessageList = new List<String>();

        Test.startTest();
            ACHReturns.buildACHReturnList(loanAccountList, last7DigitLPTAndReasonCodeByLoanName, errorMessageList);
        Test.stopTest();

        System.assertEquals(clContract.Id, loanAccountList[0].Id);
    }

    @isTest
    private static void buildACHReturnListNoLPT() {
        List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList = new List<loan__Loan_Payment_Transaction__c> ();
        String jsonLPT = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(loanPaymentTxnList, false) + '}';

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018" }', loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c> {clContract};

        Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();
        last7DigitLPTAndReasonCodeByLoanName.put('LAI-00000018', 'R010000067');
        List<String> errorMessageList = new List<String>();

        Test.startTest();
            ACHReturns.buildACHReturnList(loanAccountList, last7DigitLPTAndReasonCodeByLoanName, errorMessageList);
        Test.stopTest();

        System.assertEquals(clContract.Id, loanAccountList[0].Id);
    }

    @isTest
    private static void buildACHReturnListLPTReversed() {
        loan__Loan_Payment_Transaction__c loanPaymentTransaction = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{"Name" : "LPT-000000067" }', loan__Loan_Payment_Transaction__c.class
        );
        loanPaymentTransaction.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPaymentTransaction.loan__Reversed__c = true;
        List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList = new List<loan__Loan_Payment_Transaction__c> {loanPaymentTransaction};
        String jsonLPT = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(loanPaymentTxnList, false) + '}';

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "loan__Loan_Payment_Transactions__r" : ' + jsonLPT + '}', loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c> {clContract};

        Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();
        last7DigitLPTAndReasonCodeByLoanName.put('LAI-00000018', 'R010000067');
        List<String> errorMessageList = new List<String>();

        Test.startTest();
            ACHReturns.buildACHReturnList(loanAccountList, last7DigitLPTAndReasonCodeByLoanName, errorMessageList);
        Test.stopTest();

        System.assertEquals(clContract.Id, loanAccountList[0].Id);
    }

    @isTest
    private static void buildACHReturnListDifferentLPT() {
        loan__Loan_Payment_Transaction__c loanPaymentTransaction = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{"Name" : "LPT-000000067" }', loan__Loan_Payment_Transaction__c.class
        );
        loanPaymentTransaction.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPaymentTransaction.loan__Reversed__c = false;
        List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList = new List<loan__Loan_Payment_Transaction__c> {loanPaymentTransaction};
        String jsonLPT = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(loanPaymentTxnList, false) + '}';

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "loan__Loan_Payment_Transactions__r" : ' + jsonLPT + '}', loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        List<loan__Loan_Account__c> loanAccountList = new List<loan__Loan_Account__c> {clContract};

        Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();
        last7DigitLPTAndReasonCodeByLoanName.put('LAI-00000018', 'R010000071');
        List<String> errorMessageList = new List<String>();

        Test.startTest();
            ACHReturns.buildACHReturnList(loanAccountList, last7DigitLPTAndReasonCodeByLoanName, errorMessageList);
        Test.stopTest();

        System.assertEquals(clContract.Id, loanAccountList[0].Id);
    }
}