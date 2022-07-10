public class Brokers {

    public static final String COMMISSION_CALC_METHOD_FLAT = 'Flat Amount';
    public static final String COMMISSION_CALC_METHOD_PERCENTAGE = 'Percentage Of Financed Amount';
    public static final String COMMISSION_CALC_BASED_ON_GROSS_AMOUNT = 'Gross Amount';
    public static final String COMMISSION_CALC_BASED_ON_NET_AMOUNT = 'Net Amount';
    public static final Set<String> FUNDED_SOURCES_ON_NET_AMOUNT = new Set<String> {'Merchant', 'Competitor'};
    public static final Set<String> FUNDED_SOURCES_ON_GROSS_AMOUNT = new Set<String> {'Competitor', 'Merchant', 'Repurchase', 'Crossover'};

}