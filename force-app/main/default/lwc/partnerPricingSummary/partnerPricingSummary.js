import { LightningElement, api} from 'lwc';

export default class PartnerPricingSummary extends LightningElement {
    @api pricingRecord = {};
    @api applicationName;
    @api borrowerName;

    get isDailyFrequency() {
        return (this.pricingRecord.Payment_Frequency__c == 'DAILY');
    }
}