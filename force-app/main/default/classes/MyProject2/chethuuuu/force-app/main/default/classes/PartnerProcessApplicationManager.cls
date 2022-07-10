public class PartnerProcessApplicationManager {
    public static void processApplication(Map<String, Object> requestMap){
        Id applicationId = PartnerProcessApplications.validateRequest(requestMap);
        PartnerProcessApplications.invokeApplicationProcess(applicationId);
    }
}