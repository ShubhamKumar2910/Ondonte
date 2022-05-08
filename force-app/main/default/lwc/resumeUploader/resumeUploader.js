import { LightningElement,api,track } from 'lwc';
import uploadFiles from '@salesforce/apex/ResumeUploadController.uploadFiles';
import resumeParser from '@salesforce/apex/ResumeParseClass.resumeParser';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class ResumeUploader extends LightningElement {

    //@api recordId;
    @api isModalOpenFirstChild;
    @api recId;
    filesUploaded = [];
    handleFileUploaded(event) {
        debugger;
        //const uploadedFiles = event.target.files;
        if (event.target.files.length > 0) {
            let files = [];
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
                };
                reader.readAsDataURL(file);
            }
        }
    }

    attachFiles(event){
        debugger;
        uploadFiles({files: this.filesUploaded})
            .then(result => {
                if(result.res == true) {
                    //isModalOpen = false;
                  resumeParser({conId : this.recId , attId : result.FileId});
                    this.showToastMessage('Success','Files uploaded', 'success');
                    const event = new CustomEvent('child', {
                        // detail contains only primitives
                        detail: {key1 : result.res ,key2 :result.FileId}
                        });
                        this.dispatchEvent(event);
                    }
                else{
                    this.showToastMessage('Error','Error uploading files', 'error');
                }
            })
            .catch(error => {
                this.showToastMessage('Error','Error uploading files', 'error');
            });
    }


    showToastMessage(title,message,variant){
        debugger;
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}