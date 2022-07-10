public class UCCFilingDB extends DBManager {
    public List<UCC_Filing_Detail__c> getUCCRecordsByAccountIds (Set<Id> accountIds) {
        return [
            SELECT Id, Name, Account__c, Collateral_Text1__c, Collateral_Text2__c,
                Collateral_Text3__c, Collateral_Text4__c, Debtor_City__c, Debtor_Individual_City__c,
                Debtor_Individual_Country__c, Debtor_Individual_FirstName__c, Debtor_Individual_LastName__c,
                Debtor_Individual_MailAddress__c, Debtor_Individual_MiddleName__c, Debtor_Individual_PostalCode__c,
                Debtor_Individual_State__c, Debtor_Individual_Suffix__c, Debtor_Mail_Address__c, Debtor_Organization_State__c, Debtor_Organization_Country__c,
                Debtor_Organization_Name__c, Debtor_Organization_PostalCode__c, Debtor_Organizational_ID__c, Debtor_Organizational_Type__c,
                Debtor_Organizational_Jurisdiction__c, Filer_City__c, Filer_Client_AccountNum__c, Filer_Contact_Email__c,
                Filer_Contact_Fax__c, Filer_Contact_Name__c, Filer_Contact_Phone__c, Filer_Mail_Address__c, Filer_Organization_Name__c,
                Filer_PostalCode__c, Filer_State__c, Filing_Status__c, Jurisdiction_ID__c, Jurisdiction_Name__c, Jurisdiction_State__c,
                Secured_City__c, Secured_Country__c, Secured_MailAddress__c, Secured_Organization_Name__c, Secured_postalCode__c,
                Secured_State__c, Order_ID__c, UCC_Created_Date__c, Parent_Order_ID__c, UCC_Account_ID__c, Order_Status__c, Filing_Number__c,
                Filing_Date__c, Expiration_Date__c, Original_Filing_Number__c, Original_Filing_Date__c, Approve_Date__c, Complete_Date__c, Notes__c,
                Is_UCC_Continued__c, UCC_Continuation_Reports_Pulled__c, Is_Terminated__c, UCC_Termination_Reports_Pulled__c, Terminated_Order_ID__c
            FROM UCC_Filing_Detail__c
            WHERE Account__c IN :accountIds
        ];
    }

    public List<UCC_Filing_Detail__c> getUCCFilingListByIds (Set<Id> uccFilingIds) {
        return [
            SELECT Id, Name, Account__c, Collateral_Text1__c, Collateral_Text2__c,
                Collateral_Text3__c, Collateral_Text4__c, Debtor_City__c, Debtor_Individual_City__c,
                Debtor_Individual_Country__c, Debtor_Individual_FirstName__c, Debtor_Individual_LastName__c,
                Debtor_Individual_MailAddress__c, Debtor_Individual_MiddleName__c, Debtor_Individual_PostalCode__c,
                Debtor_Individual_State__c, Debtor_Individual_Suffix__c, Debtor_Mail_Address__c, Debtor_Organization_Country__c,Debtor_Organization_State__c,
                Debtor_Organization_Name__c, Debtor_Organization_PostalCode__c, Debtor_Organizational_ID__c, Debtor_Organizational_Type__c,
                Debtor_Organizational_Jurisdiction__c, Filer_City__c, Filer_Client_AccountNum__c, Filer_Contact_Email__c,
                Filer_Contact_Fax__c, Filer_Contact_Name__c, Filer_Contact_Phone__c, Filer_Mail_Address__c, Filer_Organization_Name__c,
                Filer_PostalCode__c, Filer_State__c, Filing_Status__c, Jurisdiction_ID__c, Jurisdiction_Name__c, Jurisdiction_State__c,
                Secured_City__c, Secured_Country__c, Secured_MailAddress__c, Secured_Organization_Name__c, Secured_postalCode__c,
                Secured_State__c, Order_ID__c, UCC_Created_Date__c, Parent_Order_ID__c, UCC_Account_ID__c, Order_Status__c, Filing_Number__c,
                Filing_Date__c, Expiration_Date__c, Original_Filing_Number__c, Original_Filing_Date__c, Approve_Date__c, Complete_Date__c, Notes__c,
                Account__r.EIS_Extend_UCC__c, Account__r.Legacy_Active_Contract__c, Is_UCC_Continued__c, UCC_Continuation_Reports_Pulled__c, Is_Terminated__c,
                UCC_Termination_Reports_Pulled__c
            FROM UCC_Filing_Detail__c
            WHERE Id IN :uccFilingIds
        ];
    }
}