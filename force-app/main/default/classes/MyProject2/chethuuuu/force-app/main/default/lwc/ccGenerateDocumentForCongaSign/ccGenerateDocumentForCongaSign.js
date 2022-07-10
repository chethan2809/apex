import { LightningElement, wire, api } from 'lwc';
import getPaymentArrangementById from '@salesforce/apex/CollectionCaseDB.getPaymentArrangementById';
import generateCongaDocumentURL from '@salesforce/apex/CollectionCongaGenerateURL.generateCongaDocumentURL';
import { NavigationMixin } from 'lightning/navigation';

export default class CcGenerateDocumentForCongaSign extends NavigationMixin(LightningElement) {

    @api recordId;
    paymentArrangement;
    congaUrl;

    @wire(getPaymentArrangementById, { paymentArrangementId: '$recordId' })
    wiredPaymentArrangement({ error, data }) {
        if (data) {
            this.paymentArrangement = data;
            console.log('Data:'+JSON.stringify(this.paymentArrangement));
            generateCongaDocumentURL({ paymentArrangementId: this.recordId, contactId: this.paymentArrangement.Contact__c })
            .then(result => {
                console.log('Result:'+JSON.stringify(result));
                this.congaUrl = result;
            }).catch(error => {
                this.error = error;
                console.log('error:' + JSON.stringify(this.error));
            });
        } else if (error) {
            this.error = error;
            console.log('Error:'+JSON.stringify(this.error));
        }
    }
    handleGenerateDocClick(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.congaUrl
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }
}