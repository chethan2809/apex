import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentSystemDate from '@salesforce/apex/CollectionCaseHelper.getCurrentSystemDate';
import getCollectionCaseDetails from '@salesforce/apex/CollectionCaseDB.getCollectionCaseDetails';
import getBankAccountDetails from '@salesforce/apex/CollectionCaseDB.getBankAccountDetails';
import createAPSRecord from '@salesforce/apex/PaymentArrangementsManager.createAPSRecord';
import updatePaymentArrangement from '@salesforce/apex/PaymentArrangementsManager.updatePaymentArrangement';
import updateActivePaymentArrangementOnAccount from '@salesforce/apex/PaymentArrangementsManager.updateActivePaymentArrangementOnAccount';
import updateCollectionCaseStatusAndSubStatus from '@salesforce/apex/PaymentArrangementsManager.updateCollectionCaseStatusAndSubStatus';
import getPaymentTypes from '@salesforce/apex/CollectionCaseDB.getPaymentTypes';
import getConstants from '@salesforce/apex/CollectionCaseDB.getAllConstants';
import calculatePaymentOccurrence from '@salesforce/apex/PaymentArrangementsManager.calculatePaymentOccurrence';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

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
    loan__Frequency__c: 'Daily',
    loan__Transaction_Amount__c: undefined,
    loan__Recurring_ACH_Start_Date__c: undefined,
    loan__Recurring_ACH_End_Date__c: undefined
};
export default class CcNewPaymentArrangement extends NavigationMixin(LightningElement) {
    @api recordId;
    accordianSection = '';
    sectionIcon = 'utility:chevrondown';
    currentSystemDate;
    error;
    achRequired = false;
    nonAchRequired = true;
    oneTimeRequired = false;
    arrangementType;
    paymentType;
    collectionList
    paymentMode;
    paymentModeId;
    paymentModeList;
    bankAccountName;
    bankAccountId;
    debitDate;
    debitDay;
    debitDateACH = null;
    debitDayACH;
    amount;
    transactionAmountACH = null;
    amountType;
    paymentFrequency = null;
    achStartDate = null;
    achEndDate = null;
    totalUnpaidDueAmount = 0;
    totalOutstandingAmount = 0;
    clContractId;
    accountId;
    CollectionCaseConstants;
    isApsRecordCreated = false;
    paymentArrangementId;
    validationErrorMessage;
    noOfOccurrence = 0;
    apsPayableAmount = 0.0;
    isLoading = false;

    get oneTimeApsMap() {
        return apsMap;
    }
    get recurringApsMap() {
        return apsMap;
    }

    @wire(getConstants)
    allConstants({ error, data }) {
        if (data) {
            this.CollectionCaseConstants = data;
            this.arrangementType = this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_PROMISE_TO_PAY;
            this.amountType = this.CollectionCaseConstants.APS_AMOUNT_TYPE_FIXED_AMOUNT;
        } else {
            this.error = error;
        }
    }

    @wire(getCurrentSystemDate)
    currentDate({ error, data }) {
        if (data) {
            this.currentSystemDate = data.loan__Current_System_Date__c;
        } else if (error) {
            this.error = error;
            console.log('Error:' + JSON.stringify(this.error));
        }
    }

