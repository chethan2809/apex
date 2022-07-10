import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getDefaultAPSRecordById from '@salesforce/apex/CollectionCaseDB.getDefaultAPSRecordByContractId';
import getConstants from '@salesforce/apex/CollectionCaseDB.getAllConstants';
import getPaymentTypes from '@salesforce/apex/CollectionCaseDB.getPaymentTypes';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import createAPSRecord from '@salesforce/apex/PaymentArrangementsManager.createAPSRecord';
import updateAPSRecord from '@salesforce/apex/PaymentArrangementsManager.updateAPSRecord';
import updatePaymentArrangement from '@salesforce/apex/PaymentArrangementsManager.updatePaymentArrangement';

    const FIELDS = ['Payment_Arrangements__c.Id','Payment_Arrangements__c.Name','Payment_Arrangements__c.Collection_Case__c',
                'Payment_Arrangements__c.Contact__c','Payment_Arrangements__c.Total_Outstanding_Repayment_Amount__c',
                'Payment_Arrangements__c.Total_Unpaid_Due_Amount_To_Current__c', 'Payment_Arrangements__c.Payment_Arrangement_Type__c',
                'Payment_Arrangements__c.Payment_Mode__c','Payment_Arrangements__c.Promise__c','Payment_Arrangements__c.Bank_Account__c',
                'Payment_Arrangements__c.Amount__c','Payment_Arrangements__c.Debit_Date__c','Payment_Arrangements__c.Automatically_Enable_Default_APS__c',
                'Payment_Arrangements__c.Automated_Payment_Setup__c','Payment_Arrangements__c.Type__c','Payment_Arrangements__c.Setup_Date__c',
                'Payment_Arrangements__c.Transaction_Amount__c','Payment_Arrangements__c.Frequency__c','Payment_Arrangements__c.Amount_Type__c',
                'Payment_Arrangements__c.Recurring_ACH_Start_Date__c','Payment_Arrangements__c.Recurring_ACH_End_Date__c','Payment_Arrangements__c.Debit_Day__c'];
    const apsMap = {
    sObject: "loan__Automated_Payment_Setup__c",
    Id: undefined,
    loan__Type__c: undefined,
    loan__Amount_Type__c: undefined,
    loan__CL_Contract__c: undefined,
    loan__Payment_Mode__c: undefined,
    loan__Active__c: true,
    loan__Bank_Account__c: undefined,
    loan__Debit_Day__c: undefined,
    loan__Debit_Date__c: undefined,
    loan__Frequency__c: undefined,
    loan__Transaction_Amount__c: undefined,
    loan__Recurring_ACH_Start_Date__c: undefined,
    loan__Recurring_ACH_End_Date__c: undefined
};

const apsMapUpdate = {
    sObject: "loan__Automated_Payment_Setup__c",
    Id: undefined,
    loan__Active__c: undefined
};
export default class CcApsRecordCreation extends LightningElement {
    
    @api recordId;
    collectionList;
    paymentModeList;
    paymentArrangement;
    defaultAPSRecord;
    defaultAPSRecordId = null;
    markDefault = false;
    CollectionCaseConstants;
    paymentModeId;
    clContractId;
    showMessagePopup = false;
    messagePopupTitle = 'Automated Payment Setup Record Creation';
    popupMessageText;

    get oneTimeApsMap() {
        return apsMap;
    }

    get recurringApsMap() {
        return apsMap;
    }

    get apsMaptoUpdate() {
        return apsMapUpdate;
    }

    @wire(getConstants)
    allConstants({ error, data }) {
        if (data) {
            this.CollectionCaseConstants = data;
        } else {
            this.error = error;
        }
    }

