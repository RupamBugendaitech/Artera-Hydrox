import { LightningElement, wire, track, api } from "lwc";
import updateAssignmentData from "@salesforce/apex/dispatcher2ctrler.updateAssignmentData";
import updateTicketData from "@salesforce/apex/dispatcher2ctrler.updateTicketData";
import getAllJobAllocationsForDis from "@salesforce/apex/dispatcher2ctrler.getAllJobAllocationsForDis";
import getAllJobAllocationsForDisRefreshData from "@salesforce/apex/dispatcher2ctrler.getAllJobAllocationsForDisRefreshData";
// import getSearchList from '@salesforce/apex/dispatcher2ctrler.getSearchList';
// import getSearchListByDate from '@salesforce/apex/dispatcher2ctrler.getSearchListByDate';
import getSearchListByFilter from "@salesforce/apex/dispatcher2ctrler.getSearchListByFilter";
import DispatchJob from "@salesforce/apex/DispatchJobsInBulk.DispatchJob";
import getRegionList from "@salesforce/apex/dispatcherCtrl.getRegionList";
import getAllResources from '@salesforce/apex/dispatcherCtrl.getAllResources';
import getAllResourcesByFilters from '@salesforce/apex/dispatcherCtrl.getAllResourcesByFilters';
// import getAllResourcesByFilterDate from '@salesforce/apex/dispatcherCtrl.getAllResourcesByFilterDate';

//import getCount from "@salesforce/apex/dispatcher2ctrler.getCount";

