public class CoBorrowers {
    public static loan__Coborrower__c createCoBorrower(clcommon__Party__c party) {
        loan__Coborrower__c coBorrower = new loan__Coborrower__c();
        coBorrower.loan__Account__c = party.clcommon__Account__c;
        coBorrower.loan__Contact__c = party.clcommon__Contact__c;
        coBorrower.loan__Party_Type__c = party.clcommon__Type__r.Name;
        coBorrower.loan__Loan__c = party.CL_Contract__c;
        return coBorrower;
    }
}