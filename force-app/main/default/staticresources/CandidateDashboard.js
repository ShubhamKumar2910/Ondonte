
var tabValues = [];
var workingDaysValues = [];
var userId;
var siteURL;
var candidateId;
var getAllEvents;
var eventsOnLoad;
var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
var maxFileSize = 4350000;      //After Base64 Encoding, this is the max file size
var chunkSize = 950000;         //Maximum Javascript Remoting message size is 1,000,000 characters
var attachment;
var attachmentName;
var fileSize;
var positionIndex;
var doneUploading;
var blobData;

var app = angular.module('cp_app');
var sitePrefix = '/apex'
app.config(function ($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(false).hashPrefix('');
    var rp = $routeProvider;


    
    for (var i = 0; i < tabValues.length; i++) {

        var pageName = '/' + tabValues[i].Name;

        if (tabValues[i].Apex_class_Name__c != undefined) {
            rp.when(pageName, {

                templateUrl: sitePrefix + pageName,
                controller: tabValues[i].Apex_class_Name__c
            });
        } else {
            rp.when(pageName, {
                templateUrl: sitePrefix + pageName,
            })
        }

    }
});




app.controller('cp_dashboard_ctrl', function ($scope, $rootScope, $timeout, $window, $location, $element) {
    

    $rootScope.userDetails;
    $rootScope.activeTab = 0;
    $rootScope.siteURL = siteURL;
    $rootScope.userHashId = userId;
    $rootScope.candidateId = candidateId;
    debugger;
  //  $rootScope.getAllEvents = getAllEvents;
    $rootScope.userDetails;
    $rootScope.profilePicId;
    $rootScope.resumeUserDoc;
    $rootScope.profilePicUD;
    $rootScope.updateResume = true;
    $rootScope.userDocument = [];
    $rootScope.showSpinner = false;
    $rootScope.JobId;
    debugger;
    $rootScope.blobData = blobData;
    $scope.editProfile = true;
    $scope.profilePic = true;
    $scope.prevExprience;
    $scope.showAddExperience = false;
    $scope.expStartDate;
    $scope.expEndDate;
    $scope.workExp = { Name: "", Employer_Name__c: "", Duration__c: "", Applicant__c: candidateId };
    $scope.showUplaodUserDoc = false;
    
    debugger;
    $scope.workingDaysPickValues = workingDaysValues;
    $scope.selectedValue = [];
    $scope.strtTime;
    $scope.endTime;
    $scope.showResumeParser = false;
    $scope.countyList = [];
    $scope.allTempJobs;
    $scope.applicationConfirmationList = [];
    $scope.allDayAvailable = true;

    $scope.getCandidateDetails = function () {
        
        if(userId ==''){
            window.location.replace("https://ondonte--dev.my.salesforce.com/apex/CP_LoginPage");
        }

        if(JobId !=''){
            $rootScope.JobId = JobId;
        /*    $scope.applicationToDisplay;
            CandidateDashboard_Controller.getapplicationDetails(appId, function (result, event) {
                debugger;
                if (event.status && result != null) {     
                    $scope.applicationToDisplay = result;

                }
                else {
    
                }
            }, { escape: false })  */
        }


        CandidateDashboard_Controller.getUserDetails(userId, function (result, event) {
            debugger;
            if (event.status && result != null) {
                debugger;
                $rootScope.userDetails = result.userDetails;
                $rootScope.profilePicId = $rootScope.userDetails.Profile_Pic_Attachment_Id__c;
                if($rootScope.userDetails.Preferred_Working_Days__c != undefined){
                    $scope.weekSchedule = $rootScope.userDetails.Preferred_Working_Days__c;
                }else{
                var exampleModalPopup = new bootstrap.Modal(document.getElementById("staticBackdrop"), {});
                exampleModalPopup.show();
                
                }
                var profilePicIndex;
                var resumeIndex;
                if (result.userDocWrapper != undefined) {
                    debugger;
                    for (var i = 0; i < result.userDocWrapper.length; i++) {
                        if (result.userDocWrapper[i].userDocument.Name == "Profile Picture") {
                            $rootScope.profilePicUD = result.userDocWrapper[i];
                        } else if (result.userDocWrapper[i].userDocument.Name == "Resume") {
                            $rootScope.resumeUserDoc = result.userDocWrapper[i];
                            if($rootScope.resumeUserDoc.contentVersion != null){
                                $rootScope.updateResume = false;
                            }
                        } else {
                            if(result.userDocWrapper[i].userDocument.Status__c == "Pending"){
                                window.location.replace("https://ondonte--dev.my.salesforce.com/apex" + "/CP_DocumentUpload?hc="+userId);
                            }
                            $rootScope.userDocument.push(result.userDocWrapper[i]);
                        }
                    }
                }
                if(result.jobsToAcceptByCandidate != undefined){
                    debugger;
                    if(result.jobsToAcceptByCandidate.length >0 ){
                        $("#applicationConfirmationPopup").modal('show');
                        //$scope.applicationConfirmationList= result.jobsToAcceptByCandidate;
                    }
                }
                debugger;
                if(result.userDetails.Background_Check__c == "No" && result.Background_Check_Submission_Date__c == true){
                    $("#backgroundCheckModal").modal('show');
                }  
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
    }

    $scope.showBgConcent = false;
    $scope.getAMyJobs = function () {
        $scope.applicationConfirmationList = [];
        $scope.BackGroundCheckApplications = [];
        CandidateDashboard_Controller.getMyJobs($rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                debugger;
                for(var i=0;i< result.length;i++){
                    if(result[i].Bg_Consent_Approved__c == false && result[i].Bg_Verification_Initiated__c == true){
                        $scope.showBgConcent = true;
                        $scope.BackGroundCheckApplications.push(result[i].Name);
                    }
                    if(result[i].Application_Stage__c == "Applied"){
                        $scope.applicationConfirmationList.push(result[i]);

                    }
                }

               
                if($scope.showBgConcent == true){
                    $("#backgroundCheckModal").modal('show');  
                } 
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
    }
    $scope.getAMyJobs();
    $scope.backgroundcheckConcent = function(){
        CandidateDashboard_Controller.backgroundcheckConcent(candidateId, function (result, event) {
    
            if (event.status) {
                Swal.fire(
                    '',
                    'Backgroud Check Will Be Initiated!',
                    'success'
                )
                $("#backgroundCheckModal").modal('hide');
            }
            else {
    
                Swal.fire(
                    '',
                    'Backgroud Check Will Be Initiated!',
                    'success'
                )
                $("#backgroundCheckModal").modal('hide');
            }
        }, { escape: false })
    }


    $scope.redirectToSchdlPlnr = function () {
        
        window.location.replace(siteURL + 'CP_SchedulePlanner?id=' + candidateId + '&hc=' + userId);
    }

    $scope.acceptJob = function(jobId){
        CandidateDashboard_Controller.acceptJob(jobId, function (result, event) {
    debugger;
            if (event.status) {
                Swal.fire(
                    '',
                    'Applied successfully!',
                    'success'
                )
                if($scope.applicationConfirmationList.length > 0){
                    for(var i=0;i< $scope.applicationConfirmationList.length;i++){
                        if($scope.applicationConfirmationList[i].Id == jobId){
                            $scope.applicationConfirmationList.splice(i,1);
                        }
                    }
                    if($scope.applicationConfirmationList == 0){
                        $("#applicationConfirmationPopup").modal('hide');
                    }
                }
                $scope.$apply();
            }
            else {
    
            }
        }, { escape: false })
    }

    $scope.acceptShift = function(jobId){
        CandidateDashboard_Controller.acceptShift(jobId,candidateId, function (result, event) {
    debugger;
            if (event.status) {
                Swal.fire(
                    '',
                    'Applied successfully!',
                    'success'
                )
                if($scope.shiftToConfirm.length > 0){
                    for(var i=0;i< $scope.shiftToConfirm.length;i++){
                        if($scope.shiftToConfirm[i].shift.Id == jobId){
                            $scope.shiftToConfirm.splice(i,1);
                        }
                    }
                    if($scope.shiftToConfirm == 0){
                        $("#shiftConfirmationPopup").modal('hide');
                    }
                }
                $scope.$apply();
            }
            else {
    
            }
        }, { escape: false })
    }

    $scope.declineShift = function(jobId){
        CandidateDashboard_Controller.rejectShift(jobId,candidateId, function (result, event) {
    
            if (event.status) {
                Swal.fire(
                    '',
                    'Declined successfully!',
                    'success'
                )  
                if($scope.shiftToConfirm.length > 0){
                    for(var i=0;i< $scope.shiftToConfirm.length;i++){
                        if($scope.shiftToConfirm[i].Id == jobId){
                            $scope.shiftToConfirm.splice(i,1);
                        }
                    }
                    if($scope.applicationConfirmationList == 0){
                        $("#shiftConfirmationPopup").modal('hide');
                    }
                }
                $scope.$apply();  
            }
            else {
    
            }
        }, { escape: false })
    } 


    $scope.getDateFormat = function(Date,type){
        debugger;
        var beginDate = new Date(bDate);
        var endDate = new Date(eDate);
    
        if (type == "time")
            return 'HH:mm';
        else
            return 'dd.MM.yyyy';
    }

    $scope.getShiftsToAccept = function(){
        $scope.shiftToConfirm = [];
        debugger;
        CandidateDashboard_Controller.getAllocatedShifts(candidateId, function (result, event) {
    
            if (event.status) {
                if(result != null){
                    if(result.length > 0){
                        $scope.shiftToConfirm = result;
                        $("#shiftConfirmationPopup").modal('show');
                    }
                }

                $scope.$apply();  
            }
            else {
    
            }
        }, { escape: false })
    }
    $scope.getShiftsToAccept();

    $scope.declineJob = function(jobId){
        CandidateDashboard_Controller.rejectJob(jobId, function (result, event) {
    
            if (event.status) {
                Swal.fire(
                    '',
                    'Declined successfully!',
                    'success'
                )  
                if($scope.applicationConfirmationList.length > 0){
                    for(var i=0;i< $scope.applicationConfirmationList.length;i++){
                        if($scope.applicationConfirmationList[i].Id == jobId){
                            $scope.applicationConfirmationList.splice(i,1);
                        }
                    }
                    if($scope.applicationConfirmationList == 0){
                        $("#applicationConfirmationPopup").modal('hide');
                    }
                }
                $scope.$apply();  
            }
            else {
    
            }
        }, { escape: false })
    } 
   
   

    /*  $scope.uploadFile = function (type, userDocId, fileId) {
          
          var file = document.getElementById('profilePic').files[0];
          console.log(file);
          if (file != undefined) {
              if (file.size <= maxFileSize) {
                  
                  attachmentName = file.name;
                  const myArr = attachmentName.split(".");
                 
                  var fileReader = new FileReader();
                  fileReader.onloadend = function (e) {
                      attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                      positionIndex = 0;
                      fileSize = attachment.length;
                      console.log("Total Attachment Length: " + fileSize);
                      doneUploading = false;
                      if (fileSize < maxStringSize) {
                          $scope.uploadAttachment(fileId, userDocId);
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
  
      $scope.uploadAttachment = function (fileId, userDocId) {
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
              attachmentBody, attachmentName, fileId, userDocId,
              function (result, event) {
                  console.log(result);
                  if (event.type === 'exception') {
                      console.log("exception");
                      console.log(event);
                  } else if (event.status) {
                      if (doneUploading == true) {
                          $rootScope.profilePicId = result;
                          $scope.profilePic = true;
                          $scope.$apply();
  
                      } else {
                          positionIndex += chunkSize;
                          $scope.uploadAttachment(result, '');
                      }
                  } else {
                      console.log(event.message);
                  }
              },
  
  
              { buffer: true, escape: true, timeout: 120000 }
          );
      }  */

    $scope.selectedDays = function(checked,value){
        
        if(checked == true){
            $scope.selectedValue.push(value);
        }else{
            var index = $scope.selectedValue.indexOf(value);
            if (index !== -1) {
                $scope.selectedValue.splice(index, 1);
            }
        }
        
    }

    $scope.submitAvailablity = function(endTime,strtTime){
        debugger;
        $rootScope.showSpinner = true;
      
    if($scope.allDayAvailable == true){
        var startHour = 00;
        var startMin = 00;
        var endHour = 23;
        var endMin = 59;
    }else{
        var startHour = strtTime.getHours();
        var startMin = strtTime.getMinutes();
        var endHour = endTime.getHours();
        var endMin = endTime.getMinutes();
        $scope.strtTime;
        $scope.endTime;
    }
        CandidateDashboard_Controller.updateAvailabllity(candidateId,$scope.selectedValue,startMin,startHour,endMin,endHour, function (result, event) {
            if (event.status) {
                
                document.getElementById("colsePopup").click();
                
                Swal.fire(
                    '',
                    'Availablity Submitted successfully!',
                    'success'
                )
            }
            else {

            }
        }, { escape: false })
        $rootScope.showSpinner = false;

    }


  
  
    $scope.selectedCounty;
    cityInSelectedCounty = function(){
        //$scope.cityInSelectedCounty();
         
    }
  

   

    $scope.getTempJobs = function(){
        debugger;
        CandidateDashboard_Controller.getTempJobs($rootScope.candidateId, function (result, event) {
            if (event.status) {
               $scope.allTempJobs = result; 
            }
            else {
            }
        }, { escape: false })
    }
    $scope.name = 'World';

    $scope.example14model = [];
    $scope.setting1 = {
        scrollableHeight: '200px',
        scrollable: true,
        enableSearch: true
    };
    
        $scope.setting2 = {
        scrollableHeight: '200px',
        scrollable: true,
        enableSearch: false
    };
    
    $scope.example14data = [];
    $scope.example2settings = {
        displayProp: 'id'
    };

    $scope.referalEmail ;
    $scope.referFriend = function(){
        debugger;
        $scope.referalEmail;
        
        CandidateDashboard_Controller.referCandidate($rootScope.candidateId,$scope.referalEmail, function (result, event) {
            if (event.status) {
                if(result == "Success"){
                    Swal.fire(
                        '',
                        'Referred successfully!',
                        'success'
                    )

                    $("#referralModal").modal('hide');
                    $scope.referalEmail = "";
                }
            }
            else {
            }
        }, { escape: false })
    }
    $scope.myFunc = function (){
        debugger;
    }
});  