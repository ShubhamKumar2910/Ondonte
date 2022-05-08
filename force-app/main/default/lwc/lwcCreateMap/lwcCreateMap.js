import { LightningElement, wire ,api,track} from 'lwc';

import getaccountCoordinates from '@salesforce/apex/MapClassHelper.getaccountCoordinates';
import getAllcandidate from '@salesforce/apex/MapClassHelper.getAllcandidate'; 
export default class LwcCreateMap extends LightningElement {    
    @api recordId = '0016D00000acbZPQAY';
    @api long;
    @api latt;
    @api contactList
    @api selectedContacts = []
    @track loaded = false;
    @api textValue = 1;
    showButton = false;
    isDistanceSelected = true;
    isDurationSelected = false;
    selectedMarkerValue;
    prevSelectedMarkerValue;
    
    //MAP PIN = 'M0-48c-9.8 0-17.7 7.8-17.7 17.4 0 15.5 17.7 30.6 17.7 30.6s17.7-15.4 17.7-30.6c0-9.6-7.9-17.4-17.7-17.4z';
    //SQUARE PIN = 'M22-48h-44v43h16l6 5 6-5h16z';
    //SHIELD = 'M18.8-31.8c.3-3.4 1.3-6.6 3.2-9.5l-7-6.7c-2.2 1.8-4.8 2.8-7.6 3-2.6.2-5.1-.2-7.5-1.4-2.4 1.1-4.9 1.6-7.5 1.4-2.7-.2-5.1-1.1-7.3-2.7l-7.1 6.7c1.7 2.9 2.7 6 2.9 9.2.1 1.5-.3 3.5-1.3 6.1-.5 1.5-.9 2.7-1.2 3.8-.2 1-.4 1.9-.5 2.5 0 2.8.8 5.3 2.5 7.5 1.3 1.6 3.5 3.4 6.5 5.4 3.3 1.6 5.8 2.6 7.6 3.1.5.2 1 .4 1.5.7l1.5.6c1.2.7 2 1.4 2.4 2.1.5-.8 1.3-1.5 2.4-2.1.7-.3 1.3-.5 1.9-.8.5-.2.9-.4 1.1-.5.4-.1.9-.3 1.5-.6.6-.2 1.3-.5 2.2-.8 1.7-.6 3-1.1 3.8-1.6 2.9-2 5.1-3.8 6.4-5.3 1.7-2.2 2.6-4.8 2.5-7.6-.1-1.3-.7-3.3-1.7-6.1-.9-2.8-1.3-4.9-1.2-6.4z';
    //ROUTE = 'M24-28.3c-.2-13.3-7.9-18.5-8.3-18.7l-1.2-.8-1.2.8c-2 1.4-4.1 2-6.1 2-3.4 0-5.8-1.9-5.9-1.9l-1.3-1.1-1.3 1.1c-.1.1-2.5 1.9-5.9 1.9-2.1 0-4.1-.7-6.1-2l-1.2-.8-1.2.8c-.8.6-8 5.9-8.2 18.7-.2 1.1 2.9 22.2 23.9 28.3 22.9-6.7 24.1-26.9 24-28.3z';
    //SQUARE = 'M-24-48h48v48h-48z';
    //SQUARE_ROUNDED = 'M24-8c0 4.4-3.6 8-8 8h-32c-4.4 0-8-3.6-8-8v-32c0-4.4 3.6-8 8-8h32c4.4 0 8 3.6 8 8v32z';
    //STAR = ''M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z';
   
    handleInputChange(event) {
        debugger; 
        this.textValue = event.detail.value;
    }

    handleCheckBox(event){
        
        let id = event.target.name;
        if(!this.selectedContacts.includes(id)){
            this.selectedContacts.push(id)
            this.showButton = true;
        }else{
             this.selectedContacts = this.selectedContacts.filter(Id=> Id!=id)  
             this.showButton = this.selectedContacts.length>0 
        }
    }

    handleAddCandidate(event){
        alert("Wait i'll call you");
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
        
        // if(e.target.id==="distance"){
        //     this.isDistanceSelected = true;
        //     this.isDurationSelected = false;
        // }else{
        //     this.isDistanceSelected = false;
        //     this.isDurationSelected = true;
        // }

        
        // if(event.target.id==="distance"){
        //     this.isDistanceSelected = !this.isDistanceSelected;
        //     this.isDurationSelected  = false;
        // }else{
        //     this.isDistanceSelected = false;
        //     this.isDurationSelected  = !this.isDurationSelected;
        // }
    }

    
    //getting the current location of the account
    connectedCallback() {
        getaccountCoordinates({accid:this.recordId}).then(result=>{
            console.log("HDSSDHSjd: ",result);
            debugger;
            this.mapMarkers = result.markerList;/*JSON.parse(result);*/
            this.contactList = result.conList;
            this.markersTitle = "Company Details";
            this.loaded = true;
            console.log('centre'+this.mapMarkers);
        }).catch(error=>{
            console.log("Error",error);
            this.error = error;
            this.items = undefined;
        })
    }

    //Getting the Candidates within a range.
    applyFilter(event) {
        debugger;
        this.loaded = false;
        this.prevSelectedMarkerValue = null;
       
        window.console.log(event);
        console.log("skjds",this.isDistanceSelected)
        let sortByType = this.isDistanceSelected?"distance":"duration";

        getAllcandidate({'Distance': this.textValue,'accId' : this.recordId,'sortByType':sortByType})
            .then(result => {
                window.console.log(result);
                console.log("WDWJDDNMSDs",result);
                this.mapMarkers = result.markerList;/*JSON.parse(result);*/
                this.contactList = result.conList;
                this.markersTitle = "Available Candidates";
                this.orders = result;
                this.loaded = true;

                console.log("SOMEXYZ",this.contactList);
            })
            .catch(error => {
                this.error = error;
                this.loaded = true;
            });
    }

    handleMarkerSelect(event) {
        debugger;
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        debugger;
    
        try{
            var divblock =  this.template.querySelector('[data-id="'+this.selectedMarkerValue+'"]');
            this.prevSelectedMarkerValue!=null?this.template.querySelector('[data-id="'+this.prevSelectedMarkerValue+'"]').style.backgroundColor = "":null;
            
            if(divblock){

                divblock.style.transition = "all 0.5s";
                divblock.style.backgroundColor = "#EBF6FF"
               
                // setTimeout(function() {
                //     this.template.querySelector('[data-id="'+this.selectedMarkerValue+'"]').style.backgroundColor = ""
                //     this.template.querySelector('[data-id="'+this.selectedMarkerValue+'"]').style.transition = "all 1s";
                // }, 400);

                this.prevSelectedMarkerValue = event.target.selectedMarkerValue;
            }   
        }catch(error){
            console.log("Error",error)
        }
    }

    
    
}