import { LightningElement, track, wire } from 'lwc';
import getAllResources from '@salesforce/apex/dispatcherCtrl.getAllResources';
import getAllResourcesByFilters from '@salesforce/apex/dispatcherCtrl.getAllResourcesByFilters';  
import getRegionList from '@salesforce/apex/dispatcherCtrl.getRegionList';

export default class EmployeeTestCmp extends LightningElement {

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

    connectedCallback(){
        this.getDate();
    }

    

    // handleValueChange(event){
    // }
    getDate() {
        let currentDate = new Date();
        currentDate.setDate(currentDate.getDate());
        const tomorrow = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(
            currentDate.getDate()+ 1 ).padStart(2, '0')}`; 
        this.defaultDate = tomorrow;
        this.bufferDate  = tomorrow;
    }
    @wire(getAllResources) wiredgetAllResources({data,error}){
        if(data){
            this.getAllResource = [...JSON.parse(data)];
        }else{
            console.log(error+' error');
        }
    }

    

@wire(getRegionList)
   wiredRegionList({ error, data }) {
       try{
        if (data) {
         

            for (var i = 0; i <= data.length; i++) {
                this.regionLists = [...this.regionLists, { value: data[i].Id, label: data[i].Name }];
            }

        } else if (error) {
            this.error = error;

        }
       }catch (e){
        console.log('error'+ e);
       }
        
    }

    handleResource(event){
        this.spinnerStatus = false;
        let curName = event.target.value;   
        this.bufferName = curName;
        let regionName = this.regionNames;
        let enterDate;  

        if(this.filterDate!=null){
            enterDate = this.filterDate;
        }else{
            enterDate = null;
        } 
          
                
        getAllResourcesByFilters({ resource : curName, fDate : enterDate, fRegion : regionName })
        .then(result=>{ 
                this.spinnerStatus = true;
                this.getAllResource = JSON.parse(result);
        })
        .catch(error=>{
                this.spinnerStatus = true; 
        }) 
    }
    

    handleRegion(event){ 
        this.spinnerStatus = false; 
        let enterDate; 
        let resName;

        if(this.filterDate!=null){
            enterDate = this.filterDate;
        }else{
            enterDate = null;
        } 
        
        if(this.bufferName == undefined || this.bufferName=='undefined'){
            resName = null;
        }else{
            resName = this.bufferName;
        }

        this.regionNames = [...event.detail.values]; 
 
            //if(resourceName.trim()){
        
                
                getAllResourcesByFilters({ resource : resName, fDate : enterDate, fRegion : this.regionNames })
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
        let regionName = this.regionNames; 
         if(enterDate!=null){
            this.filterDate = event.target.value;
         }else{
            event.target.value = this.bufferDate;
            this.filterDate = this.bufferDate;
         }
        if(this.filterDate!=null){  
            getAllResourcesByFilters({ resource : this.bufferName, fDate : this.filterDate, fRegion : this.regionNames })
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