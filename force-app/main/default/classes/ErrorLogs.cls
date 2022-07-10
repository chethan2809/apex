public class ErrorLogs {

    public static final String INFO = 'INFO';
    public static final String DEBUG = 'DEBUG';
    public static final String ERROR = 'ERROR';
    public static final String FATAL = 'FATAL';
    public static final String LOG_TYPE_AWS_OCROLUS = 'awsocrolus';

    public static final  Set<String> KEYS_TO_VALIDATE = new Set<String>{
        'pk', 'TransactionId', 'Message'
    };

    public static Error_Log__c createErrorLog(
        String origin, String errorMessage, String request, String response, String severity, Id referenceId, Boolean sendNotification
    ) {
        Error_Log__c errorlog = new Error_Log__c();
        errorlog.Origin__c = origin;
        errorlog.Error_Message__c = errorMessage != null? errorMessage.right(100000) : null;
        errorlog.Request__c = request != null? request.right(100000) : null;
        errorlog.Response__c = response != null? response.right(131070) : null;
        errorlog.Severity__c = severity;
        errorlog.Send_Notification__c = sendNotification;
        errorlog.Reference_Id__c = referenceId;

        if(referenceId != null) {
            String sObjectType = referenceId.getSObjectType().getDescribe().getName();

            switch on sObjectType {
                when 'Account' {
                    errorlog.Account__c = referenceId;
                }
                when 'Contact' {
                    errorlog.Contact__c = referenceId;
                }
                when 'genesis__Applications__c' {
                    errorlog.Application__c = referenceId;
                }
                when 'loan__Loan_Account__c' {
                    errorlog.Loan_Account__c = referenceId;
                }
            }
        }

        return errorlog;
    }

    public static Error_Log__c createErrorLog(String origin, Exception ex, Id referenceId, Boolean sendNotification) {
        String message;
        String request;
        String response;

        if(ex.getMessage().contains('| Request:')) {
            List<String> errorMessage = ex.getMessage().split('\\s\\|\\s');
            message = errorMessage.get(0);
            request = errorMessage.get(1);
            response = errorMessage.get(2);
        } else {
            message = ex.getMessage() + ex.getStackTraceString();
        }

        return createErrorLog(
            origin, message, request, response, ErrorLogs.ERROR, referenceId, sendNotification
        );
    }

    public static String constructErrorMessageFromDatabaseResult(List<Database.Error> resultErrors) {
        String message = '';
        for (Database.Error err : resultErrors) {
            message += '\n' + err.getStatusCode() + ': ' + err.getMessage();
        }
        return message;
    }
}