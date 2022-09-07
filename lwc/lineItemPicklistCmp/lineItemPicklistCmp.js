import { api, LightningElement, track, wire } from 'lwc';
import getLineItemsList from '@salesforce/apex/LineItemPicklistCtrl.getLineItemsList';

export default class LineItemPicklistCmp extends LightningElement {
    
    @api recordId;
    @api label;
    @api labelMode;
    @api lineItem;
    selectedRecord = {};
    @track lineItemList = [];
    
    value = [];
    @wire(getLineItemsList, { recordId: '$recordId' })
    wiredTicketList({ error, data }) {
       
            if (data) {               
                // var allTicketList = [];
                console.log(JSON.stringify(data) + 'tickets');
                for (var i = 0; i < data.length; i++) {
                    console.log('id=' + data[i].Id);
                    this.lineItemList = [...this.lineItemList, {value: data[i].Id, label: data[i].Name}]
                }

            } else if (error) {
                this.error = error;
            }      
    }

    get lineItemList() { 
        return this.lineItemList;
    }

    handleSelect(event) {
        let input = this.template.querySelector("[data-field='lineItem']").value; 
        //this.handleOption(input);
        this.sendValues(input);        
    }

    handleOption(value){ 
            let option = this.lineItemList.find(option => option.value === value);
            this.value.push(option);        
    }
    sendValues(input) {
        const oEvent = new CustomEvent('lineitemvalue',
            {
                'detail':  input 
            }
        );
        this.dispatchEvent(oEvent);
    }
}