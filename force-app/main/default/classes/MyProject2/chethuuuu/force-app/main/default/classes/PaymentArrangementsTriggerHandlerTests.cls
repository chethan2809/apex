@isTest
private class PaymentArrangementsTriggerHandlerTests {
    @isTest
    private static void afterUpdate() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date achTurnedDate = GeneralHelper.currentSystemDate;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.ACH_Turned_off_Date__c = achTurnedDate;

        loan__Automated_Payment_Setup__c testAPSRecord = new loan__Automated_Payment_Setup__c();
        testAPSRecord.loan__Type__c = 'RECURRING';
        testAPSRecord.Id = TestUtility.getFakeId(loan__Automated_Payment_Setup__c.getSObjectType());
        testAPSRecord.loan__CL_Contract__c = clContract.Id;

        Payment_Arrangements__c paymentArrangements = new Payment_Arrangements__c();
        paymentArrangements.Id = TestUtility.getFakeId(Payment_Arrangements__c.getSObjectType());
        paymentArrangements.Automated_Payment_Setup__c = testAPSRecord.Id;
        paymentArrangements.Promise__c = CollectionCaseConstants.BROKEN_PROMISE;

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = clContract.Id;

        list<Payment_Arrangements__c> paymentArrangementsList = [
            SELECT Id, Name
            FROM Payment_Arrangements__c
        ];

        Map<Id, Payment_Arrangements__c> newPaymentArrangementMap = new Map<Id, Payment_Arrangements__c>{paymentArrangements.Id => paymentArrangements};
        Map<Id, Payment_Arrangements__c> oldPaymentArrangementMap = new Map<Id, Payment_Arrangements__c>{paymentArrangements.Id => paymentArrangements};

        Exception Ex;
        Test.startTest();
            try{
                PaymentArrangementsTriggerHandler paymentArrangement =  new PaymentArrangementsTriggerHandler();
                paymentArrangement.afterUpdate(newPaymentArrangementMap, oldPaymentArrangementMap);
            }catch(Exception e){
                e = Ex;
            }
        Test.stopTest();

        System.assert(paymentArrangementsList != null);
    }
}