// import { refreshApex } from '@salesforce/apex';
import { createRecord } from "lightning/uiRecordApi";
import { deleteRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";

//import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// import { NavigationMixin } from 'lightning/navigation';
import TICKET_OBJECT from "@salesforce/schema/Job_Ticket__c";
import TICKET_ID from "@salesforce/schema/Job_Ticket__c.Id";
import JOB_ID_TKT from "@salesforce/schema/Job_Ticket__c.Job1__c";
import LOCATION from "@salesforce/schema/Job_Ticket__c.Location__c";
import ASSIGNMENT_OBJECT from "@salesforce/schema/Artera_Job_Allocation__c";
import JOB_ID_All from "@salesforce/schema/Artera_Job_Allocation__c.Job__c";
import ALLOCATION_ID from "@salesforce/schema/Artera_Job_Allocation__c.Id";
import RESOURCE from "@salesforce/schema/Artera_Job_Allocation__c.Artera_Resource__c";

import NPRIORITY from "@salesforce/schema/Artera_Job__c.Priority__c";
import NCUSREFNO from "@salesforce/schema/Job_Ticket__c.Customer_Reference_Number__c";
import disIco from "@salesforce/resourceUrl/images";

export default class dispatcher extends LightningElement {
  @api recordId;
  @track records;
  @track bufferedDataAll;
  @track bufferedDataMainAll;
  @track bufferedDataMy;
  @track bufferedDataMainMy;
  @track filterDate;
  @track regionLists = [];
  @track regionNames = [];

  error;
  @track isModalOpenAss = false;
  @track isModalOpenTkt = false;
  @track isEModalOpenAss = false;
  @track isEModalOpenJob = false;
  @track isEModalOpenTkt = false;
  @track selectedJobId;
  @track selectedAllocationId;
  @track searchKeyword = null;
  @track searchByDate = null;
  @track searchByYard = [];
  @track defaultDate;
  @track defaultLookupId;

  @track newJobCountsMain=0;
  @track allResourceCountAll = 0;
  @track allResourceCount = 0;
  @track resourceCount = 0; 
  @track totalJobs = 0;
  @track totalJobsMain = 0;
  @track totalUnassignedJobsMain = 0;
  @track totalNewJobsMainAll = 0;
  @track totalNewJobsMainMy = 0;
  @track totalJobsMainAll = 0;
  @track totalJobsMainMy = 0;


  @track lookpResourceId;
  @track lookpCustomerId;
  @track lookpRegionId;
  @track lookpSupervisorId;
  @track lookpAssetId;
  @track lookpContactId;
  @track lookpProjectNoId;
  @track lookpWorkOrderId;
  @track isLookupUsed = false;

  @track activeModeType = "My";
  @track activeIndex = null;
  spinnerStatus = false;
  //@track jobList = [{'Show All Jobs','Show My Jobs'];

  disIco = disIco + "/images/dispatch-icon-5-removebg-preview.png";
  @track myJobs;
  @track allJobs; 
  @track unassignedTotal;
//   @wire(getCount)
//   wiredCounts ({ error, data }) {
//     if (data) {
//     console.log('data'+JSON.stringify(data));
//       this.unassignedTotal = data; 
//    } else if (error) { 
//        this.error = error;  
//   }
// }

  connectedCallback() {
    this.getDate();
  }

  @wire(getRegionList)
  wiredRegionList({ error, data }) {
    try {
      if (data) {
        for (var i = 0; i <= data.length; i++) {
          this.regionLists = [
            ...this.regionLists,
            { value: data[i].Id, label: data[i].Name }
          ];
        }
      } else if (error) {
        this.error = error;
      }
    } catch (e) {
      console.log("error" + e);
    }
  }

  get regionsList() {
    return this.regionLists;
  }

  @wire(getAllResources) wiredgetAllResources({data,error}){
    if(data){
        this.getAllResource = [...JSON.parse(data)];
        this.allResourceCountAll = this.getAllResource.length;
        this.allResourceCount    = this.getAllResource.length;
        this.resourceCount       = this.getAllResource.length;
    }else{
        console.log(error+' error');
    }
}
  // @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: NSTATUS })
  // getAllJobStatusValues;

  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: NPRIORITY
  })
  getAllJobPriorityValues;

  getDate() {
    let currentDate = new Date();
    currentDate.setDate(currentDate.getDate());
    const tomorrow = `${currentDate.getFullYear()}-${String(
      currentDate.getMonth() + 1
    ).padStart(2, "0")}-${String(currentDate.getDate()).padStart(2, "0")}`;
    //// console.log('Yes '+ ret);
    this.defaultDate = tomorrow;
  }

  get modalClassAss() {
    return this.isModalOpenAss
      ? "slds-modal slds-modal_small slds-fade-in-open"
      : "slds-modal";
  }
  get modalBackdropClassAss() {
    return this.isModalOpenAss
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  get modalClassTkt() {
    return this.isModalOpenTkt
      ? "slds-modal slds-modal_small slds-fade-in-open"
      : "slds-modal";
  }
  get modalBackdropClassTkt() {
    return this.isModalOpenTkt
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  get editModalClassJob(){
    return this.isEModalOpenJob
    ? "slds-modal slds-modal_small slds-fade-in-open slds-scrollable_y"
    : "slds-modal";
  }
  get editModalBackdropClassJobDetails() {
    return this.isEModalOpenJob
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  get editModalClassAss() {
    return this.isEModalOpenAss
      ? "slds-modal slds-modal_small slds-fade-in-open"
      : "slds-modal";
  }
  get editModalBackdropClassAss() {
    return this.isEModalOpenAss
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }

  get editModalClassTkt() {
    return this.isEModalOpenTkt
      ? "slds-modal slds-p-around_medium slds-modal_small slds-fade-in-open"
      : "slds-modal";
  }
  get editModalBackdropClassTkt() {
    return this.isEModalOpenTkt
      ? "slds-backdrop slds-p-around_medium slds-modal_small slds-backdrop_open"
      : "slds-backdrop";
  }
  

  @track getAllJobAllocations;
  @track isShowResult = true;
  @track showSearchedValues = false;
  @track iconType = "utility:chevronright";

  ismyjob = true;
  @api jobAllocId;
  searchJobs;
     
  _wiredJobDataAll;
  @wire(getAllJobAllocationsForDis, { filter: "All", needQuerying: true })
  wiredRelatedgetAllResources(wireResultAll) {
    const { data, error } = wireResultAll;
    this._wiredJobDataAll = wireResultAll;
    var actIndex1 = this.activeIndex;
    let newJobCounts = 0;
    let countJob  =  0;
    if (this.activeModeType == "All") {
      if (data) {
        this.activeModeType = "All";
       // this.allJobs=data.length;
        //console.log(' All Job Size::');
        if (data.length > 0 && this.isShowResult) {
          this.records = data.map(function (currentItem, index, actArray) {
            if(currentItem.objJobs.RecordType.Name == 'Customer'){
              countJob++;
            } 
            if(currentItem.objJobs.Status__c=='New'){ 
              newJobCounts++;              
            } 

            if(currentItem.projectName=='HydroX Leave'){
              //leaveCount++; 
              if(currentItem.jobAllocations!=null || currentItem.jobAllocations!=undefined){
                if(currentItem.jobAllocations.length>0){                      
                  // console.log('allocation Length '+JSON.stringify(currentItem.jobAllocations.length));
                  // console.log('allocation '+JSON.stringify(currentItem.jobAllocations));

                  
                  totalResource = totalResource+currentItem.jobAllocations.length;
                }
              }
              
           }
            if (
              currentItem.objJobs.Start_Date__c != null ||
              currentItem.objJobs.Start_Date__c != undefined
            ) {
              let duration = currentItem.objJobs.Start_Date__c;
              let milliseconds = Math.floor((duration % 1000) / 100),
                seconds = Math.floor((duration / 1000) % 60),
                minutes = Math.floor((duration / (1000 * 60)) % 60),
                hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

              hours = hours < 10 ? "0" + hours : hours;
              minutes = minutes < 10 ? "0" + minutes : minutes;
              seconds = seconds < 10 ? "0" + seconds : seconds;

              if (actIndex1 == index) {
                return {
                  ...currentItem,
                  IsOpen: true,
                  Time:
                    hours + ":" + minutes + ":" + seconds + "." + milliseconds
                };
              } else {
                return {
                  ...currentItem,
                  IsOpen: false,
                  Time:
                    hours + ":" + minutes + ":" + seconds + "." + milliseconds
                };
              }
            } else {
              if (actIndex1 == index) {
                return { ...currentItem, IsOpen: true };
              } else {
                return { ...currentItem, IsOpen: false };
              }
            }
          });
            
          this.totalJobs = countJob;
          this.totalJobsMainAll = countJob;
          this.totalNewJobsMainAll = newJobCounts;
          this.newJobCountsMain = newJobCounts;
          this.bufferedDataMainAll = this.records;
          this.bufferedDataAll = this.records; 
          //console.log(this.bufferedDataMainAll);
          this.showSearchedValues = true;
          this.spinnerStatus = true;
        } else if (data.length == 0) {
          this.records = [];
          // this.getAllJobAllocations = [];
          this.totalJobsMainAll = 0; 
          this.totalNewJobsMainAll = 0;
          this.isShowResult = true;
          this.showSearchedValues = false;
          this.spinnerStatus = true;
        }
      } else if (error) {
        this.error = error;
        this.spinnerStatus = true;
      }
    }
  }

  _wiredJobDataMy;
  @wire(getAllJobAllocationsForDis, { filter: "My", needQuerying: true })
  wiredRelatedgetMyResources(wireResultMy) {
    // console.log('My ');
    const { data, error } = wireResultMy;
    this._wiredJobDataMy = wireResultMy;
    var actIndex = this.activeIndex;
    let newJobCounts = 0;
    let countJob   = 0;
    if (this.activeModeType == "My") {
      if (data) {
        this.activeModeType = "My"; 
 
        if (data.length > 0 && this.isShowResult) {
            this.records = data.map(function (currentItem, index, actArray) {
            // console.log('Status::'+currentItem.objJobs.Status__c);
            // currentItem.objJobs.Status__c!=null

              if(currentItem.objJobs.RecordType.Name == 'Customer'){
                  countJob++;
              } 

              if(currentItem.objJobs.Status__c=='New'){ 
                 newJobCounts++;              
               } 
            
           // console.log('StartDate:::'+currentItem.objJobs.Start_Date__c);
            if (
              currentItem.objJobs.Start_Date__c != null ||
              currentItem.objJobs.Start_Date__c != undefined
            ) {
              let duration = currentItem.objJobs.Start_Date__c;
              let milliseconds = Math.floor((duration % 1000) / 100),
                seconds = Math.floor((duration / 1000) % 60),
                minutes = Math.floor((duration / (1000 * 60)) % 60),
                hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

              hours = hours < 10 ? "0" + hours : hours;
              minutes = minutes < 10 ? "0" + minutes : minutes;
              seconds = seconds < 10 ? "0" + seconds : seconds;

              if (actIndex == index) {
                return {
                  ...currentItem,
                  IsOpen: true,
                  Time:
                    hours + ":" + minutes + ":" + seconds + "." + milliseconds
                };
              } else {
                return {
                  ...currentItem,
                  IsOpen: false,
                  Time:
                    hours + ":" + minutes + ":" + seconds + "." + milliseconds
                };
              }
            } else {
              if (actIndex == index) {
                return { ...currentItem, IsOpen: true };
              } else {
                return { ...currentItem, IsOpen: false };
              }
            }
           
          });
        //  console.log('New Job Count::: '+this.newJobCounts);
          this.resourceCount = this.allResourceCount;
          this.totalJobs = countJob;
          this.totalJobsMainMy = countJob; 
          this.newJobCountsMain = newJobCounts;
          this.totalNewJobsMainMy = newJobCounts;
          //console.log('AA '+this.newJobCountsMain);
          this.bufferedDataMainMy = this.records;
          this.bufferedDataMy = this.records;
          //console.log(this.records);
          this.showSearchedValues = true;
          this.spinnerStatus = true;
        } else if (data.length == 0) {
          this.records = [];
          this.totalJobsMainMy = 0; 
          this.totalNewJobsMainMy = 0;
          // this.getAllJobAllocations = [];
          this.isShowResult = true;
          this.showSearchedValues = false;
          this.spinnerStatus = true;
        }
      } else if (error) {
        this.error = error;
        this.spinnerStatus = true;
        this.totalJobsMainMy = 0; 
        this.totalNewJobsMainMy = 0;
      }
    }
  }

  cloneJob(event) {
    let srcjobrecordId = event.target.dataset.recordId;
    if (
      srcjobrecordId &&
      (srcjobrecordId.length == 15 || srcjobrecordId.length == 18)
    ) {
      cloneJob({ jobId: srcjobrecordId })
        .then()
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    }
  }

  onRecordSelection(event) {
    let objName = event.target.objectName;
    //// console.log('Current Obj '+objName);
    let currentRecordId = event.detail.variable1;

    if (objName == "Account") {
      this.lookpCustomerId = currentRecordId;
    } else if (objName == "Artera_Region__c") {
      this.lookpRegionId = currentRecordId;
    } else if (objName == "User") {
      this.lookpSupervisorId = currentRecordId;
    } else if (objName == "Artera_Resource__c") {
      this.lookpResourceId = currentRecordId;
    } else if (objName == "Asset__c") {
      this.lookpAssetId = currentRecordId;
    } else if (objName == "Contact") {
      this.lookpContactId = currentRecordId;
    } else if (objName == "Project__c") {
      this.lookpProjectNoId = currentRecordId;
    } else if (objName == "Work_Order__c") {
      this.lookpWorkOrderId = currentRecordId;
    }
    //// console.log(event.detail.variable1 + ' selected 1');
  }

  lookupRecord(event) {
    let objName = event.target.sObjectApiName;

    if (this.isLookupUsed == false) {
      //// console.log('is aa '+this.isLookupUsed);
    } else {
      //// console.log('is aas '+this.isLookupUsed);
    }
    if (event.detail.selectedRecord != undefined) {
      let currentRecordId = event.detail.selectedRecord.Id;

      if (objName == "Account") {
        this.lookpCustomerId = currentRecordId;
      } else if (objName == "Artera_Region__c") {
        this.lookpRegionId = currentRecordId;
      } else if (objName == "User") {
        this.lookpSupervisorId = currentRecordId;
      } else if (objName == "Artera_Resource__c") {
        this.lookpResourceId = currentRecordId;
      } else if (objName == "Asset__c") {
        this.lookpAssetId = currentRecordId;
      } else if (objName == "Contact") {
        this.lookpContactId = currentRecordId;
      } else if (objName == "Project__c") {
        this.lookpProjectNoId = currentRecordId;
      } else if (objName == "Work_Order__c") {
        this.lookpWorkOrderId = currentRecordId;
      }
    }
  }

  showModalAssignment(event) {
    this.isModalOpenAss = true;
    let curId = event.target.dataset.recordId;
    this.selectedJobId = curId;
    let jobTilte = event.target.dataset.title;
    this.template.querySelector("[data-field='JobName']").value = jobTilte;
  }

  closeModalAssignment() {
    this.resetAllLookupIds();
    this.isModalOpenAss = false;
    this.selectedJobId = "";
    this.template.querySelector("c-custom-lookup-cmp").handleRemove();
    // this.template.querySelector("[data-field='ResourceName']").value = '';
    this.template.querySelector("[data-field='JobName']").value = null;
  }

  showModalTicket(event) {
    this.isModalOpenTkt = true;
    let curId = event.target.dataset.recordId;
    this.selectedJobId = curId;
    let jobTilte = event.target.dataset.title;
    this.template.querySelector("[data-field='TJobName']").value = jobTilte;
  }

  closeModalTicket() {
    this.isModalOpenTkt = false;
    this.selectedJobId = "";
    this.resetAllLookupIds();
    this.template.querySelector("[data-field='Location']").value = "";
    this.template.querySelector("[data-field='TJobName']").value = "";
    this.template.querySelector("[data-field='NCUSREFNO']").value = "";
  }

  editShowModalAss(event) {
    this.isEModalOpenAss = true;
    this.isLookupUsed = true;
    let jobTitle = event.target.dataset.title;
    this.defaultLookupId = event.target.dataset.employee;
    let curId = event.target.dataset.recordId;
    this.selectedJobId = curId;
    this.template.querySelector(
      "[data-field='UJobAssignment']"
    ).value = jobTitle;
  }

  editShowModalJob(event) {
    this.isEModalOpenJob = true;
    // this.isLookupUsed = true;
    // let jobTitle = event.target.dataset.title;
    // this.defaultLookupId = event.target.dataset.employee;
    let curId = event.target.dataset.recordId;
    console.log('cur id', curId);
    this.selectedJobId = curId;
    // this.template.querySelector(
    //   "[data-field='UJobAssignment']"
    // ).value = jobTitle;
  }

  editCloseModalAss() {
    this.resetAllLookupIds();
    this.isEModalOpenAss = false;
    this.selectedJobId = "";
    this.isLookupUsed = false;
    this.defaultLookupId = "";
    this.template.querySelector("[data-field='UJobName']").value = "";
  }

  editCloseModalJobDetails(){
    this.isEModalOpenJob = false;
  }

  editShowModalTicket(event) {
    this.isEModalOpenTkt = true;
    let jobTitle = event.target.dataset.title;
    let location = event.target.dataset.location;
    let cusrefno = event.target.dataset.cusrefno;
    let curId = event.target.dataset.recordId;
    this.selectedJobId = curId;
    this.template.querySelector("[data-field='UJobName']").value = jobTitle;
    this.template.querySelector("[data-field='ULocation']").value = location;
    this.template.querySelector("[data-field='UCUSREFNO']").value = cusrefno;
  }

  editCloseModalTicket() {
    this.resetAllLookupIds();
    this.isEModalOpenTkt = false;
    this.selectedJobId = "";
    this.template.querySelector("[data-field='UJobName']").value = "";
    this.template.querySelector("[data-field='ULocation']").value = "";
    this.template.querySelector("[data-field='UCUSREFNO']").value = "";
  }

  saveAssignment(event) {
    this.spinnerStatus = false;
    let anyError = true;
    //// console.log('Active filter  '+this.activeModeType);
    if (
      this.lookpResourceId == "" ||
      this.lookpResourceId == null ||
      this.lookpResourceId == undefined
    ) {
      anyError = false; 
      this.notificationHandler('Error','Please Choose Any Resource','error');
    }
    if (anyError) {
      const fields = {};
      fields[JOB_ID_All.fieldApiName] = event.target.dataset.id;
      fields[RESOURCE.fieldApiName] = this.lookpResourceId;

      const recordInput = { apiName: ASSIGNMENT_OBJECT.objectApiName, fields };
      //// console.log(fields);
      //// console.log(recordInput+'record Inp');
      createRecord(recordInput)
        .then((details) => { 
          this.notificationHandler('Success','Job Assigned Successfully','sucess');
          this.afterEditRefresh();
        })
        .catch((error) => { 
          this.notificationHandler('Not Creates','Your Record Not Created, Please Try Contact to Admin.','error');
        })
        .finally(() => {
          //this.isLookupUsed = false;
          this.afterEditRefresh();
          this.spinnerStatus = true;
          this.resetAllIcons();
          this.closeModalAssignment();
          this.resetAllLookupIds();
        });
    }
  }

  saveTicket(event) {
    this.spinnerStatus = false;
    if (this.template.querySelector("[data-field='Location']").value == "") {
      this.spinnerStatus = true; 
      this.notificationHandler('Error','Please Fill Location.','error');
    } else {
      const fields = {};
      fields[JOB_ID_TKT.fieldApiName] = event.target.dataset.id;
      fields[LOCATION.fieldApiName] = this.template.querySelector(
        "[data-field='Location']"
      ).value;
      fields[NCUSREFNO.fieldApiName] = this.template.querySelector(
        "[data-field='NCUSREFNO']"
      ).value;

      const recordInput = { apiName: TICKET_OBJECT.objectApiName, fields };
      createRecord(recordInput)
        .then((details) => { 
          this.notificationHandler('Success','Ticket Created Successfully.','success');
          this.afterEditRefresh();
        })
        .catch((error) => { 
          this.notificationHandler('Not Creates','Your Record Not Created, Please Try Again '+ error,'error');          
        })
        .finally(() => {
          this.spinnerStatus = true;
          this.resetAllIcons();
          this.closeModalTicket();
          this.resetAllLookupIds();
          this.afterEditRefresh();
        });
    }
  }

  hideAndShow(event) {
    let indx = event.target.dataset.recordId;
    this.activeIndex = indx;
    if (this.records) {
      let recs = JSON.parse(JSON.stringify(this.records));
      let currVal = recs[indx].IsOpen;
      recs[indx].IsOpen = !currVal;
      if (recs[indx].IsOpen == false) {
        this.activeIndex = null;
      }
      this.records = recs;
      if (this.records[indx].IsOpen == true) {
        event.target.iconName = "utility:chevrondown";
      } else {
        event.target.iconName = "utility:chevronright";
      }
    }
  }

  resetAllIcons() {
    let fullData = this.template.querySelector(".ownTable");
    let allIcons = fullData.querySelectorAll(".icnClass");
    let actI = this.activeIndex;
    for (let i = 0; i < allIcons.length; i++) {
      if (actI == i) {
        allIcons[i].iconName = "utility:chevrondown";
      } else {
        allIcons[i].iconName = "utility:chevronright";
      }
    }
  }

  resetAllIconDefault() {
    let fullData = this.template.querySelector(".ownTable");
    let allIcons = fullData.querySelectorAll(".icnClass");
    this.activeIndex = null;

    for (let i = 0; i < allIcons.length; i++) {
      allIcons[i].iconName = "utility:chevronright";
    }
  }

  resetAllCheckboxes() {
    let fullData = this.template.querySelector(".ownTable");
    let allIcons = fullData.querySelectorAll(".checkbox");
    let actI = this.activeIndex;
    for (let i = 0; i < allIcons.length; i++) {
      allIcons[i].checked = false;
    }
  }

  resetAllLookupIds() {
    this.lookpResourceId = "";
    this.lookpCustomerId = "";
    this.lookpRegionId = "";
    this.lookpSupervisorId = "";
    this.lookpProjectNoId = "";
    this.lookpWorkOrderId = "";
    this.lookpAssetId = "";
  }

  // toggleJObs
  handleToggleJobs(event) {
    this.spinnerStatus = false;
    let newJobCounts = 0;
    let countJob  =  0;
    //// console.log('called');
    // this.template.querySelector("#searchVal").value = '';
    //  this.template.querySelector("#searchDate").value = '';
    this.searchKeyword = null;
    this.searchByDate = null;
    this.searchByYard = [];
    this.regionNames = [];
    this.template.querySelector("c-multi-select-picklist").clear();

    this.defaultDate = null;
    let label = event.target.value;
    this.activeIndex = null;
    this.resetAllIcons();
    console.log(this.searchByDate,' date');
    if (label == "Show My Jobs") {

    console.log(this.searchByDate,' date1');

      this.activeModeType = "My";
      getAllJobAllocationsForDis({ filter: "My", needQuerying: true })
        .then((data) => {
          if (data) {
            // console.log(data, 'my records');  
            if (data.length > 0 && this.isShowResult) {
              this.records = data.map(function (currentItem, index, actArray) {
             //console.log('2nd Status::'+currentItem.objJobs.Status);
                if(currentItem.objJobs.Status__c=='New'){ 
                  newJobCounts++;              
                } 
                if(currentItem.objJobs.RecordType.Name == 'Customer'){
                  countJob++;
                } 
                if (
                  currentItem.objJobs.Start_Date__c != null ||
                  currentItem.objJobs.Start_Date__c != undefined
                ) {
                  let duration = currentItem.objJobs.Start_Date__c;
                  let milliseconds = Math.floor((duration % 1000) / 100),
                    seconds = Math.floor((duration / 1000) % 60),
                    minutes = Math.floor((duration / (1000 * 60)) % 60),
                    hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                  hours = hours < 10 ? "0" + hours : hours;
                  minutes = minutes < 10 ? "0" + minutes : minutes;
                  seconds = seconds < 10 ? "0" + seconds : seconds;
                  return {
                    ...currentItem,
                    IsOpen: false,
                    Time:
                      hours + ":" + minutes + ":" + seconds + "." + milliseconds
                  };
                } else {
                  return { ...currentItem, IsOpen: false };
                }
              });
              
              this.totalJobs = countJob;            
              this.totalJobsMainMy = countJob;  
              this.newJobCountsMain = newJobCounts;
              this.totalNewJobsMainMy = newJobCounts;
              this.bufferedDataMainMy = this.records;
              // console.log(this.records);
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data.length == 0) {
              this.records = [];
              // this.getAllJobAllocations = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
              this.spinnerStatus = true;
            }
          } else {
            this.spinnerStatus = true;
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    } else {
      this.activeModeType = "All";
      getAllJobAllocationsForDis({ filter: "All", needQuerying: true })
        .then((data) => {
          if (data) {
            //// console.log(data);
            console.log('toggle All Job Size::'+data.length);
            //this.totalJobs=data.lenght;
            if (data.length > 0 && this.isShowResult) {
              this.records = data.map(function (currentItem, index, actArray) {

                if(currentItem.objJobs.RecordType.Name == 'Customer'){
                  countJob++;
                }

                if(currentItem.objJobs.Status__c=='New'){ 
                  newJobCounts++;              
                } 

                if (
                  currentItem.objJobs.Start_Date__c != null ||
                  currentItem.objJobs.Start_Date__c != undefined
                ) {
                  let duration = currentItem.objJobs.Start_Date__c;
                  let milliseconds = Math.floor((duration % 1000) / 100),
                    seconds = Math.floor((duration / 1000) % 60),
                    minutes = Math.floor((duration / (1000 * 60)) % 60),
                    hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                  hours = hours < 10 ? "0" + hours : hours;
                  minutes = minutes < 10 ? "0" + minutes : minutes;
                  seconds = seconds < 10 ? "0" + seconds : seconds;

                  return {
                    ...currentItem,
                    IsOpen: false,
                    Time:
                      hours + ":" + minutes + ":" + seconds + "." + milliseconds
                  };
                } else {
                  return { ...currentItem, IsOpen: false };
                }
              });
                
              this.totalJobs = countJob;
              this.totalJobsMainAll = countJob;
              this.totalNewJobsMainAll = newJobCounts;
              this.newJobCountsMain = newJobCounts;
              this.bufferedDataMainAll = this.records; 
              this.showSearchedValues = true;
              this.spinnerStatus = true;
              this.resourceCount = this.allResourceCount ;
            } else if (data.length == 0) {
              this.records = [];
              // this.getAllJobAllocations = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
              this.spinnerStatus = true;
            }
          } else {
            this.spinnerStatus = true;
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    }
  }

  handleRegion(event) { 
    this.resetAllIconDefault();
    this.spinnerStatus = false;
    // let filterYard = event.target.value;
    let curFilter = this.activeModeType;
    let actIndex1 = this.activeIndex;
    let newJobCounts = 0;
    let totalResource = 0; 
    let countJob  =  0;
  
    this.regionNames = [...event.detail.values]; 
    if(this.regionNames.length == 0){
      this.searchByYard = [];
      this.allResourceCount = this.allResourceCountAll;
    }else{
      this.searchByYard = [...this.regionNames];       
    }
     if (this.searchByYard.length == 0 && this.searchKeyword == null && this.searchByDate == null) {
      if (curFilter == "All") {
        this.records = this.bufferedDataMainAll;        
        this.totalJobs = this.totalJobsMainAll;
        this.newJobCountsMain = this.totalNewJobsMainAll;
        this.resourceCount = this.allResourceCount ;
      } else { 
        this.records   = this.bufferedDataMainMy;        
        this.totalJobs = this.totalJobsMainMy;
        this.newJobCountsMain = this.totalNewJobsMainMy; 
        this.resourceCount = this.allResourceCount;
      }
      
      this.allResourceCount = this.allResourceCountAll;
      this.resourceCount = this.allResourceCountAll;
      //this.resourceCount = 0;
      this.spinnerStatus = true;
      console.log('1 answer');
    } else {

      console.log('2 answer');
      getAllResourcesByFilters({ resource : null, fDate : this.searchByDate, fRegion : this.searchByYard })
      .then(result=>{ 
        console.log(result+' answer');
          if(result == null){
            this.allResourceCount = 0;
          }else{
            let resCount          = JSON.parse(result);
            this.allResourceCount = resCount.length;  
            resCount.forEach((element) => {
                //console.log('Internally '+element.Title);
                if(element.Title =='Unavailable'){
                  totalResource++;
                }
            }); 
          }
              console.log('called filter res '+result);              
              console.log('Real count '+this.allResourceCount);
              return getSearchListByFilter({
                filter: curFilter,
                searchKey: this.searchKeyword,
                searchByDate: this.searchByDate,
                fRegion: this.searchByYard,
                needQuerying: false
              });
      })
      .then((data) => {
        console.log(data);
         if (data) {
           if (data != "No") {
             this.records = data.map(function (currentItem, index, actArray) {
               if(currentItem.objJobs.RecordType.Name == 'Customer'){
                 countJob++;
               } 

 
               if(currentItem.objJobs.Status__c=='New'){ 
                 newJobCounts++;              
               } 
               if (
                 currentItem.objJobs.Start_Date__c != null ||
                 currentItem.objJobs.Start_Date__c != undefined
               ) {
                 let duration = currentItem.objJobs.Start_Date__c;
                 let milliseconds = Math.floor((duration % 1000) / 100),
                   seconds = Math.floor((duration / 1000) % 60),
                   minutes = Math.floor((duration / (1000 * 60)) % 60),
                   hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                 hours = hours < 10 ? "0" + hours : hours;
                 minutes = minutes < 10 ? "0" + minutes : minutes;
                 seconds = seconds < 10 ? "0" + seconds : seconds;

                 if (actIndex1 == index) {
                   return {
                     ...currentItem,
                     IsOpen: true,
                     Time:
                       hours +
                       ":" +
                       minutes +
                       ":" +
                       seconds +
                       "." +
                       milliseconds
                   };
                 } else {
                   return {
                     ...currentItem,
                     IsOpen: false,
                     Time:
                       hours +
                       ":" +
                       minutes +
                       ":" +
                       seconds +
                       "." +
                       milliseconds
                   };
                 }
               } else {
                 if (actIndex1 == index) {
                   return { ...currentItem, IsOpen: true };
                 } else {
                   return { ...currentItem, IsOpen: false };
                 }
               }
             });
             if (curFilter == "All") {
               this.bufferedDataAll = this.records;
             } else {
               this.bufferedDataMy = this.records;
             }
             
             this.totalJobs = countJob;
             console.log('All Res '+this.allResourceCountAll+' Total Res '+this.allResourceCount+' on leave '+totalResource);
             this.resourceCount = this.allResourceCount-totalResource;
             this.newJobCountsMain = newJobCounts;
             this.showSearchedValues = true;
             this.spinnerStatus = true;
           } else if (data == "No") {
             this.records = [];
             this.isShowResult = true;
             this.showSearchedValues = false;
             this.spinnerStatus = true;
           }
         }
       })
      .catch(error=>{
        this.error = error;
        this.spinnerStatus = true;
      });
    }
  }

  handleDate(event) {
    this.resetAllIconDefault();
    this.spinnerStatus = false;
    let filterDate = event.target.value;
    let curFilter = this.activeModeType;
    let actIndex1 = this.activeIndex;
    let newJobCounts = 0;
    let totalResource = 0;
    let countJob  =  0;

    if (filterDate != null) {
      this.searchByDate = filterDate;
    } else if (filterDate == null) {
      this.searchByDate = null;
    }

    if (this.searchByDate == null && this.searchKeyword == null  && this.searchByYard.length == 0) {
      if (curFilter == "All") {
        this.records = this.bufferedDataMainAll;        
        this.totalJobs = this.totalJobsMainAll;
        this.newJobCountsMain = this.totalNewJobsMainAll;
      } else { 
        this.records = this.bufferedDataMainMy;        
        this.totalJobs = this.totalJobsMainMy;
        this.newJobCountsMain = this.totalNewJobsMainMy;
      }
      this.resourceCount = this.allResourceCount ;
      this.spinnerStatus = true;
      //this.resourceCount = 0;
    } else {
      //console.log('date else date is ', this.searchByDate+' keyword is ', this.searchKeyword);
      // console.log('call');
      // console.log(curFilter+' , '+this.searchKeyword+' , '+this.searchByDate+' , '+this.searchByYard);
      // getSearchListByFilter({
      //   filter: curFilter,
      //   searchKey: this.searchKeyword,
      //   searchByDate: this.searchByDate,
      //   fRegion: this.searchByYard,
      //   needQuerying: false
      // })
      getAllResourcesByFilters({ resource : null, fDate : this.searchByDate, fRegion : this.searchByYard })
      .then(result=>{ 
        console.log(result+' answer');
          if(result == null){
            this.allResourceCount = 0;
          }else{
            let resCount          = JSON.parse(result);
            this.allResourceCount = resCount.length;  
            resCount.forEach((element) => {
                //console.log('Internally '+element.Title);
                if(element.Title =='Unavailable'){
                  totalResource++;
                }
            }); 
          } 
              return getSearchListByFilter({
                filter: curFilter,
                searchKey: this.searchKeyword,
                searchByDate: this.searchByDate,
                fRegion: this.searchByYard,
                needQuerying: false
              });
      })
        .then((data) => {
          //console.log(data);
          if (data) {
            if (data != "No") {
              this.records = data.map(function (currentItem, index, actArray) {
                if(currentItem.projectName!= null || currentItem.projectName!=undefined){
                  if(currentItem.objJobs.RecordType.Name == 'Customer'){
                    countJob++;
                  } 
                //   if(currentItem.projectName=='HydroX Leave'){
                //     //leaveCount++; 
                //     if(currentItem.jobAllocations!=null || currentItem.jobAllocations!=undefined){
                //       if(currentItem.jobAllocations.length>0){                      
                //         // console.log('allocation Length '+JSON.stringify(currentItem.jobAllocations.length));
                //         // console.log('allocation '+JSON.stringify(currentItem.jobAllocations));
                //         totalResource = totalResource+currentItem.jobAllocations.length;
                //       }
                //     }
                    
                //  }
                }
                if(currentItem.objJobs.Status__c=='New'){ 
                  newJobCounts++;              
                } 
                if (
                  currentItem.objJobs.Start_Date__c != null ||
                  currentItem.objJobs.Start_Date__c != undefined
                ) {
                  let duration = currentItem.objJobs.Start_Date__c;
                  let milliseconds = Math.floor((duration % 1000) / 100),
                    seconds = Math.floor((duration / 1000) % 60),
                    minutes = Math.floor((duration / (1000 * 60)) % 60),
                    hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                  hours = hours < 10 ? "0" + hours : hours;
                  minutes = minutes < 10 ? "0" + minutes : minutes;
                  seconds = seconds < 10 ? "0" + seconds : seconds;

                  if (actIndex1 == index) {
                    return {
                      ...currentItem,
                      IsOpen: true,
                      Time:
                        hours +
                        ":" +
                        minutes +
                        ":" +
                        seconds +
                        "." +
                        milliseconds
                    };
                  } else {
                    return {
                      ...currentItem,
                      IsOpen: false,
                      Time:
                        hours +
                        ":" +
                        minutes +
                        ":" +
                        seconds +
                        "." +
                        milliseconds
                    };
                  }
                } else {
                  if (actIndex1 == index) {
                    return { ...currentItem, IsOpen: true };
                  } else {
                    return { ...currentItem, IsOpen: false };
                  }
                }
              });
              if (curFilter == "All") {
                this.bufferedDataAll = this.records;
              } else {
                this.bufferedDataMy = this.records;
              }
              
              this.totalJobs = countJob;
              this.resourceCount= this.allResourceCount-totalResource;
              this.newJobCountsMain = newJobCounts;
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data == "No") {
              this.records = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
              this.spinnerStatus = true;
            }
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    }
  }

  handleSearch(event) { 
    this.spinnerStatus = false;
    let newJobCounts = 0;
    let totalResource = 0;
    let countJob  =  0;
    this.resetAllIconDefault();
    let searchBy = event.target.value;
    let curFilter = this.activeModeType;
    let actIndex1 = this.activeIndex;

    if (searchBy.length >= 3) {
      this.searchKeyword = searchBy;
    } else if (searchBy.length < 1) {
      this.searchKeyword = null;
    }

    console.log('search ', searchBy, 'search key', this.searchKeyword);

    // if (this.searchKeyword == null && this.searchByDate == null) {
    //     curBool = true;
    // } 
    if (this.searchByDate == null && this.searchKeyword == null && this.searchByYard.length == 0) {
      if (curFilter == "All") {
        this.records = this.bufferedDataMainAll;        
        this.totalJobs = this.totalJobsMainAll;
        this.newJobCountsMain = this.totalNewJobsMainAll;
      } else { 
        this.records = this.bufferedDataMainMy;        
        this.totalJobs = this.totalJobsMainMy;
        this.newJobCountsMain = this.totalNewJobsMainMy;
      }
      this.resourceCount = this.allResourceCount ;
      //this.resourceCount = 0;
      this.spinnerStatus = true;
      console.log('records', this.records);
      //console.log('search if date is ', this.searchByDate+' keyword is ', this.searchKeyword);
    } else {
      //console.log('serach else date is ', this.searchByDate+' keyword is ', this.searchKeyword); 
      // getSearchListByFilter({
      //   filter: curFilter,
      //   searchKey: this.searchKeyword,
      //   searchByDate: this.searchByDate,
      //   fRegion: this.searchByYard,
      //   needQuerying: false
      // })
      getAllResourcesByFilters({ resource : null, fDate : this.searchByDate, fRegion : this.searchByYard })
      .then(result=>{ 
        console.log(result+' answer');
          if(result == null){
            this.allResourceCount = 0;
          }else{
            let resCount          = JSON.parse(result);
            this.allResourceCount = resCount.length;  
            resCount.forEach((element) => {
                //console.log('Internally '+element.Title);
                if(element.Title =='Unavailable'){
                  totalResource++;
                }
            }); 
          }
              console.log('called filter res '+result);              
              console.log('Real count '+this.allResourceCount);
              return getSearchListByFilter({
                filter: curFilter,
                searchKey: this.searchKeyword,
                searchByDate: this.searchByDate,
                fRegion: this.searchByYard,
                needQuerying: false
              });
      })
        .then((data) => {

          console.log('records', this.records);
          //console.log(data);
          if (data) {
            if (data != "No") { 
              this.records = data.map(function (currentItem, index, actArray) {
                if(currentItem.objJobs.RecordType.Name == 'Customer'){
                  countJob++;
                } 

                if(currentItem.projectName!= null || currentItem.projectName!=undefined){
                //   if(currentItem.projectName=='HydroX Leave'){
                //     //leaveCount++; 
                //     if(currentItem.jobAllocations!=null || currentItem.jobAllocations!=undefined){
                //       if(currentItem.jobAllocations.length>0){                      
                //         // console.log('allocation Length '+JSON.stringify(currentItem.jobAllocations.length));
                //         // console.log('allocation '+JSON.stringify(currentItem.jobAllocations));
                //         totalResource = totalResource+currentItem.jobAllocations.length;
                //       }
                //     }
                    
                //  }
                }
                if(currentItem.objJobs.Status__c=='New'){ 
                  newJobCounts++;              
                } 
                if (
                  currentItem.objJobs.Start_Date__c != null ||
                  currentItem.objJobs.Start_Date__c != undefined
                ) {
                  let duration = currentItem.objJobs.Start_Date__c;
                  let milliseconds = Math.floor((duration % 1000) / 100),
                    seconds = Math.floor((duration / 1000) % 60),
                    minutes = Math.floor((duration / (1000 * 60)) % 60),
                    hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                  hours = hours < 10 ? "0" + hours : hours;
                  minutes = minutes < 10 ? "0" + minutes : minutes;
                  seconds = seconds < 10 ? "0" + seconds : seconds;

                  if (actIndex1 == index) {
                    return {
                      ...currentItem,
                      IsOpen: true,
                      Time:
                        hours +
                        ":" +
                        minutes +
                        ":" +
                        seconds +
                        "." +
                        milliseconds
                    };
                  } else {
                    return {
                      ...currentItem,
                      IsOpen: false,
                      Time:
                        hours +
                        ":" +
                        minutes +
                        ":" +
                        seconds +
                        "." +
                        milliseconds
                    };
                  }
                } else {
                  if (actIndex1 == index) {
                    return { ...currentItem, IsOpen: true };
                  } else {
                    return { ...currentItem, IsOpen: false };
                  }
                }
              });
              if (curFilter == "All") {
                this.bufferedDataAll = this.records;
              } else {
                this.bufferedDataMy = this.records;
              }
              
              this.totalJobs = countJob;
              this.resourceCount= this.allResourceCount-totalResource;
              this.newJobCountsMain = newJobCounts;
              this.showSearchedValues = true;
              this.spinnerStatus = true;
            } else if (data == "No") {
              this.records = [];
              this.isShowResult = true;
              this.showSearchedValues = false;
              this.spinnerStatus = true;
            }
          }
        })
        .catch(() => {
          this.error = error;
          this.spinnerStatus = true;
        });
    }

    // console.log('Mode '+this.activeModeType+' Date '+this.searchByDate+' filterKey '+this.searchKeyword+' search '+ curBool);
    // getSearchList({ filter: this.activeModeType, searchKey:  this.searchKeyword })
  }

  updateRecordAss(event) {
    // // console.log('called');
    this.spinnerStatus = false;
    let recId = event.currentTarget.dataset.id;
    let recTitle = this.template.querySelector("[data-field='UJobAssignment']")
      .value;

    if (this.lookpResourceId == "") {
       
      this.notificationHandler('Error','Please Choose Resource.','error');
    } else {
      let showMsg;
      showMsg = 'Job Assignment "' + recTitle + '" Updated.';
      const fields = {};
      fields[ALLOCATION_ID.fieldApiName] = recId;
      fields[RESOURCE.fieldApiName] = this.lookpResourceId;

      updateAssignmentData({ assObj: fields })
        .then(() => { 
          this.notificationHandler('Success',showMsg,'success');
          this.afterEditRefresh();
        })
        .catch((error) => { 
          this.notificationHandler('Error','Something Wrong Here.','error');
        })
        .finally(() => {
          this.spinnerStatus = true;
          this.editCloseModalAss();
          this.resetAllLookupIds();
          this.resetAllIcons();
          this.template.querySelector("[data-field='ULocation']").value = "";
          this.afterEditRefresh();
        });
    }
  }

  updateRecordTicket(event) {
    //// console.log('called');
    this.spinnerStatus = false;
    let recId = event.currentTarget.dataset.id;
    // let recType = event.currentTarget.dataset.type;
    let uLocation = this.template.querySelector("[data-field='ULocation']")
      .value;
    let recTitle = this.template.querySelector("[data-field='UJobName']").value;
    let cusRefNo = this.template.querySelector("[data-field='UCUSREFNO']")
      .value;
    // // console.log(uLocation+' oo'+ recId);

    if (uLocation == "") {
      this.notificationHandler('Error','Please Fill The Location.','error');
    } else {
      let showMsg;
      showMsg = 'Job Ticket "' + recTitle + '" Updated.';
      const fields = {};
      fields[TICKET_ID.fieldApiName] = recId;
      fields[LOCATION.fieldApiName] = uLocation;
      fields[NCUSREFNO.fieldApiName] = cusRefNo;

      updateTicketData({ tktObj: fields })
        .then(() => {
          this.editCloseModalTicket();           
          this.notificationHandler('Success',showMsg,'success');
          this.afterEditRefresh();
        })
        .catch((error) => {
          this.notificationHandler('Error','Something Wrong Here','error');
          
        })
        .finally(() => {
          this.spinnerStatus = true;
          this.editCloseModalTicket();
          this.resetAllIcons();
          this.resetAllLookupIds();
          this.afterEditRefresh();
        });
    }
  }

  updateJobDetails(){
    this.spinnerStatus = false;
    let curFunction = this.activeModeType;
    let actIndex2 = this.activeIndex;
    let newJobCounts = 0;
    let countJob  =  0;
    let totalResource = 0;


    getSearchListByFilter({
      filter: curFunction,
      searchKey: this.searchKeyword,
      searchByDate: this.searchByDate,
      fRegion: this.searchByYard,
      needQuerying: true
    })
      .then((data) => {
        if (data) {
          if (data.length > 0 && this.isShowResult) {
            this.records = data.map(function (currentItem, index, actArray) {
              if(currentItem.objJobs.RecordType.Name == 'Customer'){
                countJob++;
              } 
              if(currentItem.objJobs.Status__c=='New'){ 
                  newJobCounts++;              
              }
              
              if(currentItem.projectName!= null || currentItem.projectName!=undefined){
                if(currentItem.projectName=='HydroX Leave'){
                  //leaveCount++; 
                  if(currentItem.jobAllocations!=null || currentItem.jobAllocations!=undefined){
                    if(currentItem.jobAllocations.length>0){                      
                      // console.log('allocation Length '+JSON.stringify(currentItem.jobAllocations.length));
                      // console.log('allocation '+JSON.stringify(currentItem.jobAllocations));
                      totalResource = totalResource+currentItem.jobAllocations.length;
                    }
                  }    
                }
              }
              if (
                currentItem.objJobs.Start_Date__c != null ||
                currentItem.objJobs.Start_Date__c != undefined
              ) {
                let duration = currentItem.objJobs.Start_Date__c;
                let milliseconds = Math.floor((duration % 1000) / 100),
                  seconds = Math.floor((duration / 1000) % 60),
                  minutes = Math.floor((duration / (1000 * 60)) % 60),
                  hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                hours = hours < 10 ? "0" + hours : hours;
                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;

                if (actIndex2 == index) {
                  return {
                    ...currentItem,
                    IsOpen: true,
                    Time:
                      hours + ":" + minutes + ":" + seconds + "." + milliseconds
                  };
                } else {
                  return {
                    ...currentItem,
                    IsOpen: false,
                    Time:
                      hours + ":" + minutes + ":" + seconds + "." + milliseconds
                  };
                }

                // return { ...currentItem, 'IsOpen': false, 'Time': hours + ":" + minutes + ":" + seconds + "." + milliseconds };
              } else {
                if (actIndex2 == index) {
                  return { ...currentItem, IsOpen: true };
                } else {
                  return { ...currentItem, IsOpen: false };
                }
              }
            });

            if (curFunction == "All") {
              this.bufferedDataAll = this.records;
              this.totalJobs = countJob;
              this.totalJobsMainAll = countJob; 
              this.newJobCountsMain = newJobCounts;
              this.totalNewJobsMainAll = newJobCounts;
            } else {
              this.bufferedDataMy = this.records;
              this.totalJobs = countJob;            
              this.totalJobsMainMy = countJob;  
              this.totalNewJobsMainMy = newJobCounts;
              this.newJobCountsMain = newJobCounts;
            }
            // console.log(this.records);
            this.resourceCount = this.allResourceCount-totalResource;
            this.showSearchedValues = true;
            this.spinnerStatus = true;
          } else if (data.length == 0) {
            this.records = false;
            // this.getAllJobAllocations = [];
            this.isShowResult = true;
            this.showSearchedValues = false;
            this.spinnerStatus = true;
          }
        } 
        this.notificationHandler('Success','Record Updated.','success');
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.editCloseModalJobDetails();

        this.resetAllIcons();
        this.resetAllLookupIds();
        console.log('called');
      });
    
    
   

  } 

  handleDispatchAll(event) {
    this.spinnerStatus = false;
    this.allJobIdsList = [];
    let parentTable = this.template.querySelector(".ownTable");
    let allCheckBoxes = parentTable.querySelectorAll(".checkbox");
    for (let i = 0; i < allCheckBoxes.length; i++) {
      if (allCheckBoxes[i].checked) {
        this.allJobIdsList.push(allCheckBoxes[i].dataset.recordId);
      }
    }

    if (this.allJobIdsList.length > 0) {
      DispatchJob({ jobIds: this.allJobIdsList })
        .then((data) => {
          this.spinnerStatus = true; 
          this.notificationHandler('Success','The Operator Has Been Notified.','success');
          this.afterEditRefresh();
        })
        .catch((error) => {})
        .finally(() => {
          this.spinnerStatus = true;
          this.resetAllCheckboxes();
          this.resetAllIconDefault();
          this.afterEditRefresh();
        });
    } else {
      this.spinnerStatus = true; 
      this.notificationHandler('Error','Atleast Select One Job For Dispatch.','error');
    }
  }

  handleDispatch(event) {
    this.spinnerStatus = false;
    this.allJobIdsList = [];
    let redId = event.target.dataset.recordId;
    if (redId != "") {
        this.allJobIdsList.push(redId);
    }

    //// console.log('Whole Array ' + this.allJobIdsList);
    if (this.allJobIdsList.length > 0) {
      DispatchJob({ jobIds: this.allJobIdsList })
        .then((data) => {
          this.spinnerStatus = true; 
          this.notificationHandler('Success','The Operator Has Been Notified.','success');
          // this.afterEditRefresh();
        })
        .catch((error) => {
          // // console.log('called error');
          // console.log(error);
        })
        .finally(() => {
          this.spinnerStatus = true;
          this.resetAllIconDefault();
          this.resetAllCheckboxes();
          this.afterEditRefresh();
        });
    }
  }

  afterEditRefresh() {
    this.spinnerStatus = false;
    let curFunction = this.activeModeType;
    let actIndex2 = this.activeIndex;
    let newJobCounts = 0;
    let countJob  =  0;
    let totalResource = 0;

    // getSearchListByFilter({
    //   filter: curFunction,
    //   searchKey: this.searchKeyword,
    //   searchByDate: this.searchByDate,
    //   fRegion: this.searchByYard,
    //   needQuerying: true
    // })
    getAllResourcesByFilters({ resource : null, fDate : this.searchByDate, fRegion : this.searchByYard })
      .then(result=>{ 
        console.log(result+' answer');
          if(result == null){
            this.allResourceCount = 0;
          }else{
            let resCount          = JSON.parse(result);
            this.allResourceCount = resCount.length;  
            resCount.forEach((element) => {
                //console.log('Internally '+element.Title);
                if(element.Title =='Unavailable'){
                  totalResource++;
                }
            }); 
          } 
          
    console.log('Date '+this.searchByDate+' yard '+this.searchByYard);
              return getSearchListByFilter({
                filter: curFunction,
                searchKey: this.searchKeyword,
                searchByDate: this.searchByDate,
                fRegion: this.searchByYard,
                needQuerying: true
              });
      })
      .then((data) => {
        if (data) {
          if (data.length > 0 && this.isShowResult) {
            this.records = data.map(function (currentItem, index, actArray) {
              if(currentItem.objJobs.RecordType.Name == 'Customer'){
                countJob++;
            } 
            if(currentItem.objJobs.Status__c=='New'){ 
                newJobCounts++;              
            }
            
              if (
                currentItem.objJobs.Start_Date__c != null ||
                currentItem.objJobs.Start_Date__c != undefined
              ) {
                let duration = currentItem.objJobs.Start_Date__c;
                let milliseconds = Math.floor((duration % 1000) / 100),
                  seconds = Math.floor((duration / 1000) % 60),
                  minutes = Math.floor((duration / (1000 * 60)) % 60),
                  hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                hours = hours < 10 ? "0" + hours : hours;
                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;

                if (actIndex2 == index) {
                  return {
                    ...currentItem,
                    IsOpen: true,
                    Time:
                      hours + ":" + minutes + ":" + seconds + "." + milliseconds
                  };
                } else {
                  return {
                    ...currentItem,
                    IsOpen: false,
                    Time:
                      hours + ":" + minutes + ":" + seconds + "." + milliseconds
                  };
                }

                // return { ...currentItem, 'IsOpen': false, 'Time': hours + ":" + minutes + ":" + seconds + "." + milliseconds };
              } else {
                if (actIndex2 == index) {
                  return { ...currentItem, IsOpen: true };
                } else {
                  return { ...currentItem, IsOpen: false };
                }
              }
            });

            if (curFunction == "All") {
              this.bufferedDataAll = this.records;
              this.totalJobs = countJob;
              this.totalJobsMainAll = countJob; 
              this.newJobCountsMain = newJobCounts;
              this.totalNewJobsMainAll = newJobCounts;
            } else {
              this.bufferedDataMy = this.records;
              this.totalJobs = countJob;            
              this.totalJobsMainMy = countJob;  
              this.totalNewJobsMainMy = newJobCounts;
              this.newJobCountsMain = newJobCounts;
            } 
            this.resourceCount = this.allResourceCount-totalResource;
            this.showSearchedValues = true;
            this.spinnerStatus = true;
          } else if (data.length == 0) {
            this.records = false;
            // this.getAllJobAllocations = [];
            this.isShowResult = true;
            this.showSearchedValues = false;
            this.spinnerStatus = true;
          }
        }
      })
      .catch(() => {
        this.error = error;
        this.spinnerStatus = true;
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllIcons();
      });
  }

  afterOperationRefresh(event) {
    this.spinnerStatus = false;
    let curFunction = this.activeModeType;
    let actIndex2 = this.activeIndex;
    let newJobCounts = 0;
    let countJob  =  0;
    let totalResource = 0;
    getAllJobAllocationsForDisRefreshData({
      filter: curFunction,
      needQuerying: true
    })
      .then((data) => {
        if (data) {
          // console.log(data);
          this.records = data.map(function (currentItem, index, actArray) {
            if(currentItem.objJobs.RecordType.Name == 'Customer'){
                countJob++;
            } 
            if(currentItem.objJobs.Status__c=='New'){ 
                newJobCounts++;              
            }

            if(currentItem.projectName!= null || currentItem.projectName!=undefined){
              if(currentItem.projectName=='HydroX Leave'){
                //leaveCount++; 
                if(currentItem.jobAllocations!=null || currentItem.jobAllocations!=undefined){
                  if(currentItem.jobAllocations.length>0){                      
                    // console.log('allocation Length '+JSON.stringify(currentItem.jobAllocations.length));
                    // console.log('allocation '+JSON.stringify(currentItem.jobAllocations));
                    totalResource = totalResource+currentItem.jobAllocations.length;
                  }
                }    
              }
            }
            if (
              currentItem.objJobs.Start_Date__c != null ||
              currentItem.objJobs.Start_Date__c != undefined
            ) {
              let duration = currentItem.objJobs.Start_Date__c;
              let milliseconds = Math.floor((duration % 1000) / 100),
                seconds = Math.floor((duration / 1000) % 60),
                minutes = Math.floor((duration / (1000 * 60)) % 60),
                hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

              hours = hours < 10 ? "0" + hours : hours;
              minutes = minutes < 10 ? "0" + minutes : minutes;
              seconds = seconds < 10 ? "0" + seconds : seconds;

              if (actIndex2 == index) {
                return {
                  ...currentItem,
                  IsOpen: true,
                  Time:
                    hours + ":" + minutes + ":" + seconds + "." + milliseconds
                };
              } else {
                return {
                  ...currentItem,
                  IsOpen: false,
                  Time:
                    hours + ":" + minutes + ":" + seconds + "." + milliseconds
                };
              }
            } else {
              if (actIndex2 == index) {
                return { ...currentItem, IsOpen: true };
              } else {
                return { ...currentItem, IsOpen: false };
              }
            }
          });
          if (curFilterType == "All") {
            this.bufferedDataAll = this.records;
            this.totalJobs = countJob;
            this.totalJobsMainAll = countJob; 
            this.newJobCountsMain = newJobCounts;
            this.totalNewJobsMainAll = newJobCounts;
          } else {
            this.bufferedDataMy = this.records;
            this.totalJobs = countJob;            
            this.totalJobsMainMy = countJob;  
            this.totalNewJobsMainMy = newJobCounts;
            this.newJobCountsMain = newJobCounts;
          }
          // console.log(this.records);
          this.resourceCount = this.allResourceCount-totalResource;
          this.showSearchedValues = true;
        } else if (data.length == 0) {
          this.records = [];
          // this.getAllJobAllocations = [];
          this.isShowResult = true;
          this.showSearchedValues = false;
        }
      })
      .catch(() => {
        this.error = error;
        // console.log(error);
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllIcons();
      });
  }

  deleteRecord(event) {
    //this.spinnerStatus = false;
    let recId = event.currentTarget.dataset.id;
    let recType = event.currentTarget.dataset.type;
    let recTitle = event.currentTarget.dataset.title;

    // console.log(recId+' cc '+recType+' ss '+recTitle+' in '+ this.activeIndex);

    let showMsg;
    if (recType == "Ticket") {
      showMsg = 'Job Ticket "' + recTitle + '" was deleted.';
    } else {
      showMsg = 'Job Assignment "' + recTitle + '" was deleted.';
    }
    deleteRecord(recId)
      .then(() => { 
        this.notificationHandler('Success',showMsg,'success');
        this.afterEditRefresh();
      })
      .catch((error) => {
        this.notificationHandler('Error',error.message,'error');
      })
      .finally(() => {
        this.spinnerStatus = true;
        this.resetAllIcons();
        this.afterEditRefresh();
      });
  }


  notificationHandler(titleText,msgText,variantType){
      const toastEvent = new ShowToastEvent({
        title: titleText,
        message: msgText,
        variant: variantType,
    });
    dispatchEvent(toastEvent);
  }

  
}