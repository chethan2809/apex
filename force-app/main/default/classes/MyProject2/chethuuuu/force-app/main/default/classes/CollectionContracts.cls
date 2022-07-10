public class CollectionContracts
{
    public static collect__Loan_Account__c setCollectionContractFields(Map<Id,loan__Loan_Account__c> clContactsMap, collect__Loan_Account__c collectionContractRecord) {
        collectionContractRecord.Last_Payment_Date__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).loan__Last_Payment_Date__c;
        collectionContractRecord.collect__Last_Payment_Date__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).loan__Last_Payment_Date__c;
        collectionContractRecord.Outstanding_Payment_Amount__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).Total_Outstanding_Repayment_Amount__c;
        collectionContractRecord.ACH_Turned_off_Date__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).ACH_Turned_off_Date__c;
        collectionContractRecord.Last_ACH_return_date__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).Last_ACH_return_date__c;
        collectionContractRecord.collect__Contact__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).Primary_Contact__c;
        collectionContractRecord.Frequency_of_Loan_Payment__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).loan__Frequency_of_Loan_Payment__c;
        collectionContractRecord.Latest_Number_Of_Missed_Payments__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).Latest_Number_Of_Missed_Payments__c;
        collectionContractRecord.Return_Reason_Code__c = clContactsMap.get(collectionContractRecord.collect__External_ID__c).Return_Reason_Code__c;
        return collectionContractRecord;
    }
}