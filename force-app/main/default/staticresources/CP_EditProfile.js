
angular.module('cp_app').controller('cp_editprofile_ctrl', function ($scope,$rootScope, $log, $timeout) {
    debugger;

    $rootScope.userDetails;
    $rootScope.profilePicId;
    $scope.profilePic = true;
    $scope.contactUserDocument = [];
    $rootScope.blobData;
    $scope.showSpinnereditProf = false;
    $scope.resumeIframe = "data:application/pdf;base64,"+$rootScope.blobData;
    $rootScope.blobData;
    $scope.showSpinnereditProf = false;
    $scope.getExperienceDetail = function () {
        $scope.showSpinnereditProf = true;
        CandidateDashboard_Controller.getAllWorkExperience($rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                
                $scope.prevExprience = result;
                $scope.$apply();
            }
            else {

            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

    $scope.changeProfilePic = function () {
        $scope.profilePic = false;
    }


    $scope.uploadProfilePic = function () {
        debugger;
        $scope.uploadFile("profilePic", "", $rootScope.profilePicUD.userDocument.Id);
    }

    $scope.selUserDocId = function (fileId,doc) {
        
        $scope.showUplaodUserDoc = true;
        $scope.fileId = fileId;
        $scope.selecteduDoc = doc;
    }

    $scope.backFromUploadDoc = function () {
        $scope.showUplaodUserDoc = false;
        $scope.fileId = '';
        $scope.selecteduDoc = '';
    }
    $scope.uploadFileToUserDoc = function (type) {
        
       debugger;
        $scope.selecteduDoc;
        
        if ($scope.fileId != undefined) {
            $scope.uploadFile(type, $scope.selecteduDoc, $scope.fileId);
        } else {
            if (type == 'resume') {
                if ($rootScope.resumeUserDoc.contentVersion != undefined) {
                    $scope.uploadFile(type, $rootScope.resumeUserDoc.userDocument.Id, $rootScope.resumeUserDoc.contentVersion.Id);
                } else {
                    $scope.uploadFile(type, $rootScope.resumeUserDoc.userDocument.Id, "");
                }
            } else if(type == 'profilePic'){
                $scope.uploadFile(type, $rootScope.resumeUserDoc.Id, "");
            }
            else {
                $scope.uploadFile(type, $scope.selecteduDoc, "");
            }
        }
     
    }

    $scope.getContactUserDoc = function () {
        debugger;
        $scope.contactUserDocument = [];
        $scope.showSpinnereditProf = true;
        CandidateDashboard_Controller.getContactUserDoc($rootScope.candidateId, function (result, event) {

            if (event.status && result != null) {
                debugger;
                for (var i = 0; i < result.length; i++) {
                    if (result[i].userDocument.Name == "Profile Picture") {
                        $rootScope.profilePicUD = result[i];
                    } else if (result[i].userDocument.Name == "Resume") {
                        $rootScope.resumeUserDoc = result[i];
                        if($rootScope.resumeUserDoc.contentVersion != null){
                            $rootScope.updateResume = false;
                        }
                    } else {
                        $scope.contactUserDocument.push(result[i]);
                    }
                }
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }
    $scope.getContactUserDoc();
    $scope.getUserDoc = function () {
        debugger;
        $scope.showSpinnereditProf = true;
        CandidateDashboard_Controller.getAllUserDoc($rootScope.candidateId, function (result, event) {

            if (event.status && result != null) {
                debugger;
                for (var i = 0; i < result.length; i++) {
                    if (result[i].userDocument.Name == "Profile Picture") {
                        $rootScope.profilePicUD = result[i];
                    } else if (result[i].userDocument.Name == "Resume") {
                        $rootScope.resumeUserDoc = result[i];
                        if($rootScope.resumeUserDoc.contentVersion != null){
                            $rootScope.updateResume = false;
                        }
                    } else {
                        $scope.contactUserDocument.push(result[i]);
                    }
                }
                $scope.$apply();

            }
            else {

            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

    $scope.uploadFile = function (type, userDocId, fileId) {
        debugger;
        $scope.showSpinnereditProf = true;
        var file;
        if (type == 'profilePic') {
            file = document.getElementById('profilePic').files[0];
        } else if (type == 'resume') {
            file = document.getElementById('resumeAttachmentFile').files[0];
        }
        else {
            file = document.getElementById('attachmentFiles').files[0];
        }

        console.log(file);
        if (file != undefined) {
            if (file.size <= maxFileSize) {
                
                attachmentName = file.name;
                const myArr = attachmentName.split(".");
                if (myArr[1] != "pdf" && type != 'profilePic') {
                    alert("Please upload in PDF format only");
                    return;
                }
                var fileReader = new FileReader();
                fileReader.onloadend = function (e) {
                    attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                    positionIndex = 0;
                    fileSize = attachment.length;
                    $scope.showSpinnereditProf = false;
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
                $scope.showSpinnereditProf = false;
            }
        } else {
            alert("You must choose a file before trying to upload it");
            $scope.showSpinnereditProf = false;
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
            type, attachmentBody, attachmentName, candidateId, userDocId,fileId, 
            function (result, event) {
                console.log(result);
                if (event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
                } else if (event.status) {
                    if (doneUploading == true) {
                        if (type == 'profilePic') {
                            $rootScope.profilePicId = result;
                            $scope.profilePic = true;
                            Swal.fire(
                                '',
                                'Uploaded Successfully!',
                                'success'
                            )
                            $scope.$apply();
                        } else if (type == 'resume') {
                            
                            $scope.parseResume(result);
                            $rootScope.updateResume = false;
                        }else{
                            Swal.fire(
                                '',
                                'Uploaded Successfully!',
                                'success'
                            )
                            $("#fileUploadModel").modal('hide');
                            $("#resumeUploadModel").modal('hide');
                            
                            $scope.getContactUserDoc();
                        }
                        $scope.showUplaodUserDoc = false;
                       // $scope.getCandidateDetails();

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
    }

    $scope.getResumeDetail = function(){
        
    }

    $scope.educationDetails = [];
    $scope.experienceDetails = [];
    $scope.parseResume = function (attId) {
        debugger;
        CandidateDashboard_Controller.resumeParser(attId, $rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                
                Swal.fire(
                    '',
                    'Resume Updated successfully!',
                    'success'
                ) 
                $scope.showResumeParser = true;
               // $scope.educationDetails = result.Value.RedactedResumeData.Education.EducationDetails;
               // $scope.experienceDetails = result.Value.RedactedResumeData.EmploymentHistory.Positions;
              //  $scope.skillDetails = result.Value.RedactedResumeData.SkillsData;

                for(var i=0;i<result.Value.ResumeData.Education.EducationDetails.length;i++){
                    $scope.education = { Candidate__c: candidateId, Course_Name__c: "", University_College_Name__c: "", End_Year__c: "", Start_Year__c: "" };
                    if(result.Value.ResumeData.Education.EducationDetails[i].Majors != undefined)
                        $scope.education.Course_Name__c = result.Value.ResumeData.Education.EducationDetails[i].Majors[0];
                    if(result.Value.ResumeData.Education.EducationDetails[i].SchoolName != undefined)
                        $scope.education.University_College_Name__c = result.Value.ResumeData.Education.EducationDetails[i].SchoolName.Normalized;
                    if(result.Value.ResumeData.Education.EducationDetails[i].LastEducationcdate != undefined)
                        $scope.education.End_Year__c = result.Value.ResumeData.Education.EducationDetails[i].LastEducationcdate.cdate;
                    
                    $scope.educationDetails.push($scope.education);
                }

                for(var i=0;i<result.Value.ResumeData.EmploymentHistory.Positions.length;i++){
                    $scope.experience = { Applicant__c: candidateId, Employer_Name__c: "" , Duration__c : "", End_date__c: "", Job_Ttle__c: "",Start_Date__c:"", Name:""};

                    if(result.Value.ResumeData.EmploymentHistory.Positions[i].Employer != undefined)
                        $scope.experience.Employer_Name__c = result.Value.ResumeData.EmploymentHistory.Positions[i].Employer.Name.Normalized;
                    if(result.Value.ResumeData.EmploymentHistory.Positions[i].Employer != undefined)
                        $scope.experience.Name = result.Value.ResumeData.EmploymentHistory.Positions[i].JobType;
                    if(result.Value.ResumeData.EmploymentHistory.Positions[i].Startcdate != undefined)
                        $scope.experience.Start_Date__c = result.Value.ResumeData.EmploymentHistory.Positions[i].Startcdate.cdate;
                    if(result.Value.ResumeData.EmploymentHistory.Positions[i].Endcdate != undefined)
                        $scope.experience.End_date__c = result.Value.ResumeData.EmploymentHistory.Positions[i].Endcdate.cdate;

                    $scope.experienceDetails.push($scope.experience);
                } 
                
                $scope.candidateDetails = { Id: candidateId, Email: "" , MailingStreet: "",MailingCountry:result.Value.ResumeData.ContactInformation.Location.CountryCode, Name:result.Value.ResumeData.ContactInformation.CandidateName.FamilyName};


                $scope.getContactUserDoc();
                $scope.$apply();
            }
            else {

            }
        }, { escape: false })
    }

    $scope.saveWorkExp = function () {
        debugger;
        $scope.showSpinnereditProf = true;
        $scope.showAddExperience = false;
        $scope.workExp;
        var dateVal = $scope.expStartDate;
        var date = dateVal.getDate();
        var month = dateVal.getMonth();
        var year = dateVal.getFullYear();
        $scope.expStartDate = month.toString() + '/' + date.toString() + '/' + year.toString();

        var dateVal1 = $scope.expEndDate;
        var date1 = dateVal1.getDate();
        var month1 = dateVal1.getMonth();
        var year1 = dateVal1.getFullYear();
        $scope.expEndDate = month1.toString() + '/' + date1.toString() + '/' + year1.toString();
        $scope.showSpinnereditProf = true;
        CandidateDashboard_Controller.addWorkExperience($scope.workExp, $scope.expStartDate, $scope.expEndDate, function (result, event) {
            if (event.status && result != null) {
                
                // $scope.prevExprience = result;
                Swal.fire(
                    '',
                    'Work Experience added successfully!',
                    'success'
                )
                $scope.showSpinnereditProf = false;

                $scope.getExperienceDetail();
            }
            else {

            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

    $scope.updateUserDetails = function () {
        $scope.showSpinnereditProf = true;
        delete $scope.userDetails.User_Documents__r;
        delete $scope.userDetails.Preferred_End_Time__c;
        delete $scope.userDetails.Preferred_Start_Time__c;
        delete $scope.userDetails.Preferred_Working_Days__c;
        CandidateDashboard_Controller.updateUserDetails($scope.userDetails, function (result, event) {
            if (event.status) {
                
                $scope.editProfile = true;
                Swal.fire(
                    '',
                    'Updated successfully!',
                    'success'
                )
            $scope.showSpinnereditProf = false;
            }
            else {
            $scope.showSpinnereditProf = false;
            }
            $scope.$apply();
        }, { escape: false })
    }

    $scope.updateResumeFunc = function(){
        
        $rootScope.updateResume = true;
        $rootScope.resumeUserDoc;
        $scope.$apply();
    }
    $scope.viewDocument = function (docId) {
        
        window.location.replace('https://ondonte--dev--c.documentforce.com/sfc/servlet.shepherd/version/download/' + docId + '?asPdf=false&operationContext=CHATTER', '_blank', 'location=yes,height=570,width=520,scrollbars=yes,status=yes');
    }

    $scope.editProfileFunc = function () {
        debugger;
        $scope.editProfile = false;
    }

    $scope.addUserExperience = function () {
        
        $scope.showAddExperience = true;
        $scope.workExp = { Name: "", Employer_Name__c: "", Duration__c: "", Applicant__c: candidateId };
        $scope.expStartDate = "";
        $scope.expEndDate = "";
    }
    $scope.addNewCityDetails = function(){
        debugger;
        $scope.showSpinnereditProf = true;

        $scope.example14model; 
        var cityListId = [];
        if($scope.example14model == undefined)
            return;
        
        for(var i=0;i<$scope.example14model.length;i++){
            cityListId.push($scope.example14model[i].id);
        }
        CandidateDashboard_Controller.addNewPreferedWorkLocation($scope.selectedCounty,cityListId,$rootScope.candidateId, function (result, event) {
            if (event.status) {
                debugger;
                $scope.selectedCounty = '';
                $scope.example14model = [];
                cityListId = [];
                $scope.getPreferredWorkingLocation();
                if(result == 'success'){
                    Swal.fire(
                        '',
                        'Location Added successfully!',
                        'success'
                    )
                }
            }
            else {
            }
            $scope.showSpinnereditProf = false;
            
        }, { escape: false })

        $scope.showSpinnereditProf = false;
        $scope.$apply();
    }

    $scope.delteWorkLocation = function(location){
        $scope.showSpinnereditProf = true;
        debugger;
        if(location == undefined)
            return;
        delete location.$$hashKey;
        $scope.showSpinnereditProf = true;
        CandidateDashboard_Controller.delteWorkLocation(location, function (result, event) {
            if (event.status) {
                $scope.showSpinnereditProf = false;
                $scope.getPreferredWorkingLocation();
                $scope.$apply();
                Swal.fire(
                    '',
                    'Location Removed successfully!',
                    'success'
                )
            }
            else {
                Swal.fire(
                    '',
                    'Duplicate City Found!',
                    'error'
                )
            }
        }, { escape: false })
    }
    
    $scope.getAllCounties = function(){
        CandidateDashboard_Controller.getAllCounties( function (result, event) {
            debugger;
            if (event.status) {
                
                $scope.countyList = result;
            }
            else {
            }
        }, { escape: false })
    }
    $scope.example14data = [];
    $scope.cityInSelectedCounty = function(){
        $scope.example14data = [];
        console.log('$scope.selectedCounty::'+$scope.selectedCounty);
        CandidateDashboard_Controller.getAllCityInCounty($scope.selectedCounty,$scope.selectedCityList, function (result, event) {
            if (event.status) {
                debugger;
               // $scope.cityList = result;
               if(result.length > 0){
                   for(var i=0;i<result.length;i++){
                    $scope.example14data.push({
                        "label":result[i].Name ,
                            "id": result[i].Id
                    });
                   }
               }
              // $scope.example14data = result;
            }
            else {
            }
        }, { escape: false })
    }

    $scope.selectedCityList = [];
    $scope.getPreferredWorkingLocation = function(){
        $scope.selectedCityList = [];
        CandidateDashboard_Controller.getPreferredWorkingLocation($rootScope.candidateId, function (result, event) {
            if (event.status) {
                $scope.prefWorkLocation = result;
                if($scope.prefWorkLocation != undefined){
                    for(var i=0;i<$scope.prefWorkLocation.length;i++){
                        $scope.selectedCityList.push($scope.prefWorkLocation[i].City__c); 
                    }
                }
                $scope.$apply();
                debugger;
              
            }
            else {
            }
        }, { escape: false })
    }
    $scope.getPreferredWorkingLocation();


    $scope.saveCandidateResumeDetails = function(){
        
        $scope.showSpinnereditProf = true;
        if($scope.educationDetails.length > 0){
            for(var i=0; i<$scope.educationDetails.length;i++){
                delete $scope.educationDetails[i].$$hashKey;
                delete $scope.educationDetails[i].End_Year__c;
            }
        }

        if($scope.experienceDetails.length > 0){
            for(var i=0; i<$scope.experienceDetails.length;i++){
                delete $scope.experienceDetails[i].$$hashKey;
                delete $scope.experienceDetails[i].Start_Date__c;
                delete $scope.experienceDetails[i].End_date__c;
            }
        }
        CandidateDashboard_Controller.saveResumeResponse($scope.educationDetails,$scope.experienceDetails, function (result, event) {
            if (event.status) {                
                Swal.fire(
                    '',
                    'Candidate Details Saved Successfully!',
                    'success'
                )
               /* document.getElementById("resumeParsing").click();  
                document.getElementById("candDetailPopup").click(); */
                $scope.showResumeParser = false;
                $scope.$apply();
                
            }
            else {

            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

});