    @wire(getPaymentTypes, {})
    wiredPaymentTypes({ error, data }) {
        if (data) {
            this.paymentModeList = data;
        } else if (error) {
            this.error = error;
            console.log('Error:' + JSON.stringify(this.error));
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredPaymentArrangement({ error, data}) {
        if (data) {
            this.paymentArrangement = data;
            this.getCollectionCaseData(this.paymentArrangement.fields.Collection_Case__c.value);
        } else if (error) {
            this.error = error;
            console.log('Error:'+JSON.stringify(this.error));
        }
    }

    getCollectionCaseData(collectionCaseId) {
        return getCollectionCaseDetails({ collectionCaseId: collectionCaseId })
        .then(result => {
            this.clContractId = result.CL_Contract_Id__c;
            this.getDefaultAPSRecord();
        })
        .catch(error => {
            this.error = error;
        });
    }

    getDefaultAPSRecord() {
        return getDefaultAPSRecordById({ loanAccountId: this.clContractId })
        .then(result => {
            this.defaultAPSRecord = result;
            if(this.defaultAPSRecord.length > 0){
                this.defaultAPSRecordId = this.defaultAPSRecord.Id;
            }
        })
        .catch(error => {
            this.error = error;
        });
    }
    
    handleCreateButtonClick(){
        const btnElement = this.template.querySelector('lightning-button');
        btnElement.disabled = true;
        if (this.paymentArrangement.fields.Payment_Mode__c.value == this.CollectionCaseConstants.PAYMENT_MODE_ACH) {
            this.paymentModeList.forEach(paymentMode => {
                if (paymentMode.Name.toUpperCase() == this.paymentArrangement.fields.Payment_Mode__c.value.toUpperCase()) {
                    this.paymentModeId = paymentMode.Id;
                }
            });
            if (this.paymentArrangement.fields.Type__c.value == this.CollectionCaseConstants.APS_TYPE_ONE_TIME) {
                if(this.paymentArrangement.fields.Transaction_Amount__c.value == this.paymentArrangement.fields.Amount__c.value){
                    this.oneTimeApsMap.loan__Type__c = this.paymentArrangement.fields.Type__c.value;
                    this.oneTimeApsMap.loan__Payment_Mode__c = this.paymentModeId;
                    this.oneTimeApsMap.loan__CL_Contract__c = this.clContractId;
                    this.oneTimeApsMap.loan__Active__c = true;
                    this.oneTimeApsMap.loan__Bank_Account__c = this.paymentArrangement.fields.Bank_Account__c.value;
                    this.oneTimeApsMap.loan__Debit_Date__c = this.paymentArrangement.fields.Debit_Date__c.value;
                    this.oneTimeApsMap.loan__Debit_Day__c = this.paymentArrangement.fields.Debit_Day__c.value;
                    this.oneTimeApsMap.loan__Transaction_Amount__c = this.paymentArrangement.fields.Transaction_Amount__c.value;
                    createAPSRecord({ apsObject: this.oneTimeApsMap }).then(result => {
                        updatePaymentArrangement({ paymentArrangementId: this.recordId, apsId: result })
                            .then(result => {
                                this.showToastMessage('Automated Payment Setup', 'Automated Payment Setup record created successfully', 'success');
                                getRecordNotifyChange([{recordId: this.recordId}]);
                            }).catch(error => {
                                this.error = error;
                                console.log('error:' + JSON.stringify(this.error));
                            });
                    }).catch(error => {
                        this.error = error;
                        console.log('error:' + this.error);
                    });
                }
                else {
                    this.popupMessageText = 'Amount and Transaction Amount must be same to create Onetime APS Record';
                    this.showMessagePopup = true;
                }
            } else if (this.paymentArrangement.fields.Type__c.value  == this.CollectionCaseConstants.APS_TYPE_RECURRING) {
                if(this.paymentArrangement.fields.Debit_Date__c.value >= this.paymentArrangement.fields.Recurring_ACH_Start_Date__c.value){
                    if(this.paymentArrangement.fields.Debit_Date__c.value < this.paymentArrangement.fields.Recurring_ACH_End_Date__c.value){
                        let startDate = new Date(this.paymentArrangement.fields.Recurring_ACH_Start_Date__c.value);
                        let endDate = new Date(this.paymentArrangement.fields.Recurring_ACH_End_Date__c.value);
                        let debitDate = new Date(this.paymentArrangement.fields.Debit_Date__c.value);
                        let totalPaymentAmount = 0.0;
                        let msgText = '';
                        if(startDate != debitDate){
                            startDate = debitDate;
                        }
                        if(startDate.getDay() == 0){
                            startDate.setDate(startDate.getDate() + 1);
                        }
                        if(startDate.getDay() == 6){
                            startDate.setDate(startDate.getDate() + 2);
                        }
                        if(this.paymentArrangement.fields.Frequency__c.value == this.CollectionCaseConstants.DAILY_FREQUENCY){
                            let numberOfPayments = 0;
                            for(let loopDate = startDate; loopDate <= endDate; loopDate.setDate(loopDate.getDate() + 1)){
                                if(loopDate <= endDate && loopDate.getDay() != 0 && loopDate.getDay() != 6){
                                    numberOfPayments += 1;
                                }
                            }
                            totalPaymentAmount = this.paymentArrangement.fields.Transaction_Amount__c.value * numberOfPayments;
                            msgText = '(Transaction Amount * Number of Daily Payments)';
                        }
                        else if(this.paymentArrangement.fields.Frequency__c.value == this.CollectionCaseConstants.WEEKLY_FREQUENCY){
                            let numberOfPayments = 0;
                            for(let loopDate = startDate; loopDate <= endDate; loopDate.setDate(loopDate.getDate() + 7)){
                                if(loopDate <= endDate){
                                    numberOfPayments += 1;
                                }
                            }
                            totalPaymentAmount = this.paymentArrangement.fields.Transaction_Amount__c.value * numberOfPayments;
                            msgText = '(Transaction Amount * Number of Weekly Payments)';
                        }
                        else if(this.paymentArrangement.fields.Frequency__c == this.CollectionCaseConstants.BI_WEEKLY_FREQUENCY){
                            let numberOfPayments = 0;
                            for(let loopDate = startDate; loopDate <= endDate; loopDate.setDate(loopDate.getDate() + 15)){
                                if(loopDate <= endDate){
                                    numberOfPayments += 1;
                                }
                            }
                            totalPaymentAmount = this.paymentArrangement.fields.Transaction_Amount__c.value * numberOfPayments;
                            msgText = '(Transaction Amount * Number of Bi-weekly Payments)';
                        }
                        if(totalPaymentAmount == this.paymentArrangement.fields.Amount__c.value){
                            this.recurringApsMap.loan__Type__c = this.paymentArrangement.fields.Type__c.value;
                            this.recurringApsMap.loan__Payment_Mode__c = this.paymentModeId;
                            this.recurringApsMap.loan__CL_Contract__c = this.clContractId;
                            this.recurringApsMap.loan__Amount_Type__c = this.paymentArrangement.fields.Amount_Type__c.value;
                            this.recurringApsMap.loan__Active__c = true;
                            this.recurringApsMap.loan__Bank_Account__c = this.paymentArrangement.fields.Bank_Account__c.value;
                            this.recurringApsMap.loan__Debit_Date__c = this.paymentArrangement.fields.Debit_Date__c.value;
                            this.recurringApsMap.loan__Debit_Day__c = this.paymentArrangement.fields.Debit_Day__c.value;
                            this.recurringApsMap.loan__Transaction_Amount__c = this.paymentArrangement.fields.Transaction_Amount__c.value;
                            this.recurringApsMap.loan__Frequency__c = this.paymentArrangement.fields.Frequency__c.value;
                            this.recurringApsMap.loan__Recurring_ACH_Start_Date__c = this.paymentArrangement.fields.Recurring_ACH_Start_Date__c.value;
                            this.recurringApsMap.loan__Recurring_ACH_End_Date__c = this.paymentArrangement.fields.Recurring_ACH_End_Date__c.value;
                            createAPSRecord({ apsObject: this.recurringApsMap }).then(result => {
                                if(this.defaultAPSRecordId != null && (this.paymentArrangement.fields.Payment_Arrangement_Type__c.value == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_ACCOMMODATION ||
                                   this.paymentArrangement.fields.Payment_Arrangement_Type__c.value == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_SETTLEMENT)){
                                    this.markDefaultAPSRecordInActive();
                                }
                                updatePaymentArrangement({ paymentArrangementId: this.recordId, apsId: result })
                                    .then(result => {
                                        this.showToastMessage('Automated Payment Setup', 'Automated Payment Setup record created successfully', 'success');
                                        getRecordNotifyChange([{recordId: this.recordId}]);
                                    }).catch(error => {
                                        this.error = error;
                                        console.log('error:' + JSON.stringify(this.error));
                                    });
                            }).catch(error => {
                                this.error = error;
                                console.log('error:' + JSON.stringify(this.error));
                            });
                        }
                        else {
                            this.popupMessageText = 'Amount and ' + msgText + ' must be same to create Recurring APS Record';
                            this.showMessagePopup = true;
                        }
                    }
                    else{
                        this.popupMessageText = 'Debit Date cannot be greater than or equal to ACH End Date to create Recurring APS Record';
                        this.showMessagePopup = true;
                    }
                }
                else{
                    this.popupMessageText = 'Debit Date cannot be less than ACH Start Date to create Recurring APS Record';
                    this.showMessagePopup = true;
                }
            }
        }
    }

    handlePopupCloseClick(){
        this.showMessagePopup = false;
    }

    markDefaultAPSRecordInActive(){
        this.apsMaptoUpdate.Id = this.defaultAPSRecord.Id;
        this.apsMaptoUpdate.loan__Active__c = false;
        updateAPSRecord({ apsObject: this.apsMaptoUpdate }).then(result => {
            if(result){
                this.markDefault = true;
            }
        }).catch(error => {
            console.log('error:' + JSON.stringify(this.error));
        });
    }

    showToastMessage(titleText, messageText, variantType){
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: variantType
        });
        this.dispatchEvent(evt);
    }
}