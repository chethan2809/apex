public class FundingStatements {

    public static final String ACH_PROCESSOR_NAME = 'ACH (EFT Network)';

    public static String buildFundingStatementForNew(loan__Disbursal_Txn_Distribution__c disbursalRecord) {
        String salesRepresentativeName;
        if(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__c != null){
            salesRepresentativeName = disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__r.Account.Name + ' - ' + disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name;
        }else{
            salesRepresentativeName = disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name;
        }
        List<String> listOfColumns = new List<String>{
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.Merchant_ID__c),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.name),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name),
            validateStringValue(ACH_PROCESSOR_NAME),
            validateStringValue(disbursalRecord.loan__Payment_Mode__r.Name),
            validateStringValue(disbursalRecord.Funded_Source__c),
            validateStringValue(String.ValueOf(disbursalRecord.loan__Distribution_Amount__c)),
            validateStringValue(''),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c),
            validateStringValue(String.ValueOf(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Disbursed_Amt__c)),
            validateStringValue(''),
            validateStringValue(salesRepresentativeName)
        };
        return String.join(listOfColumns, ',');
    }

    public static String buildFundingStatementForRefinance(loan__Disbursal_Txn_Distribution__c disbursalRecord) {
        String salesRepresentativeName;
        if(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__c != null){
            salesRepresentativeName = disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__r.Account.Name + ' - ' + disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name;
        }else{
            salesRepresentativeName = disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name;
        }
        List<String> listOfColumns = new List<String>{
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.Merchant_ID__c),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.name),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name),
            validateStringValue(ACH_PROCESSOR_NAME),
            validateStringValue(disbursalRecord.loan__Payment_Mode__r.Name),
            validateStringValue(disbursalRecord.Funded_Source__c),
            validateStringValue(String.ValueOf(disbursalRecord.loan__Distribution_Amount__c)),
            validateStringValue(''),
            validateStringValue('Refinance'),
            validateStringValue(String.ValueOf(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Disbursed_Amt__c)),
            validateStringValue(''),
            validateStringValue(salesRepresentativeName)
        };
        return String.join(listOfColumns, ',');
    }

    public static String buildFundingStatementForConcurrent(loan__Disbursal_Txn_Distribution__c disbursalRecord) {
        String salesRepresentativeName;
        if(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__c != null){
            salesRepresentativeName = disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__r.Account.Name + ' - ' + disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name;
        }else{
            salesRepresentativeName = disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name;
        }
        List<String> listOfColumns = new List<String>{
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.Merchant_ID__c),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.name),
            validateStringValue(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name),
            validateStringValue(ACH_PROCESSOR_NAME),
            validateStringValue(disbursalRecord.loan__Payment_Mode__r.Name),
            validateStringValue(disbursalRecord.Funded_Source__c),
            validateStringValue(String.ValueOf(disbursalRecord.loan__Distribution_Amount__c)),
            validateStringValue(''),
            validateStringValue('Concurrent'),
            validateStringValue(String.ValueOf(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Disbursed_Amt__c)),
            validateStringValue(''),
            validateStringValue(salesRepresentativeName)
        };
        return String.join(listOfColumns, ',');
    }

    public static String validateStringValue(String value) {
      String stringValue = (String)value;
      if (stringValue == null) {
          return null;
      }
      return stringValue.replaceAll('\n','').replaceAll('\r','').escapeCSV();
    }
}