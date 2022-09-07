import { api, LightningElement, track, wire } from 'lwc';
import getTicketNumberLists from '@salesforce/apex/jobTicketPicklist.getTicketNumberLists'

export default class TicketPicklist extends LightningElement {
    ticket = '';
    @api recordId;
    selectedRecord = {};
    @track ticketLists = [];
    
    value = [];
    @wire(getTicketNumberLists, { recordId: '$recordId' })
    wiredTicketList({ error, data }) {
       
            if (data) {               
                // var allTicketList = [];
                console.log(JSON.stringify(data) + 'tickets');
                for (var i = 0; i < data.length; i++) {
                    console.log('id=' + data[i].Id);
                    this.ticketLists = [...this.ticketLists, {value: data[i].Id, label: data[i].Name}]
                }

            } else if (error) {
                this.error = error;
            }      
    }

    get ticketLists() {
        console.log(this.ticketLists + 'ticket list' );
        return this.ticketLists;
    }

    handleSelect(event) {
        let input = this.template.querySelector("[data-field='ticket']").value;
        console.log(input + ' value is');
        //this.handleOption(input);
        this.sendValues(input);        
    }

    handleOption(value){ 
            let option = this.ticketLists.find(option => option.value === value);
            this.value.push(option);        
    }
    sendValues(input) {
        const oEvent = new CustomEvent('ticketvalue',
            {
                'detail':  input 
            }
        );
        this.dispatchEvent(oEvent);
    }
}