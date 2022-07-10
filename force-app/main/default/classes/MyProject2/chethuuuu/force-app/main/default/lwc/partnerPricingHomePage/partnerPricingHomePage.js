import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resourceCANLogoWhite from '@salesforce/resourceUrl/logo_white_png';
import getCANGeneralSetting from '@salesforce/apex/PartnerPricingSecureLinkController.getCANGeneralSetting';
import getApplicationId from '@salesforce/apex/PartnerPricingSecureLinkController.getApplicationId';
import getApplicationDetails from '@salesforce/apex/PartnerPricingSecureLinkController.getApplicationDetails';
import getPricingDetails from '@salesforce/apex/PartnerPricingSecureLinkController.getPricingDetails';
import calculatePricing from '@salesforce/apex/PartnerPricingSecureLinkController.calculatePricing';
import validateApplication from '@salesforce/apex/PartnerPricingSecureLinkController.validateApplication';
import acceptPricingOffer from '@salesforce/apex/PartnerPricingSecureLinkController.acceptPricingOffer';
import generateDocument from '@salesforce/apex/PartnerPricingSecureLinkController.generateDocument';

export default class PartnerPricingHomePage extends LightningElement {
    @track loading = true;
    @track isPrerequisiteValid = true;
    @track pricingRecord = {};
    @track error;
    currentApplicationId;
    applicationRecord = {};
    customSetting = {};
    encryptedStringValue;
    borrowerName;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.encryptedStringValue = currentPageReference.state.source;
        }
    }

    connectedCallback() {
        this.invokeInitialDataLoad();
    }

    get isValidSession() {
        return this.isPrerequisiteValid && !this.isError;
    }

    get hasPricingRecord() {
        return (this.pricingRecord && Object.entries(this.pricingRecord).length > 0);
    }

    get canLogoWhite() {
        return resourceCANLogoWhite;
    }

    get disableGenerateDocument() {
        return this.isError || !(this.applicationRecord.genesis__Status__c == 'OFFER ACCEPTED');
    }

    get isNotFlatCommission() {
        return (this.applicationRecord.Type__c == 'New' && this.applicationRecord.Broker_Contact__r.Account.Commision_Based_On__c == 'Percentage Of Financed Amount')
            || (this.applicationRecord.Type__c == 'Renewal' && this.applicationRecord.Broker_Contact__r.Account.Is_Flat_Renewal__c == false)
    }

    get paymentFrequencyOption() {
        return [
            { label: 'DAILY', value: 'DAILY' },
            { label: 'WEEKLY', value: 'WEEKLY' }
        ];
    }

    get isError() {
        return this.errors.length > 0;
    }

    get isLoading() {
        if (this.isError) {
            return false;
        }
        return this.loading;
    }

    get errors() {
        let errors = [];

        if (this.error) {
            errors = errors.concat(this.error);
        }

        if (errors.length > 0) {
            console.error('Error => ' +JSON.stringify(errors, null, 2));
        }
        return errors;
    }

    async invokeInitialDataLoad() {
        try {
            this.customSetting = await getCANGeneralSetting();
            this.currentApplicationId = await getApplicationId({ encryptedString: this.encryptedStringValue});
            this.applicationRecord = await getApplicationDetails({ applicationId: this.currentApplicationId});
            const isValid = await validateApplication({ application: this.applicationRecord});
            if(isValid) {
                this.borrowerName = this.applicationRecord.genesis__Account__r.Name;
                this.pricingRecord = await getPricingDetails({ applicationId: this.currentApplicationId})
            } else {
                this.isPrerequisiteValid = false;
            }
        } catch(error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }

    handleFrequencyChange(event){
        this.pricingRecord.Payment_Frequency__c = event.target.value;
    }

    handleAmountChange(event){
        this.pricingRecord.Selected_Amount__c = event.target.value;
        this.handlePricingChange();
    }

    handleSliderChange(event) {
        this.pricingRecord = event.detail;
        this.handlePricingChange();
    }

    async handlePricingChange() {
        this.loading = true;
        try {
            this.pricingRecord = await calculatePricing({ pricingDetail: this.pricingRecord});
            this.loading = false;
        } catch(error) {
            this.error = error;
            this.loading = false;
        }
    }

    async handleSubmitOffer() {
        this.loading = true;
        if(await this.validateCurrentPricingIsLatest()) {
            return false;
        }
        try {
            this.applicationRecord = await getApplicationDetails({ applicationId: this.currentApplicationId});
            const isValid = await validateApplication({ application: this.applicationRecord});
            if(isValid) {
                const result = await acceptPricingOffer({ pricingDetail: this.pricingRecord});
                if (result == 'Success') {
                    this.applicationRecord = await getApplicationDetails({ applicationId: this.currentApplicationId});
                    this.pricingRecord = await getPricingDetails({ applicationId: this.currentApplicationId});
                    this.showToastMessage('Offer Accepted Successfully', null, 'success');
                } else {
                    this.showToastMessage('Failed To Accept Offer', result, 'error');
                }
            } else {
                this.isPrerequisiteValid = false;
            }
        } catch(error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }

    async handleGenerateDocument() {
        this.loading = true;
        try {
            this.applicationRecord = await getApplicationDetails({ applicationId: this.currentApplicationId});
            console.log('Document Current count : ' + this.applicationRecord.Partner_Pricing_Generate_Doc_Count__c);
            if(this.applicationRecord.Partner_Pricing_Generate_Doc_Count__c && this.customSetting.Partner_Pricing_Generate_Doc_Count_Limit__c
                && this.applicationRecord.Partner_Pricing_Generate_Doc_Count__c >= this.customSetting.Partner_Pricing_Generate_Doc_Count_Limit__c) {
                this.showToastMessage('Maximum Document Generation limit reached', 'please contact your CAN Capital sales representative', 'warning');
                return;
            }
            const isValid = await validateApplication({ application: this.applicationRecord});
            if(isValid) {
                const result = await generateDocument({ applicationId: this.currentApplicationId});
                if(result == 'Success') {
                    this.showToastMessage('Document Generated Successfully', null, 'success');
                } else {
                    this.showToastMessage('Document Generation Failed', result, 'error');
                }
            } else {
                this.isPrerequisiteValid = false;
            }
        } catch(error) {
            this.error = error;
        } finally {
            this.loading = false;
        }
    }

    async validateCurrentPricingIsLatest() {
        const latestPricing = await getPricingDetails({ applicationId: this.currentApplicationId});
        if(latestPricing.Id == this.pricingRecord.Id) {
            return false;
        } else {
            this.showToastMessage('Current offer has been modified by someone', 'Please refresh the page to get latest offer', 'warning');
            return true;
        }
    }

    handleClose() {
        window.close();
    }

    showToastMessage(title, message, variant) {
        this.loading = false;
        const displayMode = (variant == 'success')? 'dismissable': 'sticky';
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: displayMode
        }));
    }
}