public class CustomSettingsHelper {
    public static CAN_General_Settings__c generalSettings {
        get {
            if(generalSettings == null) {
                generalSettings = CAN_General_Settings__c.getOrgDefaults();
            }
            return generalSettings;
        }
        set;
    }

    public static CAN_Conga_Settings__c congaSettings {
        get {
            if(congaSettings == null) {
                congaSettings = CAN_Conga_Settings__c.getOrgDefaults();
            }
            return congaSettings;
        }
        set;
    }

    public static loan__Org_Parameters__c loanOrgParameters {
        get {
            if(loanOrgParameters == null) {
                loanOrgParameters = loan__Org_Parameters__c.getOrgDefaults();
            }
            return loanOrgParameters;
        }
        set;
    }
}