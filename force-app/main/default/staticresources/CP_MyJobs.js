var index;
debugger;

angular.module('cp_app').controller('cp_myjobs_ctrl', function ($scope, $rootScope) {
    console.log($rootScope);
    $scope.myJobs;
    $scope.jobDetailPage = false;
    $scope.jobDetails;
    $scope.userDoc;
    $scope.showDocTable = false;
    $scope.fileId;
    $rootScope.activeTab = 1;
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
document.querySelector('input.dropzone').addEventListener( 'change', showFileName );

function showFileName( event ) {
  
  // the change event gives us the input it occurred in 
  var input = event.srcElement;
  
  // the input has an array of files in the `files` property, each one has a name that you can use. We're just using the name here.
  var fileName = input.files[0].name;
  
  // use fileName however fits your app best, i.e. add it into a div
  infoArea.textContent = 'File name: ' + fileName;
}




    $scope.getAMyJobs = function () {

        $rootScope.activeTab = 1;
        CandidateDashboard_Controller.getMyJobs($rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                $scope.myJobs = result;
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
    }

    $scope.getUserDoc = function () {
        debugger;
        CandidateDashboard_Controller.getAllUserDoc($scope.jobDetails.Id, function (result, event) {

            if (event.status && result != null) {

                $scope.showDocTable = true;
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

    }

    $scope.backFromJobDetails = function () {
        $scope.jobDetailPage = false;
    }

    $scope.uploadFileToUserDoc = function (type) {
        debugger;
        // $scope.selecteduDoc;
        ;
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
                    if (fileSize < maxStringSize) {
                        $scope.uploadAttachment(type, fileId, userDocId);
                    } else {
                        alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                    }

                }
                fileReader.onerror = function (e) {
                    alert("There was an error reading the file.  Please try again.");
                }
                fileReader.onabort = function (e) {
                    alert("There was an error reading the file.  Please try again.");
                }

                fileReader.readAsBinaryString(file);  //Read the body of the file

            } else {
                alert("File must be under 4.3 MB in size.  Your file is too large.  Please try again.");
            }
        } else {
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
        $('#fileUploadModel').modal('show');

    }

    $scope.viewDocument = function (docId) {
        debugger;
        window.open('https://sales-production--ondontesb--c.documentforce.com/sfc/servlet.shepherd/version/download/' + docId + '?asPdf=false&operationContext=CHATTER', '_blank', 'location=yes,height=570,width=520,scrollbars=yes,status=yes');
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

                CandidateDashboard_Controller.withdrawApplication(appId, function (result, event) {
                    if (event.status && result != null) {
                        Swal.fire('Application withdrawn!', '', 'success')
                        $scope.jobDetailPage = false;
                        $scope.jobDetails = "";
                        $scope.getAMyJobs();
                       
                    }
                    else {
        
                    }
                }, { escape: false })
              
            } else if (result.dismiss =="cancel") {
              Swal.fire('Changes are not saved', '', 'info')
            }
          })
    }
});