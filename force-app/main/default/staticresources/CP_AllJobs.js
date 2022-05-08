var allJobReq;


angular.module('cp_app').controller('cp_alljobs_ctrl', function ($scope,$rootScope, $log, $timeout) {
    debugger;
 
    $scope.allJobReq;
    $scope.jobCount;
    $scope.temJobs = false;
    $scope.perJobs = false;
    $scope.allJobs = false;
    $scope.placementType = "";
    $scope.filterJobCity= "";
    $scope.filterJobsDate= "";
    $scope.filterJobeDate= "";
    $scope.filterJobName= "";
    $rootScope.activeTab = 1;
    $scope.workingDaysPickValues = workingDaysValues;
    var candidateId = $rootScope.candidateId;
    $scope.JobRequisition;
    $scope.showPermanent = true;
    $scope.showAllJobsDetails  = false;

    if($rootScope.JobId != undefined){
        debugger;
        CandidateDashboard_Controller.getRequisition($rootScope.JobId, function (result, event) {
            debugger;
            if (event.status && result != null) {     
                $scope.showJobDetails(result);
            }
            else {

            }
        }, { escape: false }) 
    }
    $scope.getAllJobs = function(){
        debugger;
        $rootScope.showSpinner = true;
        CandidateDashboard_Controller.getAllJobs($rootScope.candidateId,function(result,event){
            if(event.status && result != null){
                debugger;
                $scope.allJobReq = [];
                $scope.allJobReq = result;
                $scope.jobCount = $scope.allJobReq.length;
                $scope.showPermanent = true;
                $scope.perJobs = true;
                $scope.temJobs = false;
                $scope.$apply();
                
            }
            else{
              
            }
            $rootScope.showSpinner = false;
            $scope.$apply();
        },{escape:false})
    }
   
    $scope.showJobDetails = function(job){
        debugger;
        $scope.showAllJobsDetails = true;
        $scope.selectedJobReq = job;
    }

    $scope.hideJobDetails = function(){
        $scope.showAllJobsDetails = false;
    }
   
    
    $scope.submitApplication = function(index,jobId){
        debugger;
        $scope.showSpinner = true;

        CandidateDashboard_Controller.applyForJob(jobId,$rootScope.candidateId,function(result,event){
            if(event.status && result != null){
                $scope.allJobReq.splice(index,1);
                $scope.jobCount = $scope.allJobReq.length;
                $scope.showSpinner = false;

                Swal.fire(
                    '',
                    'Applied Successfully!',
                    'success'
                  )
                  $scope.getAMyJobs();
                
            }
            else{
                $scope.$apply();
            }
        },{escape:false})
    }

    $scope.jobTypeFilter = function (jobType) {
        debugger;
        if(jobType == "temp"){
            $scope.temJobs = true;
            $scope.perJobs = false;
            $scope.placementType = "Temporary";
        }else if(jobType == "permnt"){
            $scope.perJobs = true;
            $scope.temJobs = false;
            $scope.placementType = "Permanent";
        }
    }

    $scope.getFilterdJobs = function(){
       
    debugger;
    $scope.showSpinner = true;

        CandidateDashboard_Controller.getFilteredJobs($rootScope.candidateId,$scope.filterJobCity,$scope.placementType,$scope.filterJobName,$scope.filterJobsDate,$scope.filterJobeDate,function(result,event){
            if(event.status && result != null){
                $scope.allJobReq = result;
                $scope.jobCount = $scope.allJobReq.length;
                
               
            }
            else{
              
            }
            $scope.showSpinner = false;
            $scope.$apply();
        },{escape:false})
    }

    $scope.clearDates = function(){
        $scope.filterJobsDate ="";
        $scope.filterJobeDate ="";
    }

    // ---------------------my jobs js-----------------------

    $scope.myJobs = [];
    $scope.jobDetailPage = false;
    $scope.jobDetails;
    $scope.userDoc;
    $scope.fileId;
    $scope.candidateStage = [{
        "num": "1",
        "Name": "Applied"
    }, {
        "num": "2",
        "Name": "Interview Scheduled"
    }, {
        "num": "3",
        "Name": "Selected"
    }, {
        "num": "4",
        "Name": "Placed"
    }];



    var input = document.getElementById( 'attachmentFile' );
var infoArea = document.getElementById( 'file-upload-filename' );
debugger;
//document.querySelector('input.dropzone').addEventListener( 'change', showFileName );

function showFileName( event ) {
  
  // the change event gives us the input it occurred in 
  var input = event.srcElement;
  
  // the input has an array of files in the `files` property, each one has a name that you can use. We're just using the name here.
  var fileName = input.files[0].name;
  
  // use fileName however fits your app best, i.e. add it into a div
  infoArea.textContent = 'File name: ' + fileName;
}

    $scope.getAMyJobs = function () {
        $scope.applicationConfirmationList = [];
        CandidateDashboard_Controller.getMyJobs($rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                debugger;
                $scope.myJobs =[];
                for(var i=0;i< result.length;i++){
                    if(result[i].Application_Stage__c == 'Applied'){
                        $scope.applicationConfirmationList.push(result[i]);
                    }else{
                        $scope.myJobs.push(result[i]);
                    }
                }

             /*   if($scope.applicationConfirmationList.length > 0){
                    $("#applicationConfirmationPopup").modal('show');

                }  */
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
    }
 $scope.getAMyJobs();

    $scope.getUserDoc = function () {
        debugger;
        CandidateDashboard_Controller.getAllUserDoc($scope.jobDetails.Id, function (result, event) {

            if (event.status && result != null) {
                $scope.userDoc = result;
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
    }
 
    $scope.viewJobDetails = function (job) {

        $scope.jobDetailPage = true;
        $scope.jobDetails = job;
        if ($scope.jobDetails.Application_Stage__c != undefined) {
            var index;
            $scope.candidateStage.some(function (obj, i) {
                return obj.Name === $scope.jobDetails.Application_Stage__c.replace(/ /g, "") ? index = i : false;
            });

            console.warn(index);
            $scope.candidateStage.splice(index + 1);
            for (var i = 0; i < $scope.candidateStage.length; i++) {
                var stageName = $scope.candidateStage[i].Name.replace(/ /g, "");
                document.getElementById(stageName).classList.add('active');
            }
        }
        $scope.getUserDoc();

    }

    $scope.backFromJobDetails = function () {
        $scope.jobDetailPage = false;
    }

    $scope.uploadFileToUserDoc = function (type) {
        debugger;
        // $scope.selecteduDoc;

        $scope.selecteduDoc;
        if ($scope.fileId != undefined) {
            $scope.uploadFile(type, $scope.selecteduDoc, $scope.fileId);
        } else {
            $scope.uploadFile(type, $scope.selecteduDoc, "");
        }
       

    }

    $scope.replaceUserDocFile = function (fileId) {
        $scope.uploadFile(type, $scope.selecteduDoc, fileId);
    }

    $scope.uploadFile = function (type, userDocId, fileId) {
        debugger;
        $scope.showSpinner = true;
        var file = document.getElementById('attachmentFile').files[0];
        console.log(file);
        if (file != undefined) {
            if (file.size <= maxFileSize) {
                debugger;
                attachmentName = file.name;
                const myArr = attachmentName.split(".");
                if (myArr[1] != "pdf") {
                    alert("Please upload in PDF format only");
                    return;
                }
                var fileReader = new FileReader();
                fileReader.onloadend = function (e) {
                    attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                    positionIndex = 0;
                    fileSize = attachment.length;
                    console.log("Total Attachment Length: " + fileSize);
                    doneUploading = false;
                    $scope.showSpinner = false;
                    if (fileSize < maxStringSize) {
                        $scope.uploadAttachment(type, fileId, userDocId);
                    } else {
                        $scope.showSpinner = false;
                        alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                    }

                }
                fileReader.onerror = function (e) {
                    $scope.showSpinner = false;
                    alert("There was an error reading the file.  Please try again.");
                }
                fileReader.onabort = function (e) {
                    $scope.showSpinner = false;
                    alert("There was an error reading the file.  Please try again.");
                }

                fileReader.readAsBinaryString(file);  //Read the body of the file

            } else {
                $scope.showSpinner = false;
                alert("File must be under 4.3 MB in size.  Your file is too large.  Please try again.");
            }
        } else {
            $scope.showSpinner = false;
            alert("You must choose a file before trying to upload it");
        }
    }

    $scope.uploadAttachment = function (type, fileId, userDocId) {
        var attachmentBody = "";
        if (fileId == undefined) {
            fileId = " ";
        }
        if (fileSize <= positionIndex + chunkSize) {
            attachmentBody = attachment.substring(positionIndex);
            doneUploading = true;
        } else {
            attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
        }
        console.log("Uploading " + attachmentBody.length + " chars of " + fileSize);
        CandidateDashboard_Controller.doUploadAttachment(
            type,attachmentBody, attachmentName,$rootScope.candidateId, fileId, userDocId,
            function (result, event) {
                console.log(result);
                if (event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
                } else if (event.status) {
                    if (doneUploading == true) {
                        $scope.showUploadButton = false;
                        Swal.fire(
                            '',
                            'Uploaded Successfully!',
                            'success'
                        )
                        $("#fileUploadModel").modal('hide');
                        $scope.getUserDoc();

                    } else {
                        positionIndex += chunkSize;
                        $scope.uploadAttachment(type,result, '');
                    }
                } else {
                    console.log(event.message);
                }
            },


            { buffer: true, escape: true, timeout: 120000 }
        );
    }

    $scope.selUserDocId = function (doc, fileId) {
        debugger;
        $scope.fileId = fileId;
        $scope.selecteduDoc = doc;
    }

    $scope.viewDocument = function (docId) {
        debugger;
        window.open('https://ondonte--dev--c.documentforce.com/sfc/servlet.shepherd/version/download/' + docId + '?asPdf=false&operationContext=CHATTER', '_blank', 'location=yes,height=570,width=520,scrollbars=yes,status=yes');
    }

    $scope.showFileName = function(){
        debugger;
    }

    $scope.withdrawApplication = function(appId){
        debugger;
        Swal.fire({
            title: 'Do you want to withdraw your Application?',
            showDenyButton: true,
            showCancelButton: true,
            confirmButtonText: 'withdraw',
            denyButtonText: `Don't`,
          }).then((result) => {
            /* Read more about isConfirmed, isDenied below */
            if (result.value ==true) {
                $scope.showSpinner = true;
                CandidateDashboard_Controller.withdrawApplication(appId, function (result, event) {
                    if (event.status && result != null) {
                        Swal.fire('Application withdrawn!', '', 'success')
                        $scope.jobDetailPage = false;
                        $scope.jobDetails = "";
                        $scope.getAMyJobs();
                        $scope.showSpinner = false;
                    }
                    else {
                        $scope.showSpinner = false;
                    }
                    $scope.$apply();
                }, { escape: false })
              
            } else if (result.dismiss =="cancel") {
              Swal.fire('Changes are not saved', '', 'info')
            }
          })
    }
});