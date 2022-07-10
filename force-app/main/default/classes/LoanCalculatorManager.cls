public class LoanCalculatorManager {

    public Decimal getInterestRate(
        Decimal loanAmount, Decimal paymentAmount, Date contractDate, Date firstPaymentDate, Integer term,
        String paymentFrequency
    ) {

        Decimal rate = 0;
        Integer interestOnlyTerm = 0;
        Integer dueDay = null;
        Date lastPaymentDate = null;
        Date secondPaymentDate = null;
        Decimal balloon = 0;
        String timeCountingMethod = 'Actual Days';
        String billingMethodCode = 'Flexible Repayment';
        String repaymentProc = 'Flexible Repayment';
        String action = 'CALCULATE_RATE';
        Boolean moveAcrossMonth = false;
        String scheduleAdjustmentMethod = 'After';
        Boolean orgRoundingOn = true;
        Integer orgDigitsAfterDecimals = 2;
        String orgRoundMode = clcommon.CLConstants.ROUNDING_MODE_NEAREST;
        Boolean orgSkipHolidays = true;
        Boolean orgAdjustRoundingInLastPayment = false;
        Boolean orgFinalPaymentDifference = false;
        String orgInterestOnlyPeriodBehavior;
        Decimal orgCalculatorVersion = 3.1;
        Decimal orgRoundingFactor = 0.01;
        Boolean principalInterestRoundingOn = true;
        Map<String, Object> orgInputs = new Map<String, Object>();
        Map<String, Object> calcInputs = new Map<String, Object>();
        List<clcommon.FinancialCalculator.RepaymentSchedule> emiListemiList3;
        orgInputs.put('orgRoundingOn', orgRoundingOn);
        orgInputs.put('orgDigitsAfterDecimals', orgDigitsAfterDecimals);
        orgInputs.put('orgRoundMode', orgRoundMode);
        orgInputs.put('orgSkipHolidays', orgSkipHolidays);
        orgInputs.put(
            'orgAdjustRoundingInLastPayment',
            orgAdjustRoundingInLastPayment
        );
        orgInputs.put('orgFinalPaymentDifference', orgFinalPaymentDifference);
        orgInputs.put(
            'orgInterestOnlyPeriodBehavior',
            orgInterestOnlyPeriodBehavior
        );
        Boolean calc3Failed = false;
        calcInputs.put('Loan_Amt_c', loanAmount);
        calcInputs.put('Contract_Dt_c', contractDate);
        calcInputs.put('First_Payment_Dt_c', firstPaymentDate);
        calcInputs.put('Payment_Amt_c', 0);
        calcInputs.put('Payment_Amt_2_Start_dt_c', null);
        calcInputs.put('Payment_Amt_2_c', null);
        calcInputs.put('First_Payday_Date_c', firstPaymentDate);
        calcInputs.put('Second_Payday_Date_c', secondPaymentDate);
        calcInputs.put('Rate_c', rate);
        calcInputs.put('Term_c', term);
        calcInputs.put('Amortization_Term_c', null);
        calcInputs.put('Interest_Only_Period_c', interestOnlyTerm);
        calcInputs.put('InterestOnly_Payment_Amt_c', 0);
        calcInputs.put('Payment_Amt_c', paymentAmount);
        calcInputs.put('Balloon_Payment_Amt_c', balloon);
        calcInputs.put('Payment_Frequency_Cd_c', paymentFrequency);
        calcInputs.put('Payment_Frequency_Multiplier_c', 1);
        calcInputs.put('Time_Counting_Method_Cd_c', timeCountingMethod);
        calcInputs.put('Accrual_Base_Method_Cd_c', '365/365');
        calcInputs.put('Billing_Method_Cd_c', billingMethodCode);
        calcInputs.put('Due_Day_c', dueDay);
        calcInputs.put('Repayment_Procedure_c', repaymentProc);
        calcInputs.put('Action_c', action);
        calcInputs.put('Additional_Interest_Amt_c', 0.0);
        calcInputs.put('Financed_Fees_c', 0.0);
        calcInputs.put('Prepaid_Fees_c', 0.0);
        calcInputs.put('Recurring_Fee_Frequency_c', null);
        calcInputs.put('Principal_Interest_Rounding_On_c',principalInterestRoundingOn);
        calcInputs.put('Bank_Hours_c', GeneralHelper.businessHours);
        calcInputs.put('Schedule_Adjustment_Method_c', scheduleAdjustmentMethod);
        calcInputs.put('Move_Across_Month_c', moveAcrossMonth);
        List<clcommon.FinancialCalculator.RateSchedule> rs = new List<clcommon.FinancialCalculator.RateSchedule>();
        List<clcommon.FinancialCalculator.ProposedRepaymentSchedule> ps = new List<clcommon.FinancialCalculator.ProposedRepaymentSchedule>();
        List<clcommon.FinancialCalculator.HolidaySchedule> hs = new List<clcommon.FinancialCalculator.HolidaySchedule>();
        String msgPrefix = '';
        try {
            clcommon.LoanCalculator_v3.LoanCalculatorInput lI = new clcommon.LoanCalculator_v3.LoanCalculatorInput(
                calcInputs
            );
            clcommon.LoanCalculator_v3 fc3 = new clcommon.LoanCalculator_v3(
                orgInputs
            );
            emiListemiList3 = fc3.calculateEMI(lI, rs, ps);
            System.debug('====Interest Rate ====> ' + lI.rate_c);
            //return (lI.rate_c * 52 * 5) / 365;
            return lI.rate_c;
        } catch (Exception e) {
            system.debug(
                LoggingLevel.ERROR,
                msgPrefix +
                '[Calc3] ' +
                e.getMessage() +
                'ST: ' +
                e.getStackTraceString()
            );
            calc3Failed = true;
            throw e;
        }
    }

    public Map<String, Object> getFinalCalculationResults(
        String paymentFrequency, Date contractDate, Date firstPaymentDate, Date lastPaymentDate, Decimal loanAmount,
        Decimal financedFees, Integer term, Decimal rate
    ) {

        String testCategory = 'testHolidayTreatmentWithStepUpSchedule';
        Date secondPaymentDate;
        Decimal balloon = 0;
        Decimal apr = 0;
        String billingMethodCode = 'Flexible Repayment';
        String timeCountingMethod = 'Actual Days';
        Integer interestOnlyPeriod = 0;
        Decimal paymentAmount = 0;
        Integer interestOnlyTerm = 0;
        String accrualBaseMethodCode = '365/365';
        String testName;
        Integer dueDay = 0;

        Boolean orgRoundingOn = true;
        Integer orgDigitsAfterDecimals = 2;
        String  orgRoundMode = 'Nearest';

        Boolean orgSkipHolidays = true;
        Boolean orgAdjustRoundingInLastPayment = false;
        Boolean orgFinalPaymentDifference = false;
        String orgInterestOnlyPeriodBehavior;
        Boolean moveAcrossMonth = false;
        String scheduleAdjustmentMethod = 'After';

        BusinessHours bankHours = GeneralHelper.businessHours;

        Map<String, Object> orgInputs = new Map<String, Object>();
        Map<String, Object> calcInputs = new Map<String, Object>();
        List<clcommon.FinancialCalculator.HolidaySchedule> hs = new List<clcommon.FinancialCalculator.HolidaySchedule>();
        List<clcommon.FinancialCalculator.ProposedRepaymentSchedule> planList = new List<clcommon.FinancialCalculator.ProposedRepaymentSchedule>();
        orgInputs.put('orgRoundingOn', orgRoundingOn);
        orgInputs.put('orgDigitsAfterDecimals', orgDigitsAfterDecimals);
        orgInputs.put('orgRoundMode', orgRoundMode);
        orgInputs.put('orgSkipHolidays', orgSkipHolidays);
        orgInputs.put('orgAdjustRoundingInLastPayment', orgAdjustRoundingInLastPayment);
        orgInputs.put('orgFinalPaymentDifference', orgFinalPaymentDifference);
        if (orgInterestOnlyPeriodBehavior != null && orgInterestOnlyPeriodBehavior != '') {
            orgInputs.put('orgInterestOnlyPeriodBehavior', orgInterestOnlyPeriodBehavior);
        }

        testName = 'PD-316';

        calcInputs.put('Loan_Amt_c', loanAmount);
        calcInputs.put('Contract_Dt_c', contractDate);
        calcInputs.put('First_Payment_Dt_c', firstPaymentDate);
        calcInputs.put('First_Payday_Date_c', firstPaymentDate);
        calcInputs.put('Second_Payday_Date_c', secondPaymentDate);
        calcInputs.put('Rate_c', rate);
        calcInputs.put('Term_c', term);
        calcInputs.put('Interest_Only_Period_c', interestOnlyTerm);
        calcInputs.put('Payment_Amt_c', paymentAmount);
        calcInputs.put('Balloon_Payment_Amt_c', balloon);
        calcInputs.put('Payment_Frequency_Cd_c', paymentFrequency);
        calcInputs.put('Time_Counting_Method_Cd_c', timeCountingMethod);
        calcInputs.put('Accrual_Base_Method_Cd_c', accrualBaseMethodCode);
        calcInputs.put('Billing_Method_Cd_c', billingMethodCode);
        calcInputs.put('Action_c', 'CALCULATE_ALL');
        calcInputs.put('Bank_Hours_c', bankHours);
        calcInputs.put('Schedule_Adjustment_Method_c', scheduleAdjustmentMethod);
        calcInputs.put('Move_Across_Month_c', moveAcrossMonth);
        calcInputs.put('Due_Day_c', dueDay);
        calcInputs.put('Last_Payment_Date_c', lastPaymentDate);
        calcInputs.put('Billing_Method_Cd_c', billingMethodCode);
        //calcInputs.put('Interest_Period_Calculation_c', 'Include Start Date');

        List<clcommon.FinancialCalculator.RateSchedule> rs = new List<clcommon.FinancialCalculator.RateSchedule>();

        clcommon.FinancialCalculator.RateSchedule rSch = new clcommon.FinancialCalculator.RateSchedule();
        rSch.sequence = 1;
        rSch.startDate = Date.newInstance(2021, 03, 30);
        rSch.interestRate = null;
        rs.add(rSch);

        rSch = new clcommon.FinancialCalculator.RateSchedule();
        rSch.sequence = 2;
        rSch.startDate = Date.newInstance(2016, 10, 15);
        rSch.interestRate = null;
        rs.add(rSch);
        clcommon.LoanCalculator_v3.LoanCalculatorInput lI = new clcommon.LoanCalculator_v3.LoanCalculatorInput(calcInputs);
        String msgPrefix = '[' + testCategory + ']' + '[' + testName + ']';

        clcommon.LoanCalculator_v3 fc3 = new clcommon.LoanCalculator_v3(orgInputs);
        List<clcommon.FinancialCalculator.RepaymentSchedule> emiList = new List<clcommon.FinancialCalculator.RepaymentSchedule>();
        try {
            emiList = fc3.calculateEMI(lI, null, null);
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, msgPrefix + '[Calc3] ' + e.getMessage()  + 'ST: ' + e.getStackTraceString());
            throw e;
        }

        Map<String, Object> finalResult = new Map<String, Object>();
        Decimal totalInterest = 0.00;
        Integer numberOfPayments = emiList.size();
        System.debug('==== Number of payments ====> ' + numberOfPayments);

        for(clcommon.FinancialCalculator.RepaymentSchedule emi : emiList) {
            totalInterest += emi.interest;
            System.debug('==== emi ====> ' + emi);
        }

        finalResult.put(LoanCalculators.FIRST_PAYMENT_AMOUNT, emiList.get(0).amount);
        finalResult.put(LoanCalculators.MATURITY_DATE, emiList.get(numberOfPayments - 1).dueDate);
        finalResult.put(LoanCalculators.TOTAL_INTEREST, totalInterest);

        System.debug('==== Final Payment Result ====> ' + finalResult);
        return finalResult;
    }
}