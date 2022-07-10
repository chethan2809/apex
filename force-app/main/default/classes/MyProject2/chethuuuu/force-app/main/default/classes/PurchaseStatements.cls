public class PurchaseStatements {

    public static final String TOTAL_FUNDED_AMOUNT = 'totalFundedAmount';
    public static final String TOTAL_REPAYMENT_AMOUNT = 'totalRepaymentAmount';
    public static final String TOTAL_PAYMENTS = 'totalPayments';
    public static final String TOTAL_PRINCIPAL_PAID = 'totalPrincipalPaid';
    public static final String TOTAL_PRINCIPAL_BALANCE = 'totalPrincipalBalance';
    public static final String TOTAL_ACCRUED_INTEREST = 'totalAccruedInterest';
    public static final String TOTAL_NLBL_ORIGINATION_FEE = 'totalNlblOfee';
    public static final String TOTAL_WEB_BANK_ACCRUED_ORIGINATION_FEE = 'totalWebBankAccruedOfee';
    public static final String TOTAL_WRITE_OFFS = 'totalWriteOffs';
    public static final String TOTAL_LOAN_ORIGINATION_ASSISTANCE_FEE = 'totalLoanOriginationAssistanceFee';
    public static final String TOTAL_SERVICING_FEE = 'totalServicingFee';
    public static final String TOTAL_PURCHASED_LOAN_ORIGINATION_ASSISTANCE_FEE = 'totalPurchasedLoanOriginationAssistanceFee';
    public static final String TOTAL_WEB_BANK_LOAN_PURCHASE_PREMIUM = 'totalWebBankLoanPurchasePremium';
    public static final String TOTAL_RETURN_OF_FUNDING = 'totalReturnOfFunding';
    public static final String TOTAL_REFUND_AMOUNT = 'totalRefundAmount';
    public static final String TOTAL_NET_SETTLEMENT = 'totalNetSettlement';

    public static List<String> buildPurchaseStatementWrapper(
        List<loan__Loan_Disbursal_Transaction__c> loanDisbursalTransactionList, List<loan__Loan_Disbursal_Transaction__c> processedDisbursalTxnList
    ) {
        List<String> csvRowValues = new List<String>();
        Map<String, Double> summaryRowMap = setInitialSummaryRowMap();

        for(loan__Loan_Disbursal_Transaction__c disbursal : loanDisbursalTransactionList){
            List<loan__Investor_Loan__c> investmentOrderList = disbursal.Investment_Orders__r;
            if(investmentOrderList.isEmpty()) {
                continue;
            }
            loan__Investor_Loan__c investmentOrder = investmentOrderList.get(0);

            String tierName;
            WebBank_Calculations_Tier_Mapping__mdt tierMapping;

            if(disbursal.loan__Loan_Account__r.loan__Interest_Rate__c < 20){
                tierMapping = CustomMetaDataHelper.webBankCalculationsTierMappingMap.get('TIER_1');
                tierName = 'TIER 1';
            } else if(disbursal.loan__Loan_Account__r.loan__Interest_Rate__c >= 20
                && disbursal.loan__Loan_Account__r.loan__Interest_Rate__c < 40
            ){
                tierMapping = CustomMetaDataHelper.webBankCalculationsTierMappingMap.get('TIER_2');
                tierName = 'TIER 2';
            } else if(disbursal.loan__Loan_Account__r.loan__Interest_Rate__c >= 40){
                tierMapping = CustomMetaDataHelper.webBankCalculationsTierMappingMap.get('TIER_3');
                tierName = 'TIER 3';
            }

            Date originationDate = disbursal.loan__Disbursal_Date__c;
            Integer noOfDays = originationDate.daysBetween(disbursal.Repurchase_Date__c);
            Double writeOffPercent = 0.10;

            disbursal.NLBL_Origination_Fee__c =
                disbursal.loan__Loan_Account__r.Origination_Fee_Percentage__c * disbursal.Actual_Disbursed_Amount__c / 100;
            disbursal.WebBank_Accrued_Origination_Fee__c =
                (disbursal.NLBL_Origination_Fee__c * noOfDays)
                / (
                    (disbursal.loan__Disbursal_Date__c.monthsBetween(
                        disbursal.loan__Loan_Account__r.loan__Last_Installment_Date__c)) * 30
                );
            disbursal.Write_Offs__c = (disbursal.loan__Disbursed_Amt__c * writeOffPercent * (noOfDays)) / 365;
            disbursal.Loan_Origination_Assistance_Fee__c =
                disbursal.loan__Disbursed_Amt__c * (tierMapping.Loan_Origination_Assistance_Pct__c / 100 );

            Double investmentAccruedInterest = investmentOrder.loan__Inv_Accrued_Interest_Amt__c != null ?
                investmentOrder.loan__Inv_Accrued_Interest_Amt__c : 0;
            Double investmentPostedInterest = investmentOrder.loan__Inv_Interest_Posted_Amt__c != null ?
                investmentOrder.loan__Inv_Interest_Posted_Amt__c : 0;
            Double investmentInterestPaid = investmentOrder.loan__Interest_Amount_Paid__c != null ?
                investmentOrder.loan__Interest_Amount_Paid__c : 0;
            disbursal.Accrued_Interest__c = investmentAccruedInterest + investmentPostedInterest - investmentInterestPaid;
            Double disbursalAccruedInterest = investmentAccruedInterest + investmentPostedInterest;

            disbursal.Servicing_Fee__c = ((disbursal.loan__Disbursed_Amt__c * (tierMapping.Servicing_Pct__c / 100) * (noOfDays)) / 365);
            disbursal.Purchase_Loan_Origination_Assistance_Fee__c =
                (-disbursal.loan__Disbursed_Amt__c)
                    * ((
                        tierMapping.Loan_Origination_Assistance_Pct__c / 100 /
                            (disbursal.loan__Disbursal_Date__c.monthsBetween(
                                disbursal.loan__Loan_Account__r.loan__Last_Installment_Date__c)) / 30 * noOfDays
                    ) - (tierMapping.Loan_Origination_Assistance_Pct__c / 100)
                );
            disbursal.WebBank_Loan_Purchase_Premium__c =
                disbursal.loan__Disbursed_Amt__c * (tierMapping.Loan_Purchase_Premium_Pct__c / 100);
            disbursal.Net_Settlement__c =
                disbursal.loan__Disbursed_Amt__c + disbursalAccruedInterest + disbursal.WebBank_Accrued_Origination_Fee__c
                - disbursal.Write_Offs__c - disbursal.Loan_Origination_Assistance_Fee__c - disbursal.Servicing_Fee__c
                + disbursal.WebBank_Loan_Purchase_Premium__c + disbursal.Purchase_Loan_Origination_Assistance_Fee__c;

            disbursal.Total_Amount_Paid__c = investmentOrder.loan__Total_Amount_Paid__c;
            disbursal.Principal_Amount_Paid__c = investmentOrder.loan__Principal_Amount_Paid__c;
            disbursal.Remaining_Investment_Amount__c = investmentOrder.loan__Remaining_Investment_Amount__c;
            disbursal.Interest_Amount_Paid__c = investmentOrder.loan__Interest_Amount_Paid__c;

            buildTotalSummaryRowMap(disbursal, investmentOrder, summaryRowMap, disbursalAccruedInterest);
            csvRowValues.add(String.join(buildIndividualCSVRowValues(
                disbursal, investmentOrder, tierName, disbursalAccruedInterest), ',')
            );
            processedDisbursalTxnList.add(disbursal);
        }

        csvRowValues.add(String.join(buildConsolidatedResultRow(summaryRowMap), ','));
        return csvRowValues;
    }

    @TestVisible
    private static String validateStringValue(String value) {
        String stringValue = (String)value;
        if (stringValue == null) {
            return null;
        }
        return stringValue.replaceAll('\n','').replaceAll('\r','').escapeCSV();
    }

    @TestVisible
    private static Map<String, Double> setInitialSummaryRowMap(){
        Map<String, Double> summaryRowMap = new Map<String, Double>();
        summaryRowMap.put(TOTAL_FUNDED_AMOUNT, 0);
        summaryRowMap.put(TOTAL_REPAYMENT_AMOUNT, 0);
        summaryRowMap.put(TOTAL_PAYMENTS, 0);
        summaryRowMap.put(TOTAL_PRINCIPAL_PAID, 0);
        summaryRowMap.put(TOTAL_PRINCIPAL_BALANCE, 0);
        summaryRowMap.put(TOTAL_ACCRUED_INTEREST, 0);
        summaryRowMap.put(TOTAL_NLBL_ORIGINATION_FEE, 0);
        summaryRowMap.put(TOTAL_WEB_BANK_ACCRUED_ORIGINATION_FEE, 0);
        summaryRowMap.put(TOTAL_WRITE_OFFS, 0);
        summaryRowMap.put(TOTAL_LOAN_ORIGINATION_ASSISTANCE_FEE, 0);
        summaryRowMap.put(TOTAL_SERVICING_FEE, 0);
        summaryRowMap.put(TOTAL_PURCHASED_LOAN_ORIGINATION_ASSISTANCE_FEE, 0);
        summaryRowMap.put(TOTAL_WEB_BANK_LOAN_PURCHASE_PREMIUM, 0);
        summaryRowMap.put(TOTAL_RETURN_OF_FUNDING, 0);
        summaryRowMap.put(TOTAL_REFUND_AMOUNT, 0);
        summaryRowMap.put(TOTAL_NET_SETTLEMENT, 0);
        return summaryRowMap;
    }

    @TestVisible
    private static void buildTotalSummaryRowMap(
        loan__Loan_Disbursal_Transaction__c disbursal, loan__Investor_Loan__c investmentOrder, Map<String, Double> summaryRowMap,
        Double disbursalAccruedInterest
    ){
        summaryRowMap.put(TOTAL_FUNDED_AMOUNT, summaryRowMap.get(TOTAL_FUNDED_AMOUNT) + (disbursal.loan__Disbursed_Amt__c));
        summaryRowMap.put(TOTAL_REPAYMENT_AMOUNT, summaryRowMap.get(TOTAL_REPAYMENT_AMOUNT) + (disbursal.loan__Disbursed_Amt__c * disbursal.loan__Loan_Account__r.Pricing_Factor__c));
        summaryRowMap.put(TOTAL_PAYMENTS, summaryRowMap.get(TOTAL_PAYMENTS) + (investmentOrder.loan__Total_Amount_Paid__c));
        summaryRowMap.put(TOTAL_PRINCIPAL_PAID, summaryRowMap.get(TOTAL_PRINCIPAL_PAID) + (investmentOrder.loan__Principal_Amount_Paid__c));
        summaryRowMap.put(TOTAL_PRINCIPAL_BALANCE, summaryRowMap.get(TOTAL_PRINCIPAL_BALANCE) + (investmentOrder.loan__Remaining_Investment_Amount__c));
        summaryRowMap.put(TOTAL_ACCRUED_INTEREST, summaryRowMap.get(TOTAL_ACCRUED_INTEREST) + disbursalAccruedInterest);
        summaryRowMap.put(TOTAL_NLBL_ORIGINATION_FEE, summaryRowMap.get(TOTAL_NLBL_ORIGINATION_FEE) + (disbursal.NLBL_Origination_Fee__c));
        summaryRowMap.put(TOTAL_WEB_BANK_ACCRUED_ORIGINATION_FEE, summaryRowMap.get(TOTAL_WEB_BANK_ACCRUED_ORIGINATION_FEE) + disbursal.WebBank_Accrued_Origination_Fee__c);
        summaryRowMap.put(TOTAL_WRITE_OFFS, summaryRowMap.get(TOTAL_WRITE_OFFS) + disbursal.Write_Offs__c);
        summaryRowMap.put(TOTAL_LOAN_ORIGINATION_ASSISTANCE_FEE, summaryRowMap.get(TOTAL_LOAN_ORIGINATION_ASSISTANCE_FEE) + disbursal.Loan_Origination_Assistance_Fee__c);
        summaryRowMap.put(TOTAL_SERVICING_FEE, summaryRowMap.get(TOTAL_SERVICING_FEE) + disbursal.Servicing_Fee__c);
        summaryRowMap.put(TOTAL_PURCHASED_LOAN_ORIGINATION_ASSISTANCE_FEE, summaryRowMap.get(TOTAL_PURCHASED_LOAN_ORIGINATION_ASSISTANCE_FEE) + disbursal.Purchase_Loan_Origination_Assistance_Fee__c);
        summaryRowMap.put(TOTAL_WEB_BANK_LOAN_PURCHASE_PREMIUM, summaryRowMap.get(TOTAL_WEB_BANK_LOAN_PURCHASE_PREMIUM) + disbursal.WebBank_Loan_Purchase_Premium__c);
        summaryRowMap.put(TOTAL_RETURN_OF_FUNDING, 0);
        summaryRowMap.put(TOTAL_REFUND_AMOUNT, 0);
        summaryRowMap.put(TOTAL_NET_SETTLEMENT, summaryRowMap.get(TOTAL_NET_SETTLEMENT)+ disbursal.Net_Settlement__c);
    }

    @TestVisible
    private static list<string> buildIndividualCSVRowValues(
        loan__Loan_Disbursal_Transaction__c disbursal, loan__Investor_Loan__c investmentOrder, string tierName,
        Double disbursalAccruedInterest
    ){
        List<String> csvIndividualRowValues = new List<String>{
            validateStringValue(disbursal.loan__Loan_Account__r.Name),
            validateStringValue(String.valueOf(disbursal.loan__Disbursed_Amt__c)),
            validateStringValue(String.valueOf(disbursal.loan__Disbursed_Amt__c * disbursal.loan__Loan_Account__r.Pricing_Factor__c)),
            validateStringValue(String.valueOf(
                                disbursal.loan__Disbursal_Date__c.monthsBetween(
                                    disbursal.loan__Loan_Account__r.loan__Last_Installment_Date__c))
            ),
            validateStringValue(String.valueOf(investmentOrder.loan__Total_Amount_Paid__c)),
            validateStringValue(String.valueOf(investmentOrder.loan__Principal_Amount_Paid__c)),
            validateStringValue(String.valueOf(investmentOrder.loan__Remaining_Investment_Amount__c)),
            validateStringValue(String.valueOf(disbursalAccruedInterest)),
            validateStringValue(String.valueOf(disbursal.NLBL_Origination_Fee__c)),
            validateStringValue(String.valueOf(disbursal.WebBank_Accrued_Origination_Fee__c)),
            validateStringValue(String.valueOf(-disbursal.Write_Offs__c)),
            validateStringValue(String.valueOf(-disbursal.Loan_Origination_Assistance_Fee__c)),
            validateStringValue(String.valueOf(-disbursal.Servicing_Fee__c)),
            validateStringValue(String.valueOf(disbursal.Purchase_Loan_Origination_Assistance_Fee__c)),
            validateStringValue(String.valueOf(disbursal.WebBank_Loan_Purchase_Premium__c)),
            validateStringValue('0'),
            validateStringValue('0'),
            validateStringValue(String.valueOf(disbursal.Net_Settlement__c)),
            validateStringValue(String.valueOf(disbursal.loan__Loan_Account__r.loan__Interest_Rate__c)),
            validateStringValue(String.valueOf(tierName)),
            validateStringValue(String.valueOf(disbursal.loan__Loan_Account__r.loan__Frequency_of_Loan_Payment__c))
        };
        return csvIndividualRowValues;
    }

    @TestVisible
    private static list<string> buildConsolidatedResultRow(Map<String, Double> summaryRowMap){
        List<String> newTotal = new String[19];
        newTotal.set(0, 'Total');
        newTotal.set(1, String.ValueOf(summaryRowMap.get(TOTAL_FUNDED_AMOUNT)));
        newTotal.set(2, String.ValueOf(summaryRowMap.get(TOTAL_REPAYMENT_AMOUNT)));
        newTotal.set(4, String.ValueOf(summaryRowMap.get(TOTAL_PAYMENTS)));
        newTotal.set(5, String.ValueOf(summaryRowMap.get(TOTAL_PRINCIPAL_PAID)));
        newTotal.set(6, String.ValueOf(summaryRowMap.get(TOTAL_PRINCIPAL_BALANCE)));
        newTotal.set(7, String.ValueOf(summaryRowMap.get(TOTAL_ACCRUED_INTEREST)));
        newTotal.set(8, String.ValueOf(summaryRowMap.get(TOTAL_NLBL_ORIGINATION_FEE)));
        newTotal.set(9, String.ValueOf(summaryRowMap.get(TOTAL_WEB_BANK_ACCRUED_ORIGINATION_FEE)));
        newTotal.set(10, String.ValueOf(-summaryRowMap.get(TOTAL_WRITE_OFFS)));
        newTotal.set(11, String.ValueOf(-summaryRowMap.get(TOTAL_LOAN_ORIGINATION_ASSISTANCE_FEE)));
        newTotal.set(12, String.ValueOf(-summaryRowMap.get(TOTAL_SERVICING_FEE)));
        newTotal.set(13, String.ValueOf(summaryRowMap.get(TOTAL_PURCHASED_LOAN_ORIGINATION_ASSISTANCE_FEE)));
        newTotal.set(14, String.ValueOf(summaryRowMap.get(TOTAL_WEB_BANK_LOAN_PURCHASE_PREMIUM)));
        newTotal.set(15, String.ValueOf(summaryRowMap.get(TOTAL_RETURN_OF_FUNDING)));
        newTotal.set(16, String.ValueOf(summaryRowMap.get(TOTAL_REFUND_AMOUNT)));
        newTotal.set(17, String.ValueOf(summaryRowMap.get(TOTAL_NET_SETTLEMENT)));
        return newTotal;
    }

}