public class GeneralHelper {

    @TestVisible
    private static FolderDB folderDBInstance = new FolderDB();
    @TestVisible
    private static GroupDB groupDBInstance = new GroupDB();
    @TestVisible
    private static SiteDB siteDBInstance = new SiteDB();
    @TestVisible
    private static BusinessHourDB businessHourDBInstance = new BusinessHourDB();
    @TestVisible
    private static OrgWideEmailAddressDB orgWideEmailAddressDBInstance = new OrgWideEmailAddressDB();
    @TestVisible
    private static ProfileDB profileDBInstance = new ProfileDB();
    @TestVisible
    private static CustomNotificationTypeDB customNotificationTypeDBInstance = new CustomNotificationTypeDB();
    @TestVisible
    private static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    @TestVisible
    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();

    public static Date currentSystemDate {
        get {
            if (currentSystemDate == null) {
                currentSystemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
            }
            return currentSystemDate;
        }
        set;
    }

    public static DateTime currentSystemDateTime {
        get {
            return DateTime.newInstance(currentSystemDate, DateTime.Now().Time());
        }
        set;
    }

    public static String domainUrl {
        get {
            if (domainUrl == null) {
                domainUrl = Url.getSalesforceBaseUrl().toExternalForm();
            }
            return domainUrl;
        }
        set;
    }

    public static Date getNBusinessDate(Date startDate, integer businessDaysToAdd ) {
        Date finalDate = startDate;
        integer direction = businessDaysToAdd < 0 ? -1 : 1;
        while(businessDaysToAdd != 0) {
            finalDate = finalDate.AddDays(direction);
            if (!isWeekend(finalDate)) {
                businessDaysToAdd -= direction;
            }
        }

        return finalDate;
    }

    public static Boolean isWeekend(Date dateParam) {
        DateTime dayOfWeekDate = DateTime.newInstance(dateParam.year(), dateParam.month(), dateParam.day());
        String dayOfWeek = dayOfWeekDate.format('EEEE');
        return (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday');
    }

    public static Date getBusinessDate(Date startDate) {
        return loan.HolidayUtil.INSTANCE.getNextWorkingDate(startDate);
    }

    public static Date getDateFromUntypedString(
        String dateString, Integer yearIndex, Integer monthIndex, Integer dayIndex, String splitBy
    ) {
        List<String> dateSplits = dateString.split(splitBy);
        Date actualDate = Date.newInstance(
            Integer.valueOf(dateSplits[yearIndex]), Integer.valueOf(dateSplits[monthIndex]),
            Integer.valueOf(dateSplits[dayIndex])
        );
        return actualDate;
    }

    public static Organization getOrgInformation {
        get {
            if (getOrgInformation == null) {
                getOrgInformation = [
                    SELECT Id, isSandbox, InstanceName, OrganizationType
                    FROM Organization
                    LIMIT 1
                ];
            }
            return getOrgInformation;
        }
        set;
    }

    public static BusinessHours businessHours {
        get {
            if(businessHours == null) {
                List<BusinessHours> businessHourList = businessHourDBInstance.getOrgActiveBusinessHours();
                if(businessHourList.isEmpty()) {
                    throw new GeneralHelperException('There was no Business Hours exist in the system');
                }
                businessHours = businessHourList.get(0);
            }
            return businessHours;
        }
        set;
    }

    public static String getAsyncCronExpression() {
        DateTime currentDateTime = DateTime.now().addSeconds(15);
        String hour = String.valueOf(currentDateTime.hour());
        String min = String.valueOf(currentDateTime.minute());
        String sec = String.valueOf(currentDateTime.second());
        String nextFireTime = sec + ' ' + min + ' ' + hour + ' * * ?';
        return nextFireTime;
    }

    public static String getAsyncCronExpressionByDate(Date schedulerDate, String hours, String minutes, String seconds) {
        String day = String.valueOf(schedulerDate.day());
        String month = String.valueOf(schedulerDate.month());
        String year = String.valueOf(schedulerDate.year());
        String nextFireTime = seconds + ' ' + minutes + ' ' + hours +  ' ' +  day + ' ' + month + ' ' + '?' +  ' ' + year;
        return nextFireTime;
    }

    public static Map<String, Folder> folderByFolderName {
        get {
            if(folderByFolderName == null) {
                folderByFolderName = new Map<String, Folder>();
                for(Folder folderRecord : folderDBInstance.getAllFolder()) {
                    folderByFolderName.put(folderRecord.Name, folderRecord);
                }
            }
            return folderByFolderName;
        }
        set;
    }

    public static Map<String, Group> queueByNameMap {
        get {
            if(queueByNameMap == null) {
                queueByNameMap = new Map<String, Group>();
                for(Group groupRecord : groupDBInstance.getAllQueues()) {
                    queueByNameMap.put(groupRecord.DeveloperName, groupRecord);
                }
            }
            return queueByNameMap;
        }
        set;
    }

    public static Map<String, Site> siteByName {
        get {
            if(siteByName == null) {
                siteByName = new Map<String, Site>();
                for(Site siteRecord : siteDBInstance.getAllSiteDetails()) {
                    siteByName.put(siteRecord.Name, siteRecord);
                }
            }
            return siteByName;
        }
        set;
    }

    public static String siteFullURLByName(String siteName) {
        String siteFullUrl = '';
        if(siteByName.containsKey(siteName)) {
            siteFullUrl = 'https://';
            Organization org = GeneralHelper.getOrgInformation;
            siteFullUrl += (org.IsSandbox ? (GeneralHelper.domainUrl.split('--')[1].split('\\.'))[0] + '-' : '') + GeneralHelper.siteByName.get(siteName).Subdomain + '.';
            siteFullUrl += (org.IsSandbox ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
            siteFullUrl += '/' + GeneralHelper.siteByName.get(siteName).UrlPathPrefix;
        }

        return siteFullUrl;
    }

    public static Map<String, OrgWideEmailAddress> orgWideEmailAddressByEmail {
        get {
            if (orgWideEmailAddressByEmail == null) {
                orgWideEmailAddressByEmail = new Map<String,OrgWideEmailAddress>();
                for(OrgWideEmailAddress orgEmail: orgWideEmailAddressDBInstance.getAllOrgWideEmailAddressList()){
                    orgWideEmailAddressByEmail.put(orgEmail.Address, orgEmail);
                }
            }
            return orgWideEmailAddressByEmail;
        }
        set;
    }

    public static Map<String, Profile> profileByName {
        get {
            if(profileByName == null) {
                profileByName = new Map<String, Profile>();
                for(Profile profileRecord : profileDBInstance.getAllProfiles()) {
                    profileByName.put(profileRecord.Name, profileRecord);
                }
            }
            return profileByName;
        }
        set;
    }

    public static String generateUniqueReferenceId(String requestBody) {
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(requestBody + DateTime.now() + ':' + DateTime.now().millisecond()));
        return EncodingUtil.convertToHex(hash);
    }

    public static String cleanSpecialCharacters(String stringToClear) {
        if(String.isBlank(stringToClear)) {
            return stringToClear;
        }
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s]');
        Matcher matcher = nonAlphanumeric.matcher(stringToClear);
        return matcher.replaceAll('');
    }