    @wire(getCollectionCaseDetails, { collectionCaseId: '$recordId' })
    wiredContract({ error, data }) {
        if (data) {
            this.collectionList = data;
            this.bankAccountId = this.collectionList.Bank_Account__c;
            this.clContractId = this.collectionList.CL_Contract_Id__c;
            this.accountId = this.collectionList.Account__c;
            if (this.bankAccountId) {
                this.getBankAccountData();
            }
        } else if (error) {
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

    handleSubmit(event) {
        this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = true;
        event.preventDefault();
        if(this.amount == 0){
            this.showErrorMessage('Amount field cannot be Zero (0)');
            this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = false;
            return;
        }
        if(this.transactionAmountACH == 0 && this.paymentMode == this.CollectionCaseConstants.PAYMENT_MODE_ACH){
            this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = false;
            this.showErrorMessage('Transaction Amount cannot be Zero (0)');
            return;
        }
        if(this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_CATCH_UP &&
            this.paymentMode == this.CollectionCaseConstants.PAYMENT_MODE_ACH) {
            if(this.paymentType == this.CollectionCaseConstants.APS_TYPE_RECURRING && this.amount != this.apsPayableAmount){
                this.showErrorMessage('Amount & APS Total Payable Amount should be same to Create APS record');
                this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = false;
                return;
            } else if(this.paymentType == this.CollectionCaseConstants.APS_TYPE_ONE_TIME && this.amount != this.transactionAmountACH){
                this.showErrorMessage('Amount & APS Transaction Amount should be same to Create APS record');
                this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = false;
                return;
            }
        }
        this.isLoading = true;
        const fields = event.detail.fields;
        let unpaidAmountElement = this.template.querySelector('lightning-input-field[data-name="totalUnpaidDue"]');
        if(unpaidAmountElement.value > 0){
            this.totalUnpaidDueAmount = unpaidAmountElement.value;
        }
        let outstandingAmountElement = this.template.querySelector('lightning-input-field[data-name="totalOutstandingAmt"]');
        if(outstandingAmountElement.value > 0){
            this.totalOutstandingAmount = outstandingAmountElement.value;
        }
        console.log('fields:' + JSON.stringify(fields));
        if (this.paymentMode == this.CollectionCaseConstants.PAYMENT_MODE_ACH) {
            fields.Bank_Account__c = this.bankAccountId;
            fields.Total_Unpaid_Due_Amount_To_Current__c = this.totalUnpaidDueAmount;
            fields.Total_Outstanding_Repayment_Amount__c = this.totalOutstandingAmount;
            fields.Debit_Day__c = this.debitDayACH;
        } else if (this.paymentMode != this.CollectionCaseConstants.PAYMENT_MODE_ACH) {
            fields.Bank_Account__c = this.bankAccountId;
            fields.Total_Unpaid_Due_Amount_To_Current__c = this.totalUnpaidDueAmount;
            fields.Total_Outstanding_Repayment_Amount__c = this.totalOutstandingAmount;
            fields.Setup_Date__c = null;
            fields.Frequency__c = null;
            fields.Amount_Type__c = null;
            fields.Recurring_ACH_Start_Date__c = null;
            fields.Recurring_ACH_End_Date__c = null;
            fields.Debit_Date__c = this.debitDate;
        }
        this.template.querySelector('lightning-record-edit-form[data-name="paymentArrangement"]').submit(fields);
    }

    handleSuccess(event) {
        this.paymentArrangementId = event.detail.id;
        if (this.paymentArrangementId) {
            if (this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_PROMISE_TO_PAY ||
                this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_CATCH_UP) {
                if (this.paymentMode == this.CollectionCaseConstants.PAYMENT_MODE_ACH &&
                    this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_CATCH_UP) {
                    if (this.paymentType == this.CollectionCaseConstants.APS_TYPE_ONE_TIME) {
                        this.oneTimeApsMap.loan__Type__c = this.paymentType;
                        this.oneTimeApsMap.loan__Payment_Mode__c = this.paymentModeId;
                        this.oneTimeApsMap.loan__CL_Contract__c = this.clContractId;
                        this.oneTimeApsMap.loan__Active__c = true;
                        this.oneTimeApsMap.loan__Bank_Account__c = this.bankAccountId;
                        this.oneTimeApsMap.loan__Debit_Date__c = this.debitDateACH;
                        this.oneTimeApsMap.loan__Debit_Day__c = this.debitDayACH;
                        this.oneTimeApsMap.loan__Transaction_Amount__c = this.transactionAmountACH;
                        console.log('onetimeapsMap:'+JSON.stringify(this.oneTimeApsMap));
                        createAPSRecord({ apsObject: this.oneTimeApsMap }).then(result => {
                            console.log('ApsID:'+result);
                            console.log('payment arrangmentId:'+this.paymentArrangementId);
                            updatePaymentArrangement({ paymentArrangementId: this.paymentArrangementId, apsId: result })
                                .then(result => {
                                    if(result == this.CollectionCaseConstants.SUCCESS){
                                        this.isApsRecordCreated = true;
                                    }
                                    else{
                                        console.log('APS Record Creation failed');
                                    }
                                }).catch(error => {
                                    this.error = error;
                                    console.log('error:' + JSON.stringify(this.error));
                                });
                        }).catch(error => {
                            this.error = error;
                            console.log('error:' + this.error);
                        });
                    } else if (this.paymentType == this.CollectionCaseConstants.APS_TYPE_RECURRING) {
                        this.recurringApsMap.loan__Type__c = this.paymentType;
                        this.recurringApsMap.loan__Payment_Mode__c = this.paymentModeId;
                        this.recurringApsMap.loan__CL_Contract__c = this.clContractId;
                        this.recurringApsMap.loan__Amount_Type__c = this.amountType;
                        this.recurringApsMap.loan__Active__c = true;
                        this.recurringApsMap.loan__Bank_Account__c = this.bankAccountId;
                        this.recurringApsMap.loan__Debit_Date__c = this.debitDateACH;
                        this.recurringApsMap.loan__Debit_Day__c = this.debitDayACH;
                        this.recurringApsMap.loan__Transaction_Amount__c = this.transactionAmountACH;
                        this.recurringApsMap.loan__Frequency__c = this.paymentFrequency;
                        this.recurringApsMap.loan__Recurring_ACH_Start_Date__c = this.achStartDate;
                        this.recurringApsMap.loan__Recurring_ACH_End_Date__c = this.achEndDate;
                        createAPSRecord({ apsObject: this.recurringApsMap }).then(result => {
                            updatePaymentArrangement({ paymentArrangementId: this.paymentArrangementId, apsId: result })
                                .then(result => {
                                    if(result == this.CollectionCaseConstants.SUCCESS){
                                        this.isApsRecordCreated = true;
                                    }
                                    else{
                                        console.log('APS Record Creation failed');
                                    }
                                }).catch(error => {
                                    this.error = error;
                                    console.log('error:' + this.error);
                                });
                        }).catch(error => {
                            this.error = error;
                            console.log('error:' + this.error);
                        });
                    }
                }
                updateActivePaymentArrangementOnAccount({ accountId: this.accountId, activePaymentArrangementType: this.arrangementType, activePaymentArrangement: true })
                    .then(result => {
                        updateCollectionCaseStatusAndSubStatus({ collectionCaseId: this.recordId, collectionCaseStatus: this.CollectionCaseConstants.CATUP_BAD_STANDING_STATUS, collectionCaseSubStatus: this.CollectionCaseConstants.CATUP_SCHEDULED_SUB_STATUS })
                        .then(result => {
                            if (this.paymentMode == this.CollectionCaseConstants.PAYMENT_MODE_ACH && this.isApsRecordCreated) {
                                const evt = new ShowToastEvent({
                                    title: 'Payment Arrangements',
                                    message: 'Payment Arrangment record created successfully',
                                    variant: 'success'
                                });
                                this.dispatchEvent(evt);
                                this.closeModal();
                            }
                            else {
                                const evt = new ShowToastEvent({
                                    title: 'Payment Arrangements',
                                    message: 'Payment Arrangment record created successfully',
                                    variant: 'success'
                                });
                                this.dispatchEvent(evt);
                                this.closeModal();
                            }
                        }).catch(error => {
                            this.error = error;
                            console.log('error:' + JSON.stringify(this.error));
                        });

                    }).catch(error => {
                        this.error = error;
                        console.log('error:' + JSON.stringify(this.error));
                    });
            }
            else if (this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_JUDGEMENT) {
                updateActivePaymentArrangementOnAccount({ accountId: this.accountId, activePaymentArrangementType: this.arrangementType, activePaymentArrangement: true })
                .then(result => {
                        console.log('ONAccount:'+JSON.stringify(result));
                        updateCollectionCaseStatusAndSubStatus({ collectionCaseId: this.recordId, collectionCaseStatus: this.CollectionCaseConstants.JUDGEMENT_STATUS, collectionCaseSubStatus: this.CollectionCaseConstants.JUDGEMENT_SUB_STATUS })
                        .then(result => {
                            console.log('Status:'+JSON.stringify(result));
                            const evt = new ShowToastEvent({
                                title: 'Payment Arrangements',
                                message: 'Payment Arrangment record created successfully',
                                variant: 'success'
                            });
                            this.dispatchEvent(evt);
                            this.closeModal();
                        }).catch(error => {
                            this.error = error;
                            console.log('error:' + JSON.stringify(this.error));
                        });
                }).catch(error => {
                    this.error = error;
                    console.log('error:' + JSON.stringify(this.error));
                });
            }
            else if (this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_SETTLEMENT) {
                updateActivePaymentArrangementOnAccount({ accountId: this.accountId, activePaymentArrangementType: this.arrangementType, activePaymentArrangement: true })
                .then(result => {
                        updateCollectionCaseStatusAndSubStatus({ collectionCaseId: this.recordId, collectionCaseStatus: this.CollectionCaseConstants.SETTLEMENT_PLAN_STATUS, collectionCaseSubStatus: this.CollectionCaseConstants.SETTLEMENT_PLAN_SUB_STATUS })
                        .then(result => {
                            const evt = new ShowToastEvent({
                                title: 'Payment Arrangements',
                                message: 'Payment Arrangment record created successfully',
                                variant: 'success'
                            });
                            this.dispatchEvent(evt);
                            this.closeModal();
                        }).catch(error => {
                            this.error = error;
                            console.log('error:' + JSON.stringify(this.error));
                        });
                }).catch(error => {
                    this.error = error;
                    console.log('error:' + JSON.stringify(this.error));
                });
            }
            else if (this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_ACCOMMODATION) {
                updateActivePaymentArrangementOnAccount({ accountId: this.accountId, activePaymentArrangementType: this.arrangementType, activePaymentArrangement: true })
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'Payment Arrangements',
                        message: 'Payment Arrangment record created successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    this.closeModal();
                }).catch(error => {
                    this.error = error;
                    console.log('error:' + JSON.stringify(this.error));
                });
            }
        this.openPaymentArrangementRecord();
        }
    }

