var skillList = [];
var staffList = [];
function myFunction() {
    debugger;
    var fb = document.getElementById('facebookUrlId');
    fb.href = "https://www.facebook.com/v2.8/dialog/oauth?client_id=" + "{!$Setup.Facebook_API_Details__c.App_Id__c}" + "&response_type=code&redirect_uri=" + "{!$Setup.Facebook_API_Details__c.login_Site_URL__c}" + "&scope=public_profile,email&&auth_type=rerequest";

}
function myFunctionforgoogle() {
    debugger;
    var a = document.getElementById('googleUrlId');
    a.href = "https://accounts.google.com/AccountChooser?continue=https://accounts.google.com/o/oauth2/auth?redirect_uri=" + "{!$Setup.Google_API_Details__c.Login_Redirect_URI__c}" + "%26prompt%3Dconsent%26response_type%3Dcode%26client_id=" + "{!$Setup.Google_API_Details__c.Client_Id__c}" + "%26scope%3Dhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.me%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.me%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.me%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/userinfo.email%26access_type%3Doffline%26from_login%3D1%26as%3D-270badd61a3e150b&btmpl=authsub&scc=1&oauth=1";
}

var app = angular.module('LoginApp', []);
app.controller('LoginCtlr', function ($scope) {
    debugger;
    $scope.userName = '';
    $scope.userPassword = '';
    $scope.registrationPage = false;
    $scope.skillList = skillList;
    $scope.staffList = staffList;
    $scope.isRegistration = isRegistration;
    $scope.contactDetails = { FirstName: "", LastName: "", Email: "", Phone: "", Computer_Skills__c:"" };
    $scope.verifyEmail ;
    $scope.contactDetails.FirstName = first_name;
    $scope.refralId = refralId;
    $scope.contactDetails.Email = gemail;
    $scope.compSkillPickVal = compSkillPickVal;
            $scope.imgeSoftwarePickVal = imgeSoftwarePickVal;
            $scope.crownPicklistVal = crownPicklistVal;
    $scope.showSpinner = false;
    debugger;
   

    if(isRegistration == "true"){
        $scope.registrationPage = true;
    }else{
        $scope.registrationPage = false;
    }

    $scope.loginUser = function () {
        $scope.userName;
        $scope.userPassword;
        $scope.showSpinner = true;
        CP_LoginPage_Controller.loginUser($scope.userName, $scope.userPassword, function (result, event) {
            if (event.status && result != null) {
                $scope.Profile = result;
                $scope.hashcodeId = $scope.Profile.Login_Hash_Code__c;
                $scope.userLoggedIn = true;
                Swal.fire(
                    '',
                    'LoggedIn Successfully!',
                    'success'
                  )
                $scope.$apply();
                debugger;
                let mainURL = window.location.origin+'/apex';
                if(result.Candidate_Status__c == "Document Upload"){
                    window.location.replace(mainURL+"/CP_DocumentUpload?hc="+$scope.Profile.Login_Hash_Code__c);
                    return;
                }
                window.location.replace(mainURL+"/CandidateDashboard?hc=" + $scope.Profile.Login_Hash_Code__c+'#/CP_HomePage');
           // window.location.href = "/apex/CandidateDashboard?d=" + $scope.Profile.Login_Hash_Code__c+'#/CP_HomePage';

            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    text: 'Please enter the correct Username and Password!'
                })
            }
        }, { escape: false })
        $scope.showSpinner = false;
        $scope.$apply();
    }

    $scope.showRegForm = function(){
        $scope.registrationPage = true;
    }
    $scope.selectedStaffType = [];
    $scope.staffTypePickValue = function(staff){
        debugger;
        if($scope.selectedStaffType.includes(staff)){
            
            $scope.selectedStaffType.splice($scope.selectedStaffType.indexOf(staff),1);
        }else{
            $scope.selectedStaffType.push(staff);
        }
    }

    $scope.registerUser = function(){
        debugger;
        $scope.showSpinner = true;
        $scope.contactDetails.MailingCountry  = '';
        if($scope.contactDetails.Email == "" || $scope.contactDetails.LastName == ""){
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'Please Enter your Last Name and Email Id!'
            })
            $scope.showSpinner = false;
            return;
        }

        if($scope.selectedStaffType.length == 0){
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: 'Please Select Staff Type!'
            })
            $scope.showSpinner = false;
            return;
        }else{
            $scope.contactDetails.Staff_Type__c = $scope.selectedStaffType.join(';');
        }

        CP_LoginPage_Controller.registerCandidate($scope.contactDetails ,refralId,function(result,event){
            if(event.status){ // && result != null
                debugger;
                if(result== "recexists"){
                    $scope.showSpinner = false;
                    Swal.fire({
                        icon: 'error',
                        title: 'Oops...',
                        text: 'Your are already registered, please login!'
                    })
                }else{
                    $scope.showSpinner = false;
                    Swal.fire(
                        '',
                        'Details Submitted Successfully! Our recruter will get in touch shortly',
                        'success'
                      )
                }
                $scope.selectedStaffType = [];
                  let mainURL = window.location.origin+'/apex';
                  window.location.replace(mainURL+"/CP_LoginPage?register=false");
                  //window.location.replace(mainURL+"/CP_DocumentUpload?hc="+result);
            }
           
        },{escape:false})
    }

    $scope.backToLoginPage = function(){
        $scope.registrationPage = false;        
    }

    $scope.checkForEmail = function(){
        $scope.showSpinner = true;
        CP_LoginPage_Controller.verifyEmail($scope.verifyEmail ,function(result,event){
            if(event.status){ // && result != null
                debugger;
              if(result != null){
                Swal.fire(
                    '',
                    'Password reset link sent to your registered Email Successfully!',
                    'success'
                  )
              }
            }
            else{
              
            }
        },{escape:false})
        $scope.showSpinner = false;
    }
});