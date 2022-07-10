public class CANPricingDetails {

    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_SENT_TO_CUSTOMER = 'Sent To Customer';
    public static final String STATUS_ACCEPTED = 'Accepted';
    public static final String STATUS_REJECTED = 'Rejected';
    public static final String STATUS_ARCHIVED = 'Archived';
    public static final String STATUS_REVIEW_REQUIRED = 'Review Required';
    public static final String OFFER_TYPE_INITIAL_OFFER = 'Initial Offer';
    public static final String OFFER_TYPE_EXCEPTION_OFFER = 'Exception Offer';
    public static final String OFFER_TYPE_ACCEPTED_OFFER = 'Accepted Offer';
    public static final String OFFER_TYPE_MANUAL_OFFER = 'Manual Offer';
    public static final Decimal DEFAULT_MINIMUM_TERM = 6;
    public static final String MAXIMUM_COMMISSION_ERROR_MSG = 'Commission % should not be greater than Maximum Commission ';
    public static final String MAXIMUM_AMOUNT_ERROR_MSG = 'Selected Amount should not be greater than Maximum Amount ';
    public static final String DIRECT_CHANNEL = 'Direct';
    public static final String PARTNER_CHANNEL = 'Partner';
    public static final String PRICING_TYPE_STANDARD_PARTNER_NEW = 'Standard Partner New';
    public static final String PRICING_TYPE_DIRECT_NEW = 'Direct New';
    public static final String PRICING_TYPE_PARTNER_RENEWAL = 'Partner Renewal';
    public static final String PRICING_TYPE_DIRECT_RENEWAL = 'Direct Renewal';
    public static final String PRICING_TYPE_WINBACK_RENEWAL = 'Direct Winback';
    public static final Set<String> ACTIVE_PRICING_STATUSES = new Set<String> {STATUS_SENT_TO_CUSTOMER, STATUS_ACCEPTED};

    public static CAN_Pricing_Detail__c createPricingDetail(
        genesis__Applications__c application, CAN_Pricing_Detail__c existingPricingDetail, Decimal ocrolusMaxDailyPayment
    ) {
        if(ocrolusMaxDailyPayment == null) {
            throw new CANPricingDetailsException('Ocrolus Max Daily Payment field should not be null');
        }

        CAN_Pricing_Detail__c pricingDetail;
        if(existingPricingDetail == null) {
            pricingDetail = new CAN_Pricing_Detail__c();
        } else {
            pricingDetail = existingPricingDetail;
        }
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Status__c = STATUS_DRAFT;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Random_Number__c = (application.Random_Number__c == null)? 1 : application.Random_Number__c;
        if(application.Broker_Contact__c != null) {
            setInitialDefaultBrokerCommission(pricingDetail, application);
            pricingDetail.Channel__c = PARTNER_CHANNEL;
        } else {
            pricingDetail.Channel__c = DIRECT_CHANNEL;
        }
        setPricingType(pricingDetail, application);
        pricingDetail.Start_Date__c = application.genesis__Expected_Start_Date__c;
        setMaxAmountAndTerm(pricingDetail, application, true);
        if(pricingDetail.Term__c == null || pricingDetail.Term__c > pricingDetail.Maximum_Term__c) {
            pricingDetail.Term__c = pricingDetail.Maximum_Term__c;
        }
        pricingDetail.Ocrolus_Max_Daily_Payment__c = ocrolusMaxDailyPayment;

        return pricingDetail;
    }

    @TestVisible
    private static void setPricingType(
        CAN_Pricing_Detail__c pricingDetail, genesis__Applications__c application
    ) {
        if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_NEW || pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT) {
            if(pricingDetail.Channel__c == PARTNER_CHANNEL) {
                pricingDetail.Pricing_Type__c = (application.Broker_Contact__r.Account.Pricing_Partner_Type__c == null)?
                    PRICING_TYPE_STANDARD_PARTNER_NEW : application.Broker_Contact__r.Account.Pricing_Partner_Type__c;
            } else if(pricingDetail.Channel__c == DIRECT_CHANNEL) {
                pricingDetail.Pricing_Type__c = PRICING_TYPE_DIRECT_NEW;
            }
        } else if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            if(pricingDetail.Channel__c == PARTNER_CHANNEL) {
                pricingDetail.Pricing_Type__c = PRICING_TYPE_PARTNER_RENEWAL;
            } else if(pricingDetail.Channel__c == DIRECT_CHANNEL && application.genesis__Account__r.Legacy_Percent_Paid__c >= 90) {
                pricingDetail.Pricing_Type__c = PRICING_TYPE_WINBACK_RENEWAL;
            } else if(pricingDetail.Channel__c == DIRECT_CHANNEL && application.genesis__Account__r.Legacy_Percent_Paid__c < 90) {
                pricingDetail.Pricing_Type__c = PRICING_TYPE_DIRECT_RENEWAL;
            }
        }
    }

    private static void setInitialDefaultBrokerCommission(
        CAN_Pricing_Detail__c pricingDetail, genesis__Applications__c application
    ) {
        pricingDetail.Max_Broker_Commission__c = application.Max_Broker_Commission__c;
        pricingDetail.Renewal_Amount_Commission__c = application.Broker_Contact__r.Account.Renewal_Amount_Commission__c;
        pricingDetail.Broker_Commission_Based_On__c = application.Broker_Contact__r.Account.Commision_Based_On__c;
        pricingDetail.Is_Flat_Renewal__c = application.Broker_Contact__r.Account.Is_Flat_Renewal__c;

        if(pricingDetail.Standard_Commission__c == null || pricingDetail.Standard_Commission__c > pricingDetail.Max_Broker_Commission__c) {
            pricingDetail.Standard_Commission__c = pricingDetail.Max_Broker_Commission__c;
        }

        if(application.Type__c == GeneralConstants.LOAN_TYPE_NEW
            && pricingDetail.Broker_Commission_Based_On__c == Brokers.COMMISSION_CALC_METHOD_FLAT
        ) {
            pricingDetail.Commission_Amount__c = application.Broker_Contact__r.Account.Flat_Referral_Fee__c;
        } else if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && pricingDetail.Is_Flat_Renewal__c) {
            pricingDetail.Standard_Commission__c = application.Broker_Contact__r.Account.Flat_Renewal_Commission__c;
        }
    }

    public static CAN_Pricing_Detail__c calculateCANPricing(CAN_Pricing_Detail__c pricingDetail) {
        pricingDetail.Term__c = Integer.valueOf(pricingDetail.Term__c);

        setGAVAndPricingFactorFromPolicyExhibit(pricingDetail);
        calculateCANPricingWithoutPolicyUpdate(pricingDetail);

        return pricingDetail;
    }

    public static CAN_Pricing_Detail__c calculateCANPricingWithoutPolicyUpdate(CAN_Pricing_Detail__c pricingDetail) {
        pricingDetail.Term__c = Integer.valueOf(pricingDetail.Term__c);

        calculatePricingFactor(pricingDetail);
        calculateMaximumAmount(pricingDetail);
        evaluateSelectionAmount(pricingDetail);
        calculatePaymentAmount(pricingDetail);
        calculateBrokerCommission(pricingDetail);
        calculateOriginationFee(pricingDetail);

        return pricingDetail;
    }

    private static void calculatePricingFactor(CAN_Pricing_Detail__c pricingDetail) {
        String key = 'T' + pricingDetail.term__c;
        Map<String, can_max_pricing_matrix_by_term__mdt> capMaxPriceTermMap = CustomMetaDataHelper.canMaxPricingMatrixByTermMap;
        if(capMaxPriceTermMap != null) {
            pricingDetail.maximum_pricing_factor__c = capMaxPriceTermMap.get(key).max_price__c;
        }

        pricingDetail.Pricing_Factor__c = pricingDetail.Buy_Rate__c;
        if(pricingDetail.Standard_Commission__c != null) {
            pricingDetail.Pricing_Factor__c = pricingDetail.Buy_Rate__c + (pricingDetail.Standard_Commission__c / 100);
        }
    }

    private static void evaluateSelectionAmount(CAN_Pricing_Detail__c pricingDetail) {
        if(pricingDetail.Selected_Amount__c == null || pricingDetail.Selected_Amount__c > pricingDetail.Maximum_Amount__c) {
            pricingDetail.Selected_Amount__c = pricingDetail.Maximum_Amount__c;
        }

        pricingDetail.Selected_Amount__c = (pricingDetail.Selected_Amount__c).setScale(2);
    }

    private static void calculateBrokerCommission(CAN_Pricing_Detail__c pricingDetail) {
        decimal maxCommissionCap = ((pricingDetail.maximum_pricing_factor__c - pricingDetail.Buy_Rate__c - ( pricingDetail.Origination_Fee_Percentage__c / 100 )) * 100);
        if( pricingDetail.Max_Broker_Commission__c > maxCommissionCap) {
            pricingDetail.max_term_broker_commission__c = maxCommissionCap;
        } else {
            pricingDetail.max_term_broker_commission__c = pricingDetail.Max_Broker_Commission__c;
        }

        if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_NEW
            && pricingDetail.Broker_Commission_Based_On__c == Brokers.COMMISSION_CALC_METHOD_PERCENTAGE
            && pricingDetail.Standard_Commission__c > 0
        ) {
            pricingDetail.Commission_Amount__c = pricingDetail.Selected_Amount__c * (pricingDetail.Standard_Commission__c / 100);

        } else if (pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            if(pricingDetail.Renewal_Amount_Commission__c == Brokers.COMMISSION_CALC_BASED_ON_GROSS_AMOUNT && pricingDetail.Standard_Commission__c > 0) {
                pricingDetail.Commission_Amount__c = pricingDetail.Selected_Amount__c * (pricingDetail.Standard_Commission__c / 100);

            } else if(pricingDetail.Renewal_Amount_Commission__c == Brokers.COMMISSION_CALC_BASED_ON_NET_AMOUNT && pricingDetail.Standard_Commission__c > 0) {
                Decimal oldestUnpaidDueAmount = pricingDetail.Oldest_Unpaid_Due_As_Of_Today__c != null ? pricingDetail.Oldest_Unpaid_Due_As_Of_Today__c : 0;
                pricingDetail.Commission_Amount__c = (pricingDetail.Selected_Amount__c - oldestUnpaidDueAmount) * (pricingDetail.Standard_Commission__c / 100);
            }
        }
    }

    private static void calculateMaximumAmount(CAN_Pricing_Detail__c pricingDetail) {

        if(pricingDetail.Maximum_Exception_Amount__c == null) {
            Decimal ocrolusMaximumAmount = (pricingDetail.Ocrolus_Max_Daily_Payment__c *  pricingDetail.Term__c * 22) / pricingDetail.Pricing_Factor__c;
            pricingDetail.Ocrolus_Maximum_Amount__c = ocrolusMaximumAmount;

            Decimal maxAmount = ((pricingDetail.Max_GAV__c / 100) * (pricingDetail.Annual_Volume__c / 12) * pricingDetail.Term__c) / pricingDetail.Pricing_Factor__c;

            if(maxAmount < pricingDetail.Policy_Maximum_Amount__c && maxAmount < ocrolusMaximumAmount) {
                pricingDetail.Maximum_Amount__c = maxAmount;
            } else if(pricingDetail.Policy_Maximum_Amount__c < ocrolusMaximumAmount) {
                pricingDetail.Maximum_Amount__c = pricingDetail.Policy_Maximum_Amount__c;
            } else {
                pricingDetail.Maximum_Amount__c = ocrolusMaximumAmount;
            }
        } else {
            pricingDetail.Maximum_Amount__c = pricingDetail.Maximum_Exception_Amount__c;
        }

        pricingDetail.Maximum_Amount__c = (pricingDetail.Maximum_Amount__c).setScale(2);
    }

    public static void calculatePaymentAmount(CAN_Pricing_Detail__c pricingDetail) {
        pricingDetail.Start_Date__c = GeneralHelper.getBusinessDate(GeneralHelper.currentSystemDate);

        calculateDailyPaymentAmount(pricingDetail);
        calculateWeeklyPaymentAmount(pricingDetail);

        pricingDetail.GAV__c = ((pricingDetail.Daily_Payment_Amount__c * 22) / (pricingDetail.Annual_Volume__c / 12)) * 100;
    }

    private static void calculateDailyPaymentAmount(CAN_Pricing_Detail__c pricingDetail) {
        Decimal repaymentAmount = pricingDetail.Selected_Amount__c * pricingDetail.Pricing_Factor__c;
        pricingDetail.Repayment_Amount__c = repaymentAmount;

        Decimal dailyPaymentAmount = repaymentAmount / pricingDetail.Term__c / 22;
        Integer numberOfDailyPayments = (Integer) (repaymentAmount / dailyPaymentAmount).round();
        pricingDetail.Number_Of_Daily_Payments__c = numberOfDailyPayments;
        pricingDetail.Daily_Payment_Amount__c = dailyPaymentAmount;

        Date dailyFirstPaymentDate = Applications.getFirstPaymentDateByFrequency(
            pricingDetail.Start_Date__c, GeneralConstants.FREQUENCY_DAILY
        );

        Integer weeks = (Integer) (Decimal.valueOf((Double)(pricingDetail.Number_Of_Daily_Payments__c / 5))).round(System.RoundingMode.DOWN);
        Integer extraDays = (Integer) pricingDetail.Number_Of_Daily_Payments__c - (weeks * 5);
        Date endDate = dailyFirstPaymentDate.addDays((weeks * 7) + extraDays - 1);
        pricingDetail.Daily_End_Date__c = GeneralHelper.isWeekend(endDate)? endDate.addDays(2) : endDate;
    }

    private static void calculateWeeklyPaymentAmount(CAN_Pricing_Detail__c pricingDetail) {
        Decimal repaymentAmount = pricingDetail.Selected_Amount__c * pricingDetail.Pricing_Factor__c;
        Decimal weeklyPaymentAmount = repaymentAmount / (pricingDetail.Term__c * 365 / 12 / 7).round();
        Integer numberOfWeeklyPayments = (Integer) (repaymentAmount / weeklyPaymentAmount).round();
        pricingDetail.Number_Of_Weekly_Payments__c = numberOfWeeklyPayments;
        pricingDetail.Weekly_Payment_Amount__c = weeklyPaymentAmount;

        Date weeklyFirstPaymentDate = Applications.getFirstPaymentDateByFrequency(
            pricingDetail.Start_Date__c, GeneralConstants.FREQUENCY_WEEKLY
        );

        pricingDetail.Weekly_End_Date__c = weeklyFirstPaymentDate.addDays((Integer) (pricingDetail.Number_Of_Weekly_Payments__c - 1) * 7);
    }

    public static void setGAVAndPricingFactorFromPolicyExhibit(CAN_Pricing_Detail__c pricingDetail) {
        OriginationHelper.randomNumber = pricingDetail.Random_Number__c;
        String pricingKey;
        if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_NEW || pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT) {
            pricingKey = pricingDetail.Pricing_Type__c + pricingDetail.Term__c + GeneralConstants.LOAN_TYPE_NEW + pricingDetail.SC4_Tier__c + pricingDetail.Industry_Rating__c;
        } else if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            pricingKey = pricingDetail.Pricing_Type__c + pricingDetail.Term__c + pricingDetail.Loan_Type__c + pricingDetail.SC4_Tier__c + null;
        }

        String gavKey = pricingDetail.Term__c + pricingDetail.SC4_Tier__c + pricingDetail.Industry_Rating__c;

        if(!OriginationHelper.pricingMatrixDetailByCriteria.containsKey(pricingKey)) {
            throw new CANPricingDetailsException('There was no Pricing Matrix Detail found to get Pricing Rate for key : ' + pricingKey);
        }
        if(!OriginationHelper.gavMatrixDetailByCriteria.containsKey(gavKey)) {
            throw new CANPricingDetailsException('There was no GAV Matrix Detail found to get GAV for key : ' + gavKey);
        }

        pricingDetail.Max_GAV__c = OriginationHelper.gavMatrixDetailByCriteria.get(gavKey).GAV__c;
        pricingDetail.Floor_Buy_Rate__c = OriginationHelper.pricingMatrixDetailByCriteria.get(pricingKey).Pricing_Rate__c;
        pricingDetail.Buy_Rate__c = pricingDetail.Floor_Buy_Rate__c;
    }

    private static void setMaxAmountAndTerm(
        CAN_Pricing_Detail__c pricingDetail, genesis__Applications__c application, Boolean isSingleLocation
    ) {
        OriginationHelper.randomNumber = pricingDetail.Random_Number__c;
        String key = pricingDetail.Pricing_Type__c + application.Type__c + application.Industry_Rating__c + application.SC4_Tier__c;
        if(!OriginationHelper.maxAmountAndMaxTermByCriteria.containsKey(key)) {
            throw new CANPricingDetailsException(
                'There was no Max Amount And Max Term Mapping found for Type: ' + application.Type__c +
                + ' Rating: ' +  application.Industry_Rating__c + ' SC4_Tier: ' + application.SC4_Tier__c
            );
        }

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountAndMaxTerm = OriginationHelper.maxAmountAndMaxTermByCriteria.get(key);
        pricingDetail.Maximum_Term__c = maxAmountAndMaxTerm.Maximum_Term__c;

        if(isSingleLocation) {
            pricingDetail.Policy_Maximum_Amount__c = maxAmountAndMaxTerm.Maximum_Amount_Single_Location__c;
        } else {
            pricingDetail.Policy_Maximum_Amount__c
                = maxAmountAndMaxTerm.Maximum_Amount_Multi_Location__c - maxAmountAndMaxTerm.Maximum_Amount_Single_Location__c;
        }
    }

    public static Boolean isPolicyParameterModified(CAN_Pricing_Detail__c pricingDetail, CAN_Pricing_Detail__c oldPricingDetail) {
        return (
            oldPricingDetail.Term__c != pricingDetail.Term__c
        );
    }

    public static Boolean isPricingModified(CAN_Pricing_Detail__c pricingDetail, CAN_Pricing_Detail__c oldPricingDetail) {
        return (
            oldPricingDetail.Standard_Commission__c != pricingDetail.Standard_Commission__c
            || oldPricingDetail.Selected_Amount__c != pricingDetail.Selected_Amount__c
            || oldPricingDetail.Maximum_Exception_Amount__c != pricingDetail.Maximum_Exception_Amount__c
            || oldPricingDetail.Payment_Frequency__c != pricingDetail.Payment_Frequency__c
            || oldPricingDetail.Origination_Fee_Percentage__c != pricingDetail.Origination_Fee_Percentage__c
            || oldPricingDetail.Buy_Rate__c != pricingDetail.Buy_Rate__c
        );
    }

    public static void calculateOriginationFee(CAN_Pricing_Detail__c pricingDetail) {
        if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_NEW) {
           pricingDetail.Origination_Fee_Amount__c = pricingDetail.Selected_Amount__c * pricingDetail.Origination_Fee_Percentage__c / 100;
        } else if(pricingDetail.Loan_Type__c == GeneralConstants.LOAN_TYPE_RENEWAL
            && pricingDetail.Oldest_Unpaid_Due_As_Of_Today__c != null && pricingDetail.Selected_Amount__c > pricingDetail.Oldest_Unpaid_Due_As_Of_Today__c
        ) {
            pricingDetail.Origination_Fee_Amount__c = (pricingDetail.Selected_Amount__c - pricingDetail.Oldest_Unpaid_Due_As_Of_Today__c) * pricingDetail.Origination_Fee_Percentage__c / 100;
        }
    }

    public static void validatePricing(CAN_Pricing_Detail__c pricingDetail) {
        if(pricingDetail.Status__c == CANPricingDetails.STATUS_ARCHIVED) {
            return;
        }

        if(pricingDetail.Standard_Commission__c > pricingDetail.Max_Broker_Commission__c) {
            CustomError.addError(pricingDetail, MAXIMUM_COMMISSION_ERROR_MSG + pricingDetail.Max_Broker_Commission__c);
        }
        if(pricingDetail.Selected_Amount__c > pricingDetail.Maximum_Amount__c) {
            CustomError.addError(pricingDetail, MAXIMUM_AMOUNT_ERROR_MSG + pricingDetail.Maximum_Amount__c);
        }
        if(pricingDetail.Term__c < 6) {
            CustomError.addError(pricingDetail, 'Term should be greater 6');
        }
    }

    public static Map<Integer, CAN_Pricing_Detail__c> buildPricingOptionsByTerm(CAN_Pricing_Detail__c pricingDetail) {
        Map<Integer, CAN_Pricing_Detail__c> pricingOptionsByTerm = new  Map<Integer, CAN_Pricing_Detail__c>();

        for(String termEmailOption : (CustomSettingsHelper.generalSettings.Offer_Email_Term_Options__c).split(',')) {
            Integer termOption = Integer.valueOf(termEmailOption);
            if(termOption <= pricingDetail.Maximum_Term__c) {
                // Create a different instance for the new offer.
                CAN_Pricing_Detail__c newPricingDetail = pricingDetail.clone();

                // Calculate the new values (in the new instance) for this Term.
                newPricingDetail.Term__c = termOption;
                CANPricingDetails.calculateCANPricing(newPricingDetail);

                // Calculate the new values (in the new instance) for this commission type and add it to the final list.
                newPricingDetail.Standard_Commission__c = Integer.valueOf(newPricingDetail.max_term_broker_commission__c);
                pricingOptionsByTerm.put(termOption, CANPricingDetails.calculateCANPricing(newPricingDetail));
            }
        }

        return pricingOptionsByTerm;
    }

    private class CANPricingDetailsException extends Exception {}
}