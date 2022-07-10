public class ChargeManager {

    public static void createInitialCharges(loan__Loan_Account__c loanAccount, List<loan__Charge__c> chargeList) {
        if(loanAccount.Origination_Fee__c > 0) {
            loan__Fee__c originationFee =
                    ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.ORIGINATION_FEE);
            loan__Charge__c originationCharge =  Charges.createCharge(
                    loanAccount.Id, OriginationFee.Id, GeneralHelper.currentSystemDate, loanAccount.Origination_Fee__c
                );
            chargeList.add(originationCharge);
        }

        if(loanAccount.Florida_State_Fee__c > 0) {
            loan__Fee__c floridaFee =
                ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.FLORIDA_FEE);
            loan__Charge__c floridaCharge =  Charges.createCharge(
                loanAccount.Id, floridaFee.Id, GeneralHelper.currentSystemDate, loanAccount.Florida_State_Fee__c
            );
            chargeList.add(floridaCharge);
        }
    }

    public static void createReturnCharges(
        loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount, List<loan__Charge__c> chargeList
    ) {
        if(loanAccount.Return_ACH_Fee_Applied_Date__c != oldLoanAccount.Return_ACH_Fee_Applied_Date__c) {
            Decimal amount = CustomMetaDataHelper.amountByStateIDMapping.get(loanAccount.Account_StateID__c).Amount__c;
            loan__Fee__c returnACHFee =  ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.RETURNED_ACH_FEE);
            loan__Charge__c returnedACHCharge =  Charges.createCharge(
                loanAccount.Id, returnACHFee.Id, GeneralHelper.currentSystemDate, amount > Charges.MAXIMUM_CHARGEABLE_AMOUNT ? Charges.MAXIMUM_CHARGEABLE_AMOUNT : amount
            );
            chargeList.add(returnedACHCharge);
        }

        if(loanAccount.Return_Blocked_Account_Fee_Applied_Date__c != oldLoanAccount.Return_Blocked_Account_Fee_Applied_Date__c) {
            loan__Fee__c blockedAccountFee = ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.BLOCKED_ACCOUNT_FEE);
            loan__Charge__c blockedAccountCharge =  Charges.createCharge(
                loanAccount.Id, blockedAccountFee.Id, GeneralHelper.currentSystemDate, Charges.BLOCKED_ACCOUNT_FEE_AMOUNT
            );
            chargeList.add(blockedAccountCharge);
        }
    }

    public static void createConcurrentOriginationFee(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount, List<loan__Charge__c> chargeList) {
        if(oldLoanAccount.loan__Last_Disbursal_Date__c != loanAccount.loan__Last_Disbursal_Date__c && loanAccount.loan__Expected_Disbursal_Date__c != loanAccount.loan__Last_Disbursal_Date__c){
            loan__Fee__c originationFee =
                    ServicingHelper.feeSetIdToFeesByName.get(loanAccount.loan__Fee_Set__c).get(GeneralConstants.ORIGINATION_FEE);
            loan__Charge__c originationCharge =  Charges.createCharge(
                    loanAccount.Id, OriginationFee.Id, GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, 1), (loanAccount.loan__Last_Disbursal_Amount__c * loanAccount.Origination_Fee_Percentage__c)/100
                );
            chargeList.add(originationCharge);
        }
    }
}