    handlePaymentModeChange(event) {
        this.paymentMode = event.target.value;
        this.paymentModeList.forEach(paymentMode => {
            if (paymentMode.Name.toUpperCase() == this.paymentMode.toUpperCase()) {
                this.paymentModeId = paymentMode.Id;
            }
        });
        let sectionElement = this.template.querySelector('[data-name="aps-section"]');
        let inputElements = this.template.querySelectorAll('.non-ach');
        let promiseElement = this.template.querySelector('[data-name="promise"]');
        if (event.target.value == this.CollectionCaseConstants.PAYMENT_MODE_ACH) {
            inputElements.forEach(element => {
                element.classList.add('slds-hide');
            });
            sectionElement.classList.remove('slds-hide');
            this.nonAchRequired = false;
            this.oneTimeRequired = true;
            this.achRequired = true;
            promiseElement.value = this.CollectionCaseConstants.PROMISE_KEPT;
            promiseElement.disabled = true;
        } else {
            inputElements.forEach(element => {
                element.classList.remove('slds-hide');
            });
            sectionElement.classList.add('slds-hide');
            this.nonAchRequired = true;
            this.oneTimeRequired = false;
            this.achRequired = false;
            promiseElement.value = '';
            promiseElement.disabled = false;
        }
    }

    handleAchTransactionAmt(event) {
        this.transactionAmountACH = event.target.value;
        this.calculateOccurrence();
    }

