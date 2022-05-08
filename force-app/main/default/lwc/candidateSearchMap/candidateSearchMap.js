import { LightningElement, api, track } from 'lwc';
import getNearByCandidates from '@salesforce/apex/RecruiterDashboardContentController.getNearByCandidates';
import moment from '@salesforce/resourceUrl/moment'

export default class CandidateSearchMap extends LightningElement {
    
    @api lat; 
    @api lang;
    @api recordId;
    @api jobName;
    @api textValue = 1;
    @api contactList;
    @api preDisplayed;

    @track loaded = false;

    selectedContacts = [];
    
    isDistanceSelected = true;
    isDurationSelected = false;
    selectedMarkerValue;
    prevSelectedMarkerValue;


    connectedCallback(){
        this.getAllCandidates();
    }


    getAllCandidates(){
        debugger;
        getNearByCandidates({'jobName':this.jobName,'lat':parseFloat(this.lat),'lang':parseFloat(this.lang), 'distance':this.textValue,'sortByType':this.isDistanceSelected?'distance':'duration','preSelectedCandidates':this.preDisplayed}).then(result=>{
            console.log("HDSSDHSjd: ",result);
            if(result.conList && result.conList.length > 0){
                this.mapMarkers = result.markerList;/*JSON.parse(result);*/
                this.contactList = result.conList;
                this.markersTitle = "Available Candidates";
                this.orders = result;
                this.loaded = true;
            }else{
                this.loaded = true;
                alert("Candidates Not found")
            }
            console.log("MapFilters-----",result.conList);
            console.log("SOMEXYZ",this.contactList);
        }).catch(error=>{
            console.log("Error",error);
        })
    }

    handleInputChange(event) {
        debugger; 
        this.textValue = event.detail.value;
    }

     handleSorting(event){
        debugger;
        let name = event.target.name;
        if(name==="distance"){
            this.isDistanceSelected = true;
            this.isDurationSelected = false;
        }else{
            this.isDurationSelected = true;
            this.isDistanceSelected = false;
        }
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