global class CCBPGenerateCANPricingAPI implements clcommon.PortalCustomRemoteAPI1 {
    CANPricingDetailDB canPricingDetailDbInstance = new CANPricingDetailDB();
    ApplicationDB applicationDbInstance = new ApplicationDB();
    ErrorLogDB errorLogDbInstance = new ErrorLogDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        Map<String,Object> fields = new Map<String,Object>();
        CAN_Pricing_Detail__c canPricingDetailsFromPortal = new CAN_Pricing_Detail__c();
        List<CAN_Pricing_Detail__c> canPricingDetailsForValidationLst = new  List<CAN_Pricing_Detail__c>();
        CAN_Pricing_Detail__c finalCanPricingRecord = new CAN_Pricing_Detail__c();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        Id applicationId = (Id)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
        try{
            Boolean isValidApplication;
            isValidApplication = CLSPBPortalSecurity.validApplication(applicationId);
            if(isValidApplication){
                applicationList = applicationDbInstance.getApplicationsByIds(new Set<Id> {applicationId});
                canPricingDetailsForValidationLst = canPricingDetailDbInstance.getCANPricingByApplicationId(applicationId);
                if(argumentsFromPortal.containsKey(PortalConstants.SLIDER_APP_STATUS_VALIDATION) && argumentsFromPortal.get(PortalConstants.SLIDER_APP_STATUS_VALIDATION) == true) {
                   if(!applicationList.isEmpty()){
                       String applicationStatus = (String)argumentsFromPortal.get(PortalConstants.APPLICATION_STATUS);
                       String overAllStatus = (String)argumentsFromPortal.get(PortalConstants.APPLICATION_OVERALL_STATUS);
                       String pricingRecordName = (String)argumentsFromPortal.get(PortalConstants.SLIDER_PRICING_RECORD_NAME);
                       if(applicationStatus == applicationList[0].genesis__Status__c && overAllStatus == applicationList[0].Overall_Status__c &&
                       pricingRecordName == canPricingDetailsForValidationLst[0].Name){
                        fields.put(PortalConstants.SLIDER_APP_STATUS_VALIDATION, true);
                        fields.put(PortalConstants.APPLICATION_STATUS, applicationList[0].genesis__Status__c);
                        fields.put(PortalConstants.APPLICATION_OVERALL_STATUS, applicationList[0].Overall_Status__c);
                       }
                       else{
                        fields.put(PortalConstants.SLIDER_APP_STATUS_VALIDATION, false);
                        fields.put(PortalConstants.APPLICATION_STATUS, applicationList[0].genesis__Status__c);
                        fields.put(PortalConstants.APPLICATION_OVERALL_STATUS, applicationList[0].Overall_Status__c);
                       }
                   }
                }
                else if(argumentsFromPortal.containsKey(PortalConstants.SLIDER_VALUES_FROM_PORTAL) &&
                   argumentsFromPortal.get(PortalConstants.SLIDER_VALUES_FROM_PORTAL) != null &&
                   argumentsFromPortal.containsKey(PortalConstants.CALCULATE_OFFER_PORTAL)){
                       canPricingDetailsFromPortal = (CAN_Pricing_Detail__c)JSON.deserialize((String)argumentsFromPortal.get(PortalConstants.SLIDER_VALUES_FROM_PORTAL), CAN_Pricing_Detail__c.class);
                       CAN_Pricing_Detail__c canPricingDetailsResponse = CANPricingDetails.calculateCANPricing(canPricingDetailsFromPortal);
                       fields.put(PortalConstants.APPLICATION_ID, applicationId);
                       fields.put(PortalConstants.LOAN_AMOUNT, canPricingDetailsResponse.Selected_Amount__c);
                       fields.put(PortalConstants.BUY_RATE, canPricingDetailsResponse.Buy_Rate__c);
                       fields.put(PortalConstants.DAILY_PAYMENT_AMOUNT, canPricingDetailsResponse.Daily_Payment_Amount__c);
                       fields.put(PortalConstants.NO_OF_DAILY_PAYMENTS, canPricingDetailsResponse.Number_Of_Daily_Payments__c);
                       fields.put(PortalConstants.WEEKLY_PAYMENT_AMOUNT, canPricingDetailsResponse.Weekly_Payment_Amount__c);
                       fields.put(PortalConstants.NO_OF_WEEKLY_PAYMENTS, canPricingDetailsResponse.Number_Of_Weekly_Payments__c);
                       fields.put(PortalConstants.TERM, canPricingDetailsFromPortal.Term__c);
                       fields.put(PortalConstants.MAXIMUM_TERM, canPricingDetailsFromPortal.Maximum_Term__c);
                       fields.put(PortalConstants.MAXIMUM_AMOUNT, canPricingDetailsResponse.Maximum_Amount__c);
                       fields.put(PortalConstants.REPAYMENT_AMOUNT, canPricingDetailsResponse.Repayment_Amount__c);
                       fields.put(PortalConstants.LOAN_TYPE, canPricingDetailsFromPortal.Loan_Type__c);
                       fields.put(PortalConstants.SC4_TIER, canPricingDetailsFromPortal.SC4_Tier__c);
                       fields.put(PortalConstants.INDUSTRY_RATING, canPricingDetailsFromPortal.Industry_Rating__c);
                       fields.put(PortalConstants.GAV, canPricingDetailsResponse.GAV__c);
                       fields.put(PortalConstants.ANNUAL_VOLUME, canPricingDetailsFromPortal.Annual_Volume__c);
                       fields.put(PortalConstants.POLICY_MAX_AMOUNT, canPricingDetailsFromPortal.Policy_Maximum_Amount__c);
                       fields.put(PortalConstants.DAILY_END_DATE, canPricingDetailsResponse.Daily_End_Date__c);
                       fields.put(PortalConstants.START_DATE, canPricingDetailsFromPortal.Start_Date__c);
                       fields.put(PortalConstants.WEEKLY_END_DATE, canPricingDetailsResponse.Weekly_End_Date__c);
                       fields.put(PortalConstants.PRICING_STATUS, canPricingDetailsResponse.Status__c);
                       fields.put(PortalConstants.OCROLUS_MAX_DAILY_PAYMENT, canPricingDetailsResponse.Ocrolus_Max_Daily_Payment__c);
                       fields.put(PortalConstants.OCROLUS_MAXIMUM_AMOUNT, canPricingDetailsResponse.Ocrolus_Maximum_Amount__c);
                       fields.put(PortalConstants.MAX_EXCEPTION_AMOUNT, canPricingDetailsResponse.Maximum_Exception_Amount__c);
                       fields.put(PortalConstants.FLOOR_BUY_RATE, canPricingDetailsResponse.Floor_Buy_Rate__c);
                       fields.put(PortalConstants.MAX_GAV, canPricingDetailsFromPortal.Max_GAV__c);
                       fields.put(PortalConstants.ORIGINATION_FEE_PERCENTAGE, canPricingDetailsResponse.Origination_Fee_Percentage__c);
                       fields.put(PortalConstants.OVERWRITE_POLICY_DEFAULT, canPricingDetailsFromPortal.Overwrite_Policy_Default__c);
                       fields.put(PortalConstants.PAYMENT_FREQUENCY, canPricingDetailsResponse.Payment_Frequency__c);
                       fields.put(PortalConstants.ORIGINATION_FEE_AMOUNT, canPricingDetailsResponse.Origination_Fee_Amount__c);
                       fields.put(PortalConstants.BROKER_COMMISSION, canPricingDetailsFromPortal.Standard_Commission__c);
                       fields.put(PortalConstants.COMMISSION_AMOUNT, canPricingDetailsFromPortal.Commission_Amount__c);
                       fields.put(PortalConstants.MAX_BROKER_COMMISSION, canPricingDetailsFromPortal.Max_Broker_Commission__c);
                       fields.put(PortalConstants.BROKER_COMMISSION_BASED_ON, canPricingDetailsResponse.Broker_Commission_Based_On__c);
                       fields.put(PortalConstants.RENEWAL_AMOUNT_COMMISSION, canPricingDetailsResponse.Renewal_Amount_Commission__c);
                       fields.put(PortalConstants.IS_FLAT_RENEWAL, canPricingDetailsResponse.Is_Flat_Renewal__c);
                       fields.put(PortalConstants.PRICING_FACTOR, canPricingDetailsResponse.Pricing_Factor__c);
                       fields.put(PortalConstants.PRICING_TYPE, canPricingDetailsResponse.Pricing_Type__c);
                       fields.put(PortalConstants.RANDOM_NUMBER, canPricingDetailsResponse.Random_Number__c);
                   }
                else if(argumentsFromPortal.containsKey(PortalConstants.OFFERS_VALUES_FROM_PORTAL) &&
                        argumentsFromPortal.get(PortalConstants.OFFERS_VALUES_FROM_PORTAL) != null &&
                        argumentsFromPortal.containsKey(PortalConstants.SUBMIT_OFFER_PORTAL)){
                            canPricingDetailsFromPortal = (CAN_Pricing_Detail__c)JSON.deserialize((String)argumentsFromPortal.get(PortalConstants.OFFERS_VALUES_FROM_PORTAL), CAN_Pricing_Detail__c.class);
                            finalCanPricingRecord = CCAcceptOfferFromPortalAPI.createAcceptedPricingRecordFromBrokerPortal(canPricingDetailsFromPortal, applicationId);
                            if(!applicationList.isEmpty()){
                                finalCanPricingRecord.Opportunity__c = applicationList[0].Opportunity__c != null ? applicationList[0].Opportunity__c : '';
                            }
                            else{
                                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                                            PortalConstants.ERROR_SLIDER_PRICING_CATCH_BP, PortalConstants.PRICING_RECORD_IS_MISSING + applicationId, null,
                                            null, ErrorLogs.ERROR, applicationId, true);
                                errorLogDBInstance.addInsert(errorLog);
                                errorLogDBInstance.executeInserts();
                            }
                            canPricingDetailDbInstance.addInsert(finalCanPricingRecord);
                            canPricingDetailDbInstance.executeInserts();
                            applicationList = applicationDbInstance.getApplicationsByIds(new Set<Id> {applicationId});
                            fields.put(PortalConstants.APPLICATION_ID, applicationId);
                            fields.put(PortalConstants.APPLICATION_STATUS, applicationList[0].genesis__Status__c);
                            fields.put(PortalConstants.APPLICATION_OVERALL_STATUS, applicationList[0].Overall_Status__c);
                        }
            }else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                            PortalConstants.ACCESS_DENIED_GENERATE_SUBMIT_OFFER, null, null,
                            null, ErrorLogs.ERROR, applicationId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
        }catch (Exception e) {
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.ERROR_SLIDER_PRICING_CATCH_BP, e.getMessage(), e.getStackTraceString(), null, ErrorLogs.ERROR, applicationId, true);
            errorLogDbInstance.addInsert(errorLog);
            errorLogDbInstance.executeInserts();
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            return response;
        }
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        response.Status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
        response.errorMessage = null;
        return response;
    }
    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}