    handleAmountChange(event) {
        this.amount = event.target.value;
    }

    handleTypeChange(event) {
        this.paymentType = event.target.value;
        let inputElements = this.template.querySelectorAll('.recurring-ach');
        if (event.target.value == this.CollectionCaseConstants.APS_TYPE_ONE_TIME) {
            inputElements.forEach(element => {
                element.classList.add('slds-hide');
            });
            this.achRequired = false;
            this.template.querySelector('lightning-input-field[data-name="frequency"]').value = '';
            this.paymentFrequency = null;
            this.template.querySelector('lightning-input-field[data-name="recurringStartDate"]').value = '';
            this.achStartDate = null;
            this.template.querySelector('lightning-input-field[data-name="recurringEndDate"]').value = '';
            this.achEndDate = null;
        } else if (event.target.value == this.CollectionCaseConstants.APS_TYPE_RECURRING) {
            inputElements.forEach(element => {
                element.classList.remove('slds-hide');
            });
            this.achRequired = true;
        }

        let defaultAPSElement = this.template.querySelector('.forAccommodation');
        if (this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_ACCOMMODATION &&
            this.paymentType == this.CollectionCaseConstants.APS_TYPE_RECURRING) {
            defaultAPSElement.classList.remove('slds-hide');
        }
        else {
            defaultAPSElement.classList.add('slds-hide');
        }
        this.calculateOccurrence();
    }

    handleArrangementType(event) {
        this.arrangementType = event.target.value;
        console.log('arr type:'+this.arrangementType);
        let defaultAPSElement = this.template.querySelector('.forAccommodation');
        if (this.arrangementType == this.CollectionCaseConstants.PAYMENT_ARRANGEMENT_TYPE_ACCOMMODATION &&
            this.paymentType == this.CollectionCaseConstants.APS_TYPE_RECURRING) {
            defaultAPSElement.classList.remove('slds-hide');
        }
        else {
            defaultAPSElement.classList.add('slds-hide');
        }
    }

    handleFrequencyChange(event) {
        this.paymentFrequency = event.target.value;
        this.calculateOccurrence();
    }

