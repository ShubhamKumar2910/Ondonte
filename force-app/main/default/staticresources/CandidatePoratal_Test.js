var tabValues = [];

var app = angular.module('myApp', ['ngRoute']);
var sitePrefix = '/login'
app.config(function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(false).hashPrefix('');
    var rp = $routeProvider;  
    
    
    
    for(var i=0;i<tabValues.length;i++){
        var pageName = '/'+tabValues[i].Name;
        
        if(tabValues[i].Apex_class_Name__c != undefined){
            rp.when(pageName,{
                
                templateUrl:sitePrefix+pageName,
                controller:tabValues[i].Apex_class_Name__c
            });
        }else{
            rp.when(pageName, {templateUrl: sitePrefix+pageName,
                              })
        }
        
    }
});

window.onload = function(){
            
}
function myFunction(){
 
var fb	= document.getElementById('facebookUrlId');

}
function myFunctionforgoogle(){
 
var a = document.getElementById('googleUrlId');
}


app.controller('myCtrl', function($scope, $timeout, $window, $location,$element) {
    
    $scope.tabValues = tabValues;
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
             
                if(event.status && result != null){
                    
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