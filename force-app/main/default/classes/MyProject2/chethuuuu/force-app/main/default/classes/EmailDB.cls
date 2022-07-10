public class EmailDB {

    public List<Messaging.SendEmailResult> sendEmail(Messaging.SingleEmailMessage email) {
        if(email == null) {
            return new List<Messaging.SendEmailResult>();
        }
        return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }

    public List<Messaging.SendEmailResult> sendBulkEmail(List<Messaging.SingleEmailMessage> emailList) {
        if(emailList.isEmpty()) {
            return new List<Messaging.SendEmailResult>();
        }
        return Messaging.sendEmail(emailList);
    }
}