public class LeadTriggerHandler
{
    private static AccountDB accountDbInstance = new AccountDB();
    private static ContactDB contactDbInstance = new ContactDB();

    public void beforeInsert(List<Lead> triggerNew)
    {
        for(Lead leadRecord : triggerNew)
        {
            if(leadRecord.State__c != null) {
                String mailingStateName = leadRecord.State__c.trim().replaceAll('\\s+','_');
                State_Name_Vs_State_Code_Mapping__mdt mailingStateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(mailingStateName);
                if(mailingStateCodeMapping != null){
                    leadRecord.State__c = mailingStateCodeMapping.short_code__c;
                }
            }

            if(leadRecord.State != null) {
                String billingStateName = leadRecord.State.trim().replaceAll('\\s+','_');
                State_Name_Vs_State_Code_Mapping__mdt billingStateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(billingStateName);
                if(billingStateCodeMapping != null){
                    leadRecord.State = billingStateCodeMapping.short_code__c;
                }
            }
        }
    }

    public void beforeUpdate(List<Lead> triggerNew)
    {
        for(Lead leadRecord : triggerNew)
        {
            Leads.leadMandatoryInformationCheck(leadRecord, Leads.CLOSED_CONVERTED);
            List<Contact> brokerAccountFromContact = new List<Contact>();
            if(leadRecord.Broker_Email__c != null) {
                brokerAccountFromContact = contactDbInstance.getBrokerAccountIdFromContactByEmail(new set<String>{leadRecord.Broker_Email__c});
            }
            Leads.leadRecordFieldsAssign(leadRecord, brokerAccountFromContact);
            Leads.leadQualificationCriteria(leadRecord, Leads.CLOSED_CONVERTED);
        }
    }

    public void afterUpdate(List<Lead> triggerNew)
    {
        for(Lead leadRecord : triggerNew)
        {
            String label = leadRecord.Lead_Type__c;
            if(leadRecord.IsConverted && leadRecord.LeadSource != Leads.SOURCE_BROKER_PORTAL
                && leadRecord.LeadSource != Leads.SOURCE_MERCHANT_PORTAL)
            {
                switch on label {
                    when 'Merchant' {
                        LeadManager.convertLeadsAsMerchant(leadRecord);
                    }
                    when 'Broker' {
                        LeadManager.convertLeadsAsBroker(leadRecord);
                    }
                }
            }
            else if(leadRecord.IsConverted && leadRecord.Portal_Lead_Converted__c == false
                && leadRecord.Lead_Type__c == 'Merchant')
            {
                LeadManager.convertLeadsAsMerchant(leadRecord);
            }
        }
    }
}