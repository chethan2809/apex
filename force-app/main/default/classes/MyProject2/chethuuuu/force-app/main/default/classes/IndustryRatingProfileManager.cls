public class IndustryRatingProfileManager {

    @TestVisible
    private static IndustryRatingProfileDB industryRatingProfileDBInstance = new IndustryRatingProfileDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void calculateIndustryRating(List<genesis__Applications__c> applicationList) {
        List<String> sicCodes = new List<String>();
        for(genesis__Applications__c application :applicationList) {
            sicCodes.add(application.SIC_Code__c.left(3));
            sicCodes.add(application.SIC_Code__c.left(2));
        }

        Map<String, CAN_Industry_Rating_Profile__c> industryToRating = new Map<String, CAN_Industry_Rating_Profile__c>();
        for(CAN_Industry_Rating_Profile__c industryProfile : industryRatingProfileDBInstance.getIndustryProfilesById(sicCodes)) {
            industryToRating.put(industryProfile.Digit_Code__c, industryProfile);
        }

        for(genesis__Applications__c application : applicationList) {
            try {
                CAN_Industry_Rating_Profile__c industryProfile = getIndustryRatingProfileBySICCode(application.SIC_Code__c);
                if(industryProfile == null) {
                    throw new IndustryRatingProfileManagerException(
                        'There was no mapping record found in the Industry Rating Profile for SIC Code ' + application.SIC_Code__c
                    );
                }

                application.Industry_Rating__c = industryProfile.Industry_Rating__c;

                if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && industryProfile.Excluded_For_Renewal__c) {
                    application.Industry_Rating__c = OriginationHelper.canIndustryProfileSicDescription.get(
                        application.SIC_Code__c.left(2)
                    ).Industry_Rating__c;
                }

            } catch (Exception e) {
                application.genesis__Status__c = Applications.STATUS_INDUSTRY_CHECK_FAILED;
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Industry Check', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    application.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        errorLogDBInstance.executeInserts();
    }

    public static CAN_Industry_Rating_Profile__c getIndustryRatingProfileBySICCode(String sicCode) {
        CAN_Industry_Rating_Profile__c canIndustryRatingProfile;
        if(sicCode == null) {
            return canIndustryRatingProfile;
        }
        String threeDigitSICCode = sicCode.left(3);
        String twoDigitSICCode = sicCode.left(2);

        Map<String, CAN_Industry_Rating_Profile__c> canIndustryRatingProfileMap = OriginationHelper.canIndustryProfileSicDescription;

        if(canIndustryRatingProfileMap.containsKey(threeDigitSICCode)) {
            canIndustryRatingProfile = canIndustryRatingProfileMap.get(threeDigitSICCode);
        } else if(canIndustryRatingProfileMap.containsKey(twoDigitSICCode)) {
            canIndustryRatingProfile = canIndustryRatingProfileMap.get(twoDigitSICCode);
        }
        return canIndustryRatingProfile;
    }

    public static String getIndustryRatingDescriptionBySICCode(String sicCode) {
        CAN_Industry_Rating_Profile__c canIndustryRatingProfile = getIndustryRatingProfileBySICCode(sicCode);
        if(canIndustryRatingProfile == null) {
            return null;
        }
        return canIndustryRatingProfile.Description__c;
    }

    private class IndustryRatingProfileManagerException extends Exception {}
}