public class CustomError {
    public static void addError(SObject obj, String errorMessage) {
        if (Trigger.isExecuting) {
            castSObject(obj, errorMessage);
        } else {
            throw new CustomErrorException(errorMessage);
        }
    }

    @TestVisible
    private static void castSObject(SObject ob, String errorMessage) {
        String sObjectTypeName = String.valueOf(ob.getSObjectType());

        switch on sObjectTypeName {
            when 'Note' {
                Note n = (Note) ob;
                n.addError(errorMessage);
            } when 'genesis__Applications__c' {
                genesis__Applications__c app = (genesis__Applications__c) ob;
                app.addError(errorMessage);
            } when 'loan__Loan_Account__c' {
                loan__Loan_Account__c la = (loan__Loan_Account__c) ob;
                la.addError(errorMessage);
            } when 'loan__Automated_Payment_Setup__c' {
                loan__Automated_Payment_Setup__c aps = (loan__Automated_Payment_Setup__c) ob;
                aps.addError(errorMessage);
            } when 'Contact' {
                Contact con = (Contact) ob;
                con.addError(errorMessage);
            } when 'loan__Loan_Payment_Transaction__c' {
                loan__Loan_Payment_Transaction__c lpt = (loan__Loan_Payment_Transaction__c) ob;
                lpt.addError(errorMessage);
            } when 'genesis__Action__c' {
                genesis__Action__c act = (genesis__Action__c) ob;
                act.addError(errorMessage);
            } when 'User' {
                User u = (User) ob;
                u.addError(errorMessage);
            } when 'loan__Loan_Product__c' {
                loan__Loan_Product__c prod = (loan__Loan_Product__c) ob;
                prod.addError(errorMessage);
            } when 'genesis__Company__c' {
                genesis__Company__c comp = (genesis__Company__c) ob;
                comp.addError(errorMessage);
            } when 'loan__Bank_Account__c' {
                loan__Bank_Account__c bankAccount = (loan__Bank_Account__c) ob;
                bankAccount.addError(errorMessage);
            } when 'CAN_Pricing_Detail__c' {
                CAN_Pricing_Detail__c canPricing = (CAN_Pricing_Detail__c) ob;
                canPricing.addError(errorMessage);
            } when 'clcommon__Category_Attachment_Association__c' {
                clcommon__Category_Attachment_Association__c categoryObj = (clcommon__Category_Attachment_Association__c) ob;
                categoryObj.addError(errorMessage);
            } when 'UCC_Filing_Detail__c' {
                UCC_Filing_Detail__c uccFiling = (UCC_Filing_Detail__c) ob;
                uccFiling.addError(errorMessage);
            } when 'ContentDocument' {
                ContentDocument contentDocument = (ContentDocument) ob;
                contentDocument.addError(errorMessage);
            }
             when else {
                throw new CustomErrorException(errorMessage);
            }
        }
    }

    public class CustomErrorException extends Exception {}
}