import { LightningElement,wire,api,track } from 'lwc';
import resumeParser from '@salesforce/apex/ResumeParseClass.resumeParser';
import saveResumeResponse from '@salesforce/apex/CandidateDetailsController.saveResumeResponse';

export default class CreateEditableFormNew extends LightningElement {
    @api isModalOpenSecondChild;
    
    @track objects = [];
    @track error;

    @track personalDetails = {name:"Barak",age:67,gender:'Male'};
    @track skillsList = [{key:'Educational',value:[{'key':'ABC School, Jaya Nagar, Palika vihar'},{'key': 'PTLR College, Jaya Nagar, Palika vihar'}]},
                        {key:'Experience',value:[{'key':'ABC School, Jaya Nagar, Palika vihar'},{'key': 'PTLR College, Jaya Nagar, Palika vihar'}]}];

    @track data = [
        {name: 'General Details', DetailList : [{'Id': 1}, {'Type': 'CS'}, {'FirstName' : 'Ajeet'}, {'LastName' : 'Kumar' }]},
        {name: 'Educational details', DetailList :[{'Id': 2}, {'Type': 'EC'}, {'Candidate': 'candidate1'}, {'CourseName': 'Networking'}, {'EndYear' : '2024'},  {'StartYear': '2020' }] },
        {name: 'Employment History', DetailList : [{'Id': 3}, {'Type': 'MEC'}, {'EmployerName': 'UtilitarianLab'}, {'Duration' : '2 year'}, {'jobtitle' : 'Developer'}, {'Enddate' : '27/07/2030'}, {'StartDate' : '1/01/2020'  }] },
        
    ];
    
    connectedCallback(){
        resumeParser()
            .then(result => {
                //this.objects = result;
                alert(' Result ==> ' + this.objects);
                for(let key in result) {
                    // Preventing unexcepted data
                    if (result.hasOwnProperty(key)) { // Filtering the data in the loop
                        this.objects.push({value:result[key], key:key});
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    
    }

    handleaccordion(event){
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    
    }

    closeModalPop() {
        //this.isModalOpenNew = false;
        

        const event = new CustomEvent('secondchild', {
            // detail contains only primitives
            detail: true });
            this.dispatchEvent(event);
    }

}