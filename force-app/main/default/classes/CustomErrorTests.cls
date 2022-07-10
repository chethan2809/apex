@IsTest
private class CustomErrorTests {

    @IsTest
    private static void addError() {
        loan__Automated_Payment_Setup__c obj = new loan__Automated_Payment_Setup__c();
        String errorMessage = 'This is an Error';
        String exString;
        Test.startTest();
        try {
            CustomError.addError(obj, errorMessage);
        } catch (Exception e) {
            exString = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(errorMessage, exString);
    }

    @IsTest
    private static void castSObjectTestNote() {
        Note obj = new Note();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestGenesisApplications() {
        genesis__Applications__c obj = new genesis__Applications__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestLoanAccount() {
        loan__Loan_Account__c obj = new loan__Loan_Account__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestLoanAutomatedPaymentSetup() {
        loan__Automated_Payment_Setup__c obj = new loan__Automated_Payment_Setup__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestContact() {
        Contact obj = new Contact();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestLoanPaymentTransaction() {
        loan__Loan_Payment_Transaction__c obj = new loan__Loan_Payment_Transaction__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestGenesisAction() {
        genesis__Action__c obj = new genesis__Action__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestUser() {
        User obj = new User();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestLoanProduct() {
        loan__Loan_Product__c obj = new loan__Loan_Product__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestGenesisCompany() {
        genesis__Company__c obj = new genesis__Company__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestBankAccount() {
        loan__Bank_Account__c obj = new loan__Bank_Account__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestCANPricing() {
        CAN_Pricing_Detail__c obj = new CAN_Pricing_Detail__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectTestCategoryAssObj() {
        clcommon__Category_Attachment_Association__c obj = new clcommon__Category_Attachment_Association__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectUCCFilingObj() {
        UCC_Filing_Detail__c obj = new UCC_Filing_Detail__c();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }

    @IsTest
    private static void castSObjectContentDocumentObj() {
        ContentDocument obj = new ContentDocument();
        String errorMessage = 'This is an Error';

        String exString;
        Test.startTest();
            try {
                CustomError.castSObject(obj, errorMessage);
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(null, exString);
    }
}