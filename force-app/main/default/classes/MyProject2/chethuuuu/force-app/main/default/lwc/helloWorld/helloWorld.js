import {LightningElement,api } from 'lwc';

export default class HelloWorld extends LightningElement {
  @api myText='Hello World';
    onChangeEvent(event){
        this.myText=event.target.value;

    }

}