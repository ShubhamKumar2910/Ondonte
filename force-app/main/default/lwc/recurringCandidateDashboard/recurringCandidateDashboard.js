import { LightningElement,api } from 'lwc';
import getContactRecord from "@salesforce/apex/RecurringCandidateDashboardController.getContactById";

export default class RecurringCandidateDashboard extends LightningElement {
    @api jobId;
    @api candidateSelected;
    contact;
    startDate;
    endDate;

    dateInputChange(event){
        debugger;
        let name = event.target.name;
        let value =  event.target.value;
        console.log("Valueselected",value); 
        if(name=="startDate"){
            this.startDate = new Date(value).toISOString();
        }else{
            this.endDate = new Date(value).toISOString();
        }
    }

    closePopup(event){
        let ev = new CustomEvent('closepopup');
        this.dispatchEvent(ev);                    
    }

    handleAccountSelection(event){
        debugger;
        this.candidateSelected = event.target.value;
        this.getContact();
    }

    getContact(){
        if(this.candidateSelected!=null){
            getContactRecord({id:this.candidateSelected}).then(result=>{
                debugger;
                console.log("RecordDetails",result);
                this.contact = result;
                this.contact.Profile_Picture_URL__c = this.contact.Profile_Picture_URL__c?this.contact.Profile_Picture_URL__c:"https://spng.pngfind.com/pngs/s/500-5008297_lars-christian-larsen-user-profile-image-png-transparent.png"
            }).catch(error=>{
                console.log("Error to get record",error);
            });
        }
    }

    searchShifts(){
        alert(this.jobId);
    }



}