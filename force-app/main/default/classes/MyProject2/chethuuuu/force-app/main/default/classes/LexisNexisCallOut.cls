public class LexisNexisCallOut {

    public static HttpResponse requestBusinessInstantIDCheck(
        Account accountDetail, Map<String,List<Contact>> contactListByPartyType
    ) {
        LexisNexisCallOutParser parser = new LexisNexisCallOutParser(accountDetail, contactListByPartyType, null, 'BID');
        HttpRequest request = CallOutHelper.createRequest(LexisNexiss.lexisNexisBIIDNamedCredential + '?ver_=2.60', 'POST');
        request.setHeader('Content-Type','application/json');
        request.setBody(JSON.serialize(parser.requestBodyForBusinessInstantId()));

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response;
    }

    public static HttpResponse requestFraudPointCheck(Account accountDetail, List<Contact> contactList) {
        LexisNexisCallOutParser parser = new LexisNexisCallOutParser(accountDetail, null, contactList, 'FraudPoint');
        HttpRequest request = CallOutHelper.createRequest(LexisNexiss.lexisNexisSMANamedCredential + '?ver_=2.22', 'POST');
        request.setHeader('Content-Type','application/json');
        request.setBody(JSON.serialize(parser.requestBodyForFraudPoint()));

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response;
    }
}