    public static Boolean isAsynchronous() {
        return (System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled());
    }

    public static String convertStateNameToShortCode(String stateName) {
        String stateFullName = titleCaseConversion(stateName);
        State_Name_Vs_State_Code_Mapping__mdt stateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(stateFullName);
        if(stateCodeMapping != null) {
            stateName = stateCodeMapping.short_code__c;
        }
        return stateName;
    }

    private static String titleCaseConversion(String inputString)
    {
        String titleCase = '';
        List<String> stringSplits = inputString.split(' ');
        for (String stringPart : stringSplits) {
            String stringFirstCharacter = stringPart.subString(0,1).toUpperCase();
            String stringRemainingCharacters = stringPart.substringAfter(stringPart.subString(0,1)).toLowerCase();
            titleCase += ' ' + stringFirstCharacter + stringRemainingCharacters;
        }
        return titleCase.trim().replaceAll('\\s+','_');
    }

    public static Map<String, Id> customNotificationTypeByName {
        get {
            if(customNotificationTypeByName == null) {
                customNotificationTypeByName = new Map<String, Id>();
                for(CustomNotificationType customNotificationTypeRecord : customNotificationTypeDBInstance.customNotificationTypeIdByName()) {
                    customNotificationTypeByName.put(customNotificationTypeRecord.DeveloperName, customNotificationTypeRecord.Id);
                }
            }
            return customNotificationTypeByName;
        }
        set;
    }

    public static Map<String, Id> reciprocalRoleIdByName {
        get {
            if(reciprocalRoleIdByName == null) {
                reciprocalRoleIdByName = new Map<String, Id>();
                for(clcommon__Reciprocal_Role__c reciprocalRole : clCommonReciprocalRoleDBInstance.getAllCLCommonRelationship()) {
                    reciprocalRoleIdByName.put(reciprocalRole.Name, reciprocalRole.Id);
                }
            }
            return reciprocalRoleIdByName;
        }
        set;
    }

    public static Map<String, EmailTemplate> emailTemplateByName {
        get {
            if(emailTemplateByName == null) {
                emailTemplateByName = new Map<String, EmailTemplate>();
                for(EmailTemplate template : emailTemplateDBInstance.getAllTemplates()) {
                    emailTemplateByName.put(template.DeveloperName, template);
                }
            }
            return emailTemplateByName;
        }
        set;
    }

    public static String getObjectKeyPrefix(String objName) {
        return DescribeHelper.getSObjectResult(objName).getKeyPrefix();
    }

    private class GeneralHelperException extends Exception {}
}