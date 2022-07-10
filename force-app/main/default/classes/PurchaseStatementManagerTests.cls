@isTest
private class PurchaseStatementManagerTests {

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockFail implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Failure Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(404);
            return res;
        }
    }

    @isTest
    private static void purchaseStatementUploadTest() {
        Test.setMock(HttpCalloutMock.class, new RestMock());

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        list<loan__Loan_Disbursal_Transaction__c> disbursementList = new list<loan__Loan_Disbursal_Transaction__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "Loan Account",  "loan__Total_Interest_Amortization_Based__c" : "10000", "loan__Total_Amount_Paid__c" : "299"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Origination_Fee__c = 30;
        loanAccount.Origination_Fee_Percentage__c = 3;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(60);
        loanAccount.loan__Interest_Rate__c = 10;
        loanAccount.Pricing_Factor__c = 1.2;
        loanAccount.loan__Number_of_Installments__c = 12;

        loan__Investor_Loan__c investmentOrder = (loan__Investor_Loan__c) JSON.deserialize(
            '{"loan__Total_Amount_Paid__c" : "10", "loan__Remaining_Investment_Amount__c" : "10"}', loan__Investor_Loan__c.class
        );
        investmentOrder.Id = TestUtility.getFakeId(loan__Investor_Loan__c.getSObjectType());
        investmentOrder.loan__Inv_Accrued_Interest_Amt__c = 10;
        investmentOrder.loan__Principal_Amount_Paid__c = 10;

        List<loan__Investor_Loan__c> investmentOrderList = new List<loan__Investor_Loan__c>{investmentOrder};
        String jsonInvestmentOrderList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(investmentOrderList, false) + '}';

        loan__Loan_Disbursal_Transaction__c disbursal = (loan__Loan_Disbursal_Transaction__c) JSON.deserialize(
            '{ "Investment_Orders__r" : ' + jsonInvestmentOrderList + ' }', loan__Loan_Disbursal_Transaction__c.class
        );
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccount;
        disbursal.WebBank_Accrued_Origination_Fee__c = 20;
        disbursal.Write_Offs__c = 15;
        disbursal.Loan_Origination_Assistance_Fee__c=30;
        disbursal.Servicing_Fee__c = 20;
        disbursal.Purchase_Loan_Origination_Assistance_Fee__c = 100;
        disbursal.WebBank_Loan_Purchase_Premium__c = 20;
        disbursal.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        disbursal.Repurchase_Date__c = GeneralHelper.currentSystemDate.addDays(15);
        disbursal.Net_Settlement__c = 100;
        disbursal.loan__Disbursed_Amt__c = 1000;
        disbursementList.add(disbursal);

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';

        Folder folderDetail = new Folder();
        folderDetail.Name = 'Purchase Statement';
        folderDetail.Id = TestUtility.getFakeId(Folder.getSObjectType());

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        PurchaseStatementManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        Test.startTest();
                PurchaseStatementManager.uploadPurchaseStatement(disbursementList);
        Test.stopTest();

        System.assertEquals(1, documentDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void purchaseStatementUploadFailedTest() {
        Test.setMock(HttpCalloutMock.class, new RestMockFail());

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        list<loan__Loan_Disbursal_Transaction__c> disbursementList = new list<loan__Loan_Disbursal_Transaction__c>();

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "Loan Account",  "loan__Total_Interest_Amortization_Based__c" : "10000", "loan__Total_Amount_Paid__c" : "299"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Origination_Fee__c = 30;
        loanAccount.Origination_Fee_Percentage__c = 3;
        loanAccount.loan__Disbursed_Amount__c = 1000;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addDays(60);
        loanAccount.loan__Interest_Rate__c = 10;
        loanAccount.Pricing_Factor__c = 1.2;
        loanAccount.loan__Number_of_Installments__c = 12;

        loan__Investor_Loan__c investmentOrder = (loan__Investor_Loan__c) JSON.deserialize(
            '{"loan__Total_Amount_Paid__c" : "10", "loan__Remaining_Investment_Amount__c" : "10"}', loan__Investor_Loan__c.class
        );
        investmentOrder.Id = TestUtility.getFakeId(loan__Investor_Loan__c.getSObjectType());
        investmentOrder.loan__Inv_Accrued_Interest_Amt__c = 10;
        investmentOrder.loan__Principal_Amount_Paid__c = 10;

        List<loan__Investor_Loan__c> investmentOrderList = new List<loan__Investor_Loan__c>{investmentOrder};
        String jsonInvestmentOrderList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(investmentOrderList, false) + '}';

        loan__Loan_Disbursal_Transaction__c disbursal = (loan__Loan_Disbursal_Transaction__c) JSON.deserialize(
            '{ "Investment_Orders__r" : ' + jsonInvestmentOrderList + ' }', loan__Loan_Disbursal_Transaction__c.class
        );
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursal.loan__Loan_Account__r = loanAccount;
        disbursal.WebBank_Accrued_Origination_Fee__c = 20;
        disbursal.Write_Offs__c = 15;
        disbursal.Loan_Origination_Assistance_Fee__c=30;
        disbursal.Servicing_Fee__c = 20;
        disbursal.Purchase_Loan_Origination_Assistance_Fee__c = 100;
        disbursal.WebBank_Loan_Purchase_Premium__c = 20;
        disbursal.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        disbursal.Repurchase_Date__c = GeneralHelper.currentSystemDate.addDays(15);
        disbursal.Net_Settlement__c = 100;
        disbursal.loan__Disbursed_Amt__c = 1000;

        disbursementList.add(disbursal);

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';

        Folder folderDetail = new Folder();
        folderDetail.Name = 'Purchase Statement';
        folderDetail.Id = TestUtility.getFakeId(Folder.getSObjectType());

        Map<String, Folder> folderByFolderName = new Map<String, Folder>();
        folderByFolderName.put(folderDetail.Name, folderDetail);
        GeneralHelper.folderByFolderName = folderByFolderName;

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        PurchaseStatementManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        PurchaseStatementManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            try {
                PurchaseStatementManager.uploadPurchaseStatement(disbursementList);
            }
            catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}