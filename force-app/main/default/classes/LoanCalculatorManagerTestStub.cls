@isTest(isParallel=true)
public class LoanCalculatorManagerTestStub implements System.StubProvider {
    public Decimal interestRate = 20;
    public Decimal firstPaymentAmount = 100;
    public Date maturityDate = GeneralHelper.currentSystemDate.addDays(1);
    public Decimal totalInterest = 100;
    private Map<String, Object> finalResult = new Map<String, Object>();

    @TestVisible
    private LoanCalculatorManagerTestStub() {
    }

    public Object handleMethodCall(
        Object stubbedObject, String stubbedMethodName,  Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
        List<Object> listOfArgs
    ) {
        switch on stubbedMethodName {
            when 'getInterestRate' {
                return interestRate;
            }
            when 'getFinalCalculationResults' {
                finalResult.put(LoanCalculators.FIRST_PAYMENT_AMOUNT, firstPaymentAmount);
                finalResult.put(LoanCalculators.MATURITY_DATE, maturityDate);
                finalResult.put(LoanCalculators.TOTAL_INTEREST, totalInterest);
                return finalResult;
            }
            when else {
                return null;
            }
        }
    }
}