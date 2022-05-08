import { LightningElement, api, track } from 'lwc';
import getNearByCandidateForTempShift from '@salesforce/apex/RecruiterDashboardTemporaryJobController.getNearByCandidateForTempShift';

export default class CandidateSearchMapTemporary extends LightningElement {

    @api shiftName; //
    @api lat;  //
    @api lang; //
    @api textValue = 1;
    @api startDate; //
    @api endDate; //
    @track loaded = false;
    @api errorMsg='';

    mapMarkers;
    nearbyCandidates;
    contactList = [];
    selectedContacts = [];
    selectedMarkerValue;
    isDistanceSelected = true;
    isDurationSelected = false;
    prevSelectedMarkerValue;

    markersTitle;

    connectedCallback(){
        this.getAllCandidates();
    }

    getAllCandidates(){
        debugger;
        getNearByCandidateForTempShift({startDateString:this.startDate,endDateString:this.endDate,shiftName:this.shiftName,'sortByType':this.isDistanceSelected?'distance':'duration',lat:this.lat,lang:this.lang,'distance':this.textValue}).then(result=>{
            console.log('Result',result);
            if(result.markerList){
                this.nearbyCandidates = result;
                this.mapMarkers = result.markerList;/*JSON.parse(result);*/
                this.contactList = result.shiftList;
                this.markersTitle = "Available Candidates";
            }else{
                alert('Candidates not found');
            }
            this.loaded = true;
        }).catch(err=>{
            console.log('Error to fetch nearby candidates',err);
        })
    }

    handleInputChange(event) {
        debugger; 
        this.textValue = event.detail.value;
    }

    handleCheckBox(event) {
    
        let id = event.target.name;
        let conSelected = this.contactList.find(con=>con.id===id);

        if(!this.selectedContacts.includes(conSelected)){
            this.selectedContacts.push(conSelected)
        }else{
            this.selectedContacts = this.selectedContacts.filter(con=> con.id!=id)  
        }

        this.dispatchEvent(new CustomEvent('mapselhandler', { detail: this.selectedContacts }));
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        try{
            var divblock =  this.template.querySelector('[data-id="'+this.selectedMarkerValue+'"]');
            this.prevSelectedMarkerValue!=null?this.template.querySelector('[data-id="'+this.prevSelectedMarkerValue+'"]').style.backgroundColor = "":null;
            if(divblock){
                divblock.style.transition = "all 0.5s";
                divblock.style.backgroundColor = "#EBF6FF"
                this.prevSelectedMarkerValue = event.target.selectedMarkerValue;
            }   
        }catch(error){
            console.log("Error",error)
        }
    }

    applyFilter(event) {
        debugger;
        this.loaded = false;
        this.prevSelectedMarkerValue = null;
        this.selectedContacts = []
        this.getAllCandidates();
        this.dispatchEvent(new CustomEvent('mapselhandler', { detail: this.selectedContacts }));
    }
}