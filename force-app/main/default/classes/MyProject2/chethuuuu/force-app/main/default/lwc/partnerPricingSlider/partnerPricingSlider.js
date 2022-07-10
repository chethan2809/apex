import { LightningElement, api } from 'lwc';

export default class PartnerPricingSlider extends LightningElement {

    @api currentValue;
    @api minValue;
    @api maxValue;
    @api sliderType;
    @api pricingRecord = {};
    finalPricingRecord = {};

    renderedCallback() {
        this.setBallonPosition();
    }

    get isTerm() {
        return (this.sliderType && this.sliderType == "Term");
    }

    get isLoanAmount() {
        return (this.sliderType && this.sliderType == "Loan Amount");
    }

    get isCommission() {
        return (this.sliderType && this.sliderType == "Commission");
    }

    handleSliderDrag(event) {
        this.currentValue = event.target.value;
    }

    handleSliderChange(event) {
        this.currentValue = event.target.value;
        this.finalPricingRecord = {...this.pricingRecord};
        if(Object.entries(this.finalPricingRecord).length > 0) {
            if(this.sliderType == "Loan Amount") {
                this.finalPricingRecord.Selected_Amount__c = this.currentValue;
            } else if (this.sliderType == "Term") {
                this.finalPricingRecord.Term__c = this.currentValue;
            } else if(this.sliderType == "Commission") {
                this.finalPricingRecord.Standard_Commission__c = this.currentValue;
            }

            const selectedEvent = new CustomEvent("sliderchange", {
                detail: this.finalPricingRecord
            });
            this.dispatchEvent(selectedEvent);
        }
    }

    setBallonPosition() {
        const sliderSpan = this.template.querySelector("span");
        sliderSpan.textContent = this.currentValue;
        let pos = this.calculateBalloonPosition(this.currentValue, this.minValue, this.maxValue, this.sliderType);
        sliderSpan.style.left = pos;
        if(this.sliderType == "Loan Amount"){
            if(sliderSpan.textContent.length >5){
                sliderSpan.style.fontSize = "7px";
            } else {
                sliderSpan.style.fontSize = "11px";
            }
        }
    }

    calculateBalloonPosition(val, min, max, type){
        let balloonPos = Number(((val - min) * 100) / (max - min));
        let percentage = Number((val / max) * 100);

        if(type == 'Term' && percentage < 20) {
            balloonPos = balloonPos + 6;
        } if(type == 'Term' && percentage < 40) {
            balloonPos = balloonPos + 5;
        } else if(type == 'Term' && percentage < 60) {
            balloonPos = balloonPos + 4;
        } else if(type == 'Term' && percentage < 80) {
            balloonPos = balloonPos + 2;
        } else if(type == 'Term' && percentage < 100) {
            balloonPos = balloonPos + 1;
        } else if(type == 'Loan Amount' && percentage < 15) {
            balloonPos = balloonPos + 4;
        } else if(type == 'Loan Amount' && percentage < 40) {
            balloonPos = balloonPos + 3;
        } else if(type == 'Loan Amount' && percentage < 65) {
            balloonPos = balloonPos + 2;
        } else if(type == 'Loan Amount' && percentage <= 100) {
            balloonPos = balloonPos + 1;
        } else if(type == 'Commission' && percentage < 15) {
            balloonPos = balloonPos + 4;
        } else if(type == 'Commission' && percentage < 50) {
            balloonPos = balloonPos + 3;
        } else if(type == 'Commission' && percentage < 80) {
            balloonPos = balloonPos + 2;
        } else if(type == 'Commission' && percentage <= 100) {
            balloonPos = balloonPos + 1;
        }
        return balloonPos + "%";
    }
}