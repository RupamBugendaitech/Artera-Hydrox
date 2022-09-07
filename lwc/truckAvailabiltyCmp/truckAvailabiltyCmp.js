import { LightningElement, track, wire } from 'lwc';
import getAllAsset from '@salesforce/apex/TruckAvailabiltyCtrl.getAllAsset';
import getRegionList from '@salesforce/apex/TruckAvailabiltyCtrl.getRegionList';
import getAllAssetsByFilters from '@salesforce/apex/TruckAvailabiltyCtrl.getAllAssetsByFilters'; 


export default class TruckAvailabiltyCmp extends LightningElement {
    @track defaultDate;
    @track bufferDate;
    @track filterDate;
    @track bufferName;
    @track getAllResource;
    @track getAllResourceNew = [];
    @track filterData = [];
    @track regionLists = [];
    @track regionNames = [];
    region = '';
    // picklistValues;
    // error;
    spinnerStatus = true;

    connectedCallback() {
        this.getDate();
    }



    // handleValueChange(event){
    // }
    getDate() {
        let currentDate = new Date();
        currentDate.setDate(currentDate.getDate());
        const tomorrow = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(
            currentDate.getDate() + 1).padStart(2, '0')}`;
        this.defaultDate = tomorrow;
        this.bufferDate  = tomorrow;
        this.filterDate  = tomorrow;
    }
    @wire(getAllAsset) wiredgetAllAsset({ data, error }) {
        if (data) {
            this.getAllResource = [...JSON.parse(data)];
        } else {
            console.log(error + ' error');
        }
    }



    @wire(getRegionList)
    wiredRegionList({ error, data }) {
        try {
            if (data) {


                for (var i = 0; i <= data.length; i++) {
                    this.regionLists = [...this.regionLists, { value: data[i].Id, label: data[i].Name }];
                }

            } else if (error) {
                this.error = error;

            }
        } catch (e) {
            console.log('error' + e);
        }

    }

    handleAsset(event){
        this.spinnerStatus = false;
        let resourceName = event.target.value; 
        this.bufferName = event.target.value;
        let onDate = this.filterDate;
        let regionName = this.regionNames;
 
        getAllAssetsByFilters({ resource : resourceName, fDate : onDate, fRegion : regionName })
        .then(result=>{ 
                this.spinnerStatus = true;
            this.getAllResource = JSON.parse(result);
        })
        .catch(error=>{
                this.spinnerStatus = true;
            console.log(error);
        })
          
    }


    handleRegion(event){ 
        this.spinnerStatus = false; 

        let enterDate; 

        if(this.filterDate!=null){
            enterDate = this.filterDate;
        }else{
            enterDate = null;
        } 
        this.regionNames = [...event.detail.values]; 
 
            //if(resourceName.trim()){
                
                getAllAssetsByFilters({ resource : this.bufferName, fDate : this.filterDate, fRegion : this.regionNames })
                .then(result=>{ 
                     this.spinnerStatus = true;
                    this.getAllResource = JSON.parse(result);
                })
                .catch(error=>{
                     this.spinnerStatus = true;
                    console.log(error);
                })
            //}
    }


    get regionsList() {
        return this.regionLists;
    }

    handleDateEmp(event){
        this.spinnerStatus = false;          
        let enterDate = event.target.value;  
         if(enterDate!=null){
            this.filterDate = event.target.value;
         }else{
            event.target.value = this.bufferDate;
            this.filterDate    = this.bufferDate;
         }

        if(this.filterDate!=null){
            getAllAssetsByFilters({ resource : this.bufferName, fDate : this.filterDate, fRegion : this.regionNames })
                .then(result=>{ 
                     this.spinnerStatus = true;
                    this.getAllResource = JSON.parse(result);
                })
                .catch(error=>{
                     this.spinnerStatus = true;
                    console.log(error);
                })
        }      
    }

   


}