    handleAmountType(event) {
        this.amountType = event.target.value;
    }

    handleAchDebitDate(event) {
        this.debitDateACH = event.target.value;
        if(this.debitDateACH < this.achStartDate){
            this.showErrorMessage('ACH Debit Date cannot be less than the ACH Start Date');
            this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = true;
        } else if(this.debitDateACH >= this.achEndDate){
            this.showErrorMessage('ACH Debit Date cannot be greater than or equal to ACH End Date');
            this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = true;
        } else{
            this.template.querySelector('lightning-button[data-name="submitButton"]').disabled = false;
        }
        let myDate = new Date(this.debitDateACH);
        this.debitDayACH = myDate.getDate();
        this.calculateOccurrence();
    }

    handleDebitDate(event) {
        this.debitDate = event.target.value;
        let myDate = new Date(this.debitDate);
        this.debitDay = myDate.getDate();
    }

    handleACHStartDate(event) {
        this.achStartDate = event.target.value;
        this.calculateOccurrence();
    }

    handleACHEndDate(event) {
        this.achEndDate = event.target.value;
        this.calculateOccurrence();
    }

    handleSection() {
        let element = this.template.querySelector('[data-name="aps-detail-section"]');
        if (element.classList.contains('slds-hide')) {
            element.classList.remove('slds-hide');
            this.sectionIcon = 'utility:chevrondown';
        } else {
            this.sectionIcon = 'utility:chevronright';
            element.classList.add('slds-hide');
        }
    }

    closeModal() {
        let close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close }
        });
         this.dispatchEvent(closeclickedevt);
        //this.dispatchEvent(new CloseActionScreenEvent());
        /* this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        }); */
    }

    handleToggleSection(event) {
        if (event.detail.openSections == '') {
            this.accordianSection = '';
        } else {
            this.accordianSection = 'APS';
        }
    }

    getBankAccountData() {
        return getBankAccountDetails({ bankAccountId: this.bankAccountId })
            .then(result => {
                this.bankAccountName = result.Name;
            })
            .catch(error => {
                this.error = error;
            });
    }

    openPaymentArrangementRecord() {
        this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
          if (isConsole) {
            this.invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
              this.invokeWorkspaceAPI('openSubtab', {
                parentTabId: focusedTab.tabId,
                recordId: this.paymentArrangementId,
                focus: true
              }).then(tabId => {
              });
            });
          }
        });
        setTimeout(() => {
            getRecordNotifyChange([{recordId: this.paymentArrangementId}]);
        }, 5000);
      }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });
            window.dispatchEvent(apiEvent);
        });
    }

    showErrorMessage(messageText){
        const evt = new ShowToastEvent({
            title: 'Payment Arrangements',
            message: messageText,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    calculateOccurrence(){
        if(this.paymentType == this.CollectionCaseConstants.APS_TYPE_ONE_TIME &&
            this.transactionAmountACH != null && this.debitDateACH != null){
            this.template.querySelector('lightning-input-field[data-name="occurrence"]').value = 1;
            this.noOfOccurrence = 1;
            this.apsPayableAmount = this.transactionAmountACH;
            this.template.querySelector('lightning-input-field[data-name="apsTotalPayableAmt"]').value = this.apsPayableAmount;
        }else if(this.paymentType == this.CollectionCaseConstants.APS_TYPE_RECURRING){
            if(this.transactionAmountACH != null && this.paymentFrequency != null &&
            this.achStartDate != null && this.achEndDate != null && this.debitDateACH != null){
                calculatePaymentOccurrence({ transactionAmount: this.transactionAmountACH, frequency: this.paymentFrequency, startDate: this.achStartDate, endDate: this.achEndDate, debitDate: this.debitDateACH })
                .then(result => {
                    this.template.querySelector('lightning-input-field[data-name="occurrence"]').value = result;
                    this.noOfOccurrence = result;
                    this.apsPayableAmount = this.noOfOccurrence * this.transactionAmountACH;
                    this.template.querySelector('lightning-input-field[data-name="apsTotalPayableAmt"]').value = this.apsPayableAmount;
                }).catch(error => {
                    this.error = error;
                    console.log('error:' + JSON.stringify(this.error));
                });
            }
        }else {
            this.template.querySelector('lightning-input-field[data-name="occurrence"]').value = '';
            this.noOfOccurrence = 0;
            this.apsPayableAmount = 0;
            this.template.querySelector('lightning-input-field[data-name="apsTotalPayableAmt"]').value = '';
        }
    }
}