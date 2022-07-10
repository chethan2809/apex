public class ServicingHelper {
    @TestVisible
    private static FeeJunctionDB feeJunctionDBInstance = new FeeJunctionDB();
    @TestVisible
    private static FeeDB feeDBInstance = new FeeDB();
    @TestVisible
    private static PaymentModeDB paymentModeDBInstance = new PaymentModeDB();
    @TestVisible
    private static CommissionPlanDB commissionPlanDBInstance = new CommissionPlanDB();
    @TestVisible
    private static LoanPaymentSpreadDB loanPaymentSpreadDBInstance = new LoanPaymentSpreadDB();
    @TestVisible
    private static ConditionsOnSpreadDB conditionsOnSpreadDBInstance = new ConditionsOnSpreadDB();
    @TestVisible
    private static BankAccountDB bankAccountDBInstance = new BankAccountDB();

    public static Map<String, Id> paymentModeIdByName {
        get {
            if(paymentModeIdByName == null) {
                paymentModeIdByName = new Map<String, Id>();
                for(loan__Payment_Mode__c paymentMode : paymentModeDBInstance.getAllPaymentModes()) {
                    paymentModeIdByName.put(paymentMode.Name, paymentMode.Id);
                }
            }
            return paymentModeIdByName;
        }
        set;
    }
    public static Map<Id, loan__Fee__c> allActiveFeesMap {
        get {
            if (allActiveFeesMap == null) {
                allActiveFeesMap = new Map<Id, loan__Fee__c>(feeDBInstance.getAllActiveFees());
            }
            return allActiveFeesMap;
        }
        set;
    }


   public static Map<Id, Map<String, loan__Fee__c>> feeSetIdToFeesByName {
        get {
            if (feeSetIdToFeesByName == null) {
                feeSetIdToFeesByName = new  Map<Id, Map<String, loan__Fee__c>>();
                for(loan__Fee_Junction__c feeJunction : feeJunctionDBInstance.getAllActiveFeesAndFeeSets()) {
                    Id feeSetId = feeJunction.loan__Fee_Set__c;
                    if(!feeSetIdToFeesByName.containsKey(feeSetId)) {
                        feeSetIdToFeesByName.put(feeSetId, new Map<String, loan__Fee__c>());
                    }
                    loan__Fee__c fee = allActiveFeesMap.get(feeJunction.loan__Fee__c);
                    feeSetIdToFeesByName.get(feeSetId).put(fee.Name, fee);
                }
            }
            return feeSetIdToFeesByName;
        }
        set;
    }


    public static List<loan__Commission_Plan__c> brokerCommissionPlans {
        get {
            if(brokerCommissionPlans == null) {
                brokerCommissionPlans = commissionPlanDBInstance.getCommissionPlanByIds();
            }
            return brokerCommissionPlans;
        }
        set;
    }

    public static Id conditionsOnSpreadId {
        get {
            if(conditionsOnSpreadId == null) {
                List<loan__Conditions_On_Spread__c> spreadConditionList = conditionsOnSpreadDBInstance.getDefaultConditionsOnSpread();
                if(spreadConditionList.isEmpty()) {
                    throw new ServicingHelperException('Conditions On Spread is not found in the system');
                }
                conditionsOnSpreadId = spreadConditionList.get(0).Id;
            }
            return conditionsOnSpreadId;
        }
        set;
    }

    public static Id defaultPaymentSpreadId {
        get {
            if(defaultPaymentSpreadId == null) {
                List<loan__Loan_Payment_Spread__c> paymentSpreadList = loanPaymentSpreadDBInstance.getDefaultCANPaymentSpread();
                if(paymentSpreadList.isEmpty()) {
                    throw new ServicingHelperException('CAN Payment Spread is not found in the system');
                }
                defaultPaymentSpreadId = paymentSpreadList.get(0).Id;
            }
            return defaultPaymentSpreadId;
        }
        set;
    }

    public static loan__Bank_Account__c canBankAccount {
        get {
            if (canBankAccount == null) {
                List<loan__Bank_Account__c> canBankAccountList = bankAccountDBInstance.getActiveCANBankAccount();
                if(canBankAccountList.isEmpty()) {
                    throw new ServicingHelperException('There was no active bank account found for CAN Capital');
                }
                canBankAccount = canBankAccountList.get(0);
            }
            return canBankAccount;
        }
        set;
    }

    private class ServicingHelperException extends Exception {}
}