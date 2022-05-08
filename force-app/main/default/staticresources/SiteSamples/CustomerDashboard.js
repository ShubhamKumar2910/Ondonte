var tabValues = [];
var app = angular.module('myApp', ['ngRoute']);
var sitePrefix = '/login'
app.config( function($routeProvider, $locationProvider) {
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
