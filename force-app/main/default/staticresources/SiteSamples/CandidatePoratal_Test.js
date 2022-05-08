var tabValues = [];
debugger;
var app = angular.module('myApp', ['ngRoute']);
var sitePrefix = '/Login'
app.config( function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(false).hashPrefix('');
    $routeProvider

    .when('/', {templateUrl: sitePrefix+'/Candidatedashboard',
                      })
    .when('/CandidatePortal', {templateUrl: sitePrefix+'/CandidatePortal',
                      })
    .when('/LoginPage', {templateUrl: sitePrefix+'/LoginPage',
                      })

    
});


window.onload = function(){
            
}
function myFunction(){
debugger; 
var fb	= document.getElementById('facebookUrlId');

}
function myFunctionforgoogle(){
debugger; 
var a = document.getElementById('googleUrlId');
}


app.controller('myCtrl', function($scope, $timeout, $window, $location,$element) {
    debugger;
    $scope.employee = false;
    $scope.employer = false;
    $scope.userLogedIn = false;
    $scope.userName;
    $scope.userPassword;
    $scope.userLoggedIn = false;
    $scope.loginUser = function(userName,userPassword){
        $scope.userName;
    $scope.userPassword;
         CustomerDashboard_Controller.loginUser($scope.userName,$scope.userPassword, function(result,event){
             debugger;
                if(event.status && result != null){
                    debugger;
                    $scope.Profile = result;
                    $scope.hashcodeId = $scope.Profile.Login_Hash_Code__c;
                    $scope.userLoggedIn = true;
                    Swal.fire({
                        icon: 'success',
                        title: 'Logged in Successfully',
                        showConfirmButton: false,
                        timer: 1500
                    })
                    $scope.$apply();
                     //
                     
                    window.location.href  = "?d="+$scope.Profile.Login_Hash_Code__c+'#/CandidatePortal';
                    
                }
                else{
                    Swal.fire({
                        icon: 'error',
                        title: 'Oops...',
                        text: 'Please enter the correct Username and Password!'
                    })
                }
            },{escape:false})
    }
    
});  