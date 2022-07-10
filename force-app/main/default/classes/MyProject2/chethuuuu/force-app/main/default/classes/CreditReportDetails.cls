public class CreditReportDetails {
    public static final String TYPE_EXPERIAN_CONSUMER = 'Experian Consumer';
    public static final String TYPE_EXPERIAN_BUSINESS = 'Experian Business';
    public static final String TYPE_LEXISNEXIS = 'Lexis Nexis';
    public static final String TYPE_CAN_SCORING = 'CAN Scoring';

    public static void calculateSICCodeAndTimeInBusiness(
        List<Credit_Report_Detail__c> creditReportList, genesis__Applications__c application
    ) {
        String lexisNexisSICCod;
        String experianSICCode;
        Date experianBusinessStartDate;
        Integer lexisNexisYearsInBusiness;
        Decimal experianBusYearsInBusiness;
        Decimal applicationBusinessInYears = application.Business_Start_Date__c.daysBetween(GeneralHelper.currentSystemDate) / 365;

        for(Credit_Report_Detail__c creditReportDetail : creditReportList) {
            if(creditReportDetail.Type__c == TYPE_EXPERIAN_BUSINESS) {
                experianSICCode = creditReportDetail.SIC_Code__c != null? creditReportDetail.SIC_Code__c : null;
                if(creditReportDetail.Business_Start_Date__c != null) {
                    experianBusYearsInBusiness = creditReportDetail.Business_Start_Date__c.daysBetween(GeneralHelper.currentSystemDate) / 365;
                    experianBusinessStartDate = creditReportDetail.Business_Start_Date__c;
                }
            } else if(creditReportDetail.Type__c == TYPE_LEXISNEXIS) {
                lexisNexisSICCod = creditReportDetail.SIC_Code__c != null? creditReportDetail.SIC_Code__c : null;
                if(creditReportDetail.Business_First_Seen_YYYY__c != null) {
                    Date lexisNexisBusinessStartDate = Date.newInstance(
                        Integer.valueOf(creditReportDetail.Business_First_Seen_YYYY__c), 01, 01
                    );
                    lexisNexisYearsInBusiness = lexisNexisBusinessStartDate.daysBetween(GeneralHelper.currentSystemDate) / 365;
                }
            }
        }

        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW) {
            application.SIC_Code__c = getSICCode(experianSICCode, lexisNexisSICCod, application.SIC_Code__c);
        }

        if((experianBusYearsInBusiness != null && lexisNexisYearsInBusiness != null
                && experianBusYearsInBusiness < 3 && lexisNexisYearsInBusiness < 3 && applicationBusinessInYears >= 3)
        ) {
            application.Business_Start_Date__c = experianBusinessStartDate;
        }
    }

    public static String getSICCode(String experianSICCode, String lexisNexisSICCod, String applicationSICCode) {
        String experianThreeDigitSICCode;
        String experianTwoDigitSICCode;
        String appThreeDigitSICCode;
        String appTwoDigitSICCode;
        String lexisNexisThreeDigitSICCode;
        String lexisNexisTwoDigitSICCode;

        if(experianSICCode != null) {
            experianThreeDigitSICCode = experianSICCode.left(3);
            experianTwoDigitSICCode = experianSICCode.left(2);
        }
        if(applicationSICCode != null) {
            appThreeDigitSICCode = applicationSICCode.left(3);
            appTwoDigitSICCode = applicationSICCode.left(2);
        }
        if(lexisNexisSICCod != null) {
            lexisNexisThreeDigitSICCode = lexisNexisSICCod.left(3);
            lexisNexisTwoDigitSICCode = lexisNexisSICCod.left(2);
        }

        if(experianSICCode != null && lexisNexisSICCod != null) {
            if((experianThreeDigitSICCode == lexisNexisThreeDigitSICCode && experianThreeDigitSICCode != appThreeDigitSICCode
                    && experianThreeDigitSICCode.length() == appThreeDigitSICCode.length()
                    && lexisNexisThreeDigitSICCode.length() == appThreeDigitSICCode.length()
                )
                || (experianTwoDigitSICCode == lexisNexisTwoDigitSICCode && experianTwoDigitSICCode != appTwoDigitSICCode
                    && experianTwoDigitSICCode.length() == appTwoDigitSICCode.length()
                    && lexisNexisTwoDigitSICCode.length() == appTwoDigitSICCode.length()
                )
            ) {
                return experianSICCode;
            } else if((experianTwoDigitSICCode != lexisNexisTwoDigitSICCode && experianTwoDigitSICCode != appTwoDigitSICCode
                    && lexisNexisTwoDigitSICCode != appTwoDigitSICCode
                    && experianTwoDigitSICCode.length() == appTwoDigitSICCode.length()
                    && lexisNexisTwoDigitSICCode.length() == appTwoDigitSICCode.length()
                )
                || (experianThreeDigitSICCode != lexisNexisThreeDigitSICCode && experianThreeDigitSICCode != appThreeDigitSICCode
                    && lexisNexisThreeDigitSICCode != appThreeDigitSICCode
                    && experianThreeDigitSICCode.length() == appThreeDigitSICCode.length()
                    && lexisNexisThreeDigitSICCode.length() == appThreeDigitSICCode.length()
                )
            ) {
                return GeneralConstants.DEFAULT_SIC_CODE;
            }
        }
        else if(((experianSICCode == null && lexisNexisTwoDigitSICCode != null && lexisNexisTwoDigitSICCode != appTwoDigitSICCode
                    && lexisNexisTwoDigitSICCode.length() == appTwoDigitSICCode.length()
                ) || (experianSICCode == null && lexisNexisThreeDigitSICCode != null && lexisNexisThreeDigitSICCode != appThreeDigitSICCode
                    && lexisNexisThreeDigitSICCode.length() == appThreeDigitSICCode.length()
                )
            )
            || ((lexisNexisSICCod == null && experianTwoDigitSICCode != null && experianTwoDigitSICCode != appTwoDigitSICCode
                    && experianTwoDigitSICCode.length() == appTwoDigitSICCode.length()
                ) || (lexisNexisSICCod == null && experianThreeDigitSICCode != null && experianThreeDigitSICCode != appThreeDigitSICCode
                    && experianThreeDigitSICCode.length() == appThreeDigitSICCode.length()
                )
            )
        ) {
            return GeneralConstants.DEFAULT_SIC_CODE;
        }
        return applicationSICCode;
    }
}