import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllFeeTypes from '@salesforce/apex/CollectionCaseDB.getAllFeeTypes';
import createChargeRecord from '@salesforce/apex/PaymentArrangementsManager.createChargeRecord';

const chargeMap = {
    sObject: "loan__Charge__c",
    Id: undefined,
    loan__Fee__c: undefined,
    loan__Date__c: undefined,
    loan__Reference__c: undefined,
    loan__Original_Amount__c: undefined,
    loan__Loan_Account__c: undefined
};

export default class CcNewChargeForm extends LightningElement {
    @api contractName;
    @api contractId;
    feeTypesList;
    feeTypes;
    selectedFeeTypeId;
    selectedFeeType = '';
    chargeDate = '';
    chargeAmount = 0;
    referenceText;
    error;

    @wire(getAllFeeTypes)
    getFeeType({error,data}){
        if(data){
            let options = [];
            options.push({ label: '--None--', value: '--None--' });
            this.feeTypesList = data;
            for(let key in this.feeTypesList){
                options.push({ label: data[key].Name, value: data[key].Name });
            }
            this.feeTypes = options;
        }else if(error){
            this.error = JSON.stringify(error);
        }
    };

    get newChargeMap(){
        return chargeMap;
    }

    handleFeeTypeChange(event){
        this.selectedFeeType = event.target.value;
        this.getFeeTypeId(this.selectedFeeType);
    }

    handleDateChange(event){
        this.chargeDate = event.target.value;
    }

    handleChargeAmountChange(event){
        this.chargeAmount = event.target.value;
    }

    handleReferenceChange(event){
        this.referenceText = event.target.value;
    }

    handleSave(event){
        if(this.selectedFeeType == '' || this.chargeDate == '' || this.chargeAmount <= 0){
            const evt = new ShowToastEvent({
                title: 'Record Creation',
                message: 'Please complete all required fields!',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
        else{
            this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = true;
            this.newChargeMap.loan__Fee__c = this.selectedFeeTypeId;
            this.newChargeMap.loan__Date__c = this.chargeDate;
            this.newChargeMap.loan__Reference__c = this.referenceText;
            this.newChargeMap.loan__Original_Amount__c = this.chargeAmount;
            this.newChargeMap.loan__Loan_Account__c = this.contractId;
            createChargeRecord({ chargeObject: this.newChargeMap }).then(result => {
                const evt = new ShowToastEvent({
                    title: 'Record Creation',
                    message: 'Charge record created successfully',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
                this.closeModal();
            }).catch(error => {
                console.log('error:' + this.error);
            });
        }
    }

    getFeeTypeId(feeType){
        for(let key in this.feeTypesList){
            if(this.feeTypesList[key].Name == feeType){
                this.selectedFeeTypeId = this.feeTypesList[key].Id;
                break;
            }
        }
    }

    closeModal(){
        const customEvent = new CustomEvent('closepopup',{
            detail: 'Close Popup'
        });
        this.dispatchEvent(customEvent);
    }
}