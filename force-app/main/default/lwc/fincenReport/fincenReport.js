import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import readTextDocumentContent from '@salesforce/apex/FinCenController.readTextDocumentContent';
import getFinCenReportRecord from '@salesforce/apex/FinCenController.getFinCenReportRecord';

export default class FincenReport extends LightningElement {
    @track textFiles = [];
    @track runJobError;
    @track recordList;
    @track loading = false;

    readFile(fileSource) {
        return new Promise((resolve, reject) => {
            const fileReader = new FileReader();
            const fileName = fileSource.name;
            fileReader.onerror = () => reject(fileReader.error);
            fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1]});
            fileReader.readAsDataURL(fileSource);
        });
    }

    async handleFileChange(event) {
        this.loading = true;
        this.textFiles = await Promise.all(
            [...event.target.files].map(file => this.readFile(file))
        );

        readTextDocumentContent({documentList : this.textFiles})
        .then(result => {
            this.showToastMessage(
                ' FinCen Report is under processing for finding matches!', 'If matches found, report will be available under FinCen Report', 'success'
            );
            this.loading = false;
        })
        .catch(error =>{
            this.runJobError = error;
        })
    }

    @wire(getFinCenReportRecord)
    finCenAllReport({data, error}) {
        if(data) {
            this.recordList = data;
            this.error = undefined;
        }else {
            this.recordList =undefined;
            this.error = error;
        }
    }

    get url() {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        if(baseURL.indexOf('my.salesforce.com') > -1) {
            baseURL.replace('.my.salesforce.com', '--c.documentforce.com');
        }
        return baseURL + '/servlet/servlet.FileDownload?file=' + this.recordList[0]['Id'];
    }

    get isLoading() {
        if (this.isError) {
            return false;
        }
        return this.loading;
    }

    get isError() {
        return this.errors.length > 0;
    }

    get errors() {
        let errors = [];
        if (this.runJobError) {
            errors = errors.concat(this.runJobError);
        }

        if (errors.length > 0) {
            console.error(JSON.stringify(errors, null, 2));
        }
        return errors;
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}