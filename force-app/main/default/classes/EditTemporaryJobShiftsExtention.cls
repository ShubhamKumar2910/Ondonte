/**
 * Author : Deagle
 */
public without sharing class EditTemporaryJobShiftsExtention {
    
    public Job_Requisition__c requisitionRecord {get;set;}
    
    List<String> queryFields = new List<String>{'Name'};
    public EditTemporaryJobShiftsExtention(Apexpages.StandardController reqStdController) {
        reqStdController.addFields(queryFields);
        this.requisitionRecord = (Job_Requisition__c)reqStdController.getRecord();
    }
    
    @RemoteAction
    public static Map<String,Object> getInit(Id requisitionId) {
        Map<String,Object> returnMap = new Map<String,Object>();
        if(String.isEmpty(requisitionId))
            return null;
        //returnMap.put('pick_crowns', Utility.getPicklistValues('Shift__c', 'Types_of_Crowns__c'));
        //returnMap.put('img_x_ray', Utility.getPicklistValues('Shift__c', 'Image_X_ray_Software__c'));
        returnMap.put('special_skills', Utility.getPicklistValues('Shift__c', 'Special_Skills__c'));
        returnMap.put('staff_type', Utility.getPicklistValues('Shift__c', 'Staff_Type__c'));
        returnMap.put('shifts', [SELECT Id, Name, Start_DateTime__c,Special_Skills__c, End_DateTime__c, Status__c, Staff_Type__c FROM Shift__c WHERE Start_Date__c>= TODAY AND Job_Requisition__c =:requisitionId AND RecordTypeId = :ShiftUtility.getClientShiftRTId() ORDER BY Start_DateTime__c DESC]);
        return returnMap;
    }


    @RemoteAction
    public static String createSlot(Shift__c shift, Slot__c slot, String startTime, String endTime, String arrivalTime, String selectionString) {
        System.debug('--- Slot '+slot);
        System.debug('--- selectionString'+selectionString);
        System.debug('--- shift__c'+shift);
        System.debug('--- arrivalTime'+arrivalTime);
        Savepoint sp = Database.setSavepoint();
        if(String.isEmpty(selectionString) || slot == null || startTime == null || endTime == null)
            return 'ERROR';
        try{
            Map<String,Object> selectionMap = (Map<String,Object>)JSON.deserializeUntyped(selectionString);
            System.debug('--- selectionMap'+ selectionMap);
            if(selectionMap.containsKey('frequency')) {
                String frequency = (String)selectionMap.get('frequency');
                insert slot;
                if(frequency == 'WEEKLY') {
                    Map<String, Map<String,Object>> dayOfWeekMap = new Map<String, Map<String,Object>>(); 
                    for(Object freqObj : (List<Object>)selectionMap.get('frequencies')) {
                        Map<String,Object> freqMap = (Map<String,Object>)freqObj;
                        dayOfWeekMap.put((String)freqMap.get('day'), new Map<String,Object>{'startTime' => Datetime.newInstance((Long)freqMap.get('startTime')), 'endTime' => Datetime.newInstance((Long)freqMap.get('endTime')), 'arrivalTime' => (String)freqMap.get('arrivalTime')});
                    }
                    ShiftUtility.createShifts(shift, slot, Datetime.newInstance(Long.valueOf(startTime)), Datetime.newInstance(Long.valueOf(endTime)), arrivalTime, dayOfWeekMap, false);
                }else {
                    String subFrequency = (String)selectionMap.get('subFrequency');
                    if(subFrequency == 'ON-MONTH') {
                        String dayOfMonth = (String)selectionMap.get('dayOfMonth');
                        ShiftUtility.createMonthlyShifts(shift, slot, Datetime.newInstance(Long.valueOf(startTime)), Datetime.newInstance(Long.valueOf(endTime)), arrivalTime, Integer.valueOf(dayOfMonth), false);
                    }else {
                        String weekOfMonth = (String)selectionMap.get('weekOfMonth');
                        String dayOFWeek = (String)selectionMap.get('dayOfWeek');
                        ShiftUtility.createWeeklyShifts(shift, slot, Datetime.newInstance(Long.valueOf(startTime)), Datetime.newInstance(Long.valueOf(endTime)), arrivalTime, weekOfMonth, dayOFWeek, false);
                    }
                }
            }
        }catch(Exception e) {
            Database.rollback(sp);
            HandleBusinessException.captureError('CP_SchedulePlannerController', 'createSlot', e);
            return e.getMessage();
        }
        return 'SUCCESS';
    }
    
    @RemoteAction
    public static String upsertShifts(List<Shift__c> shiftsList) {
        if(shiftsList == null || shiftsList.isEmpty())
            return 'ERROR';
        try{
        	upsert shiftsList;    
            return 'SUCCESS';
        }catch(DMLException e) {
            HandleBusinessException.captureError('CP_SchedulePlannerController', 'upsertShifts', e);
            return 'ERROR';
        }
        
    }


    @RemoteAction
    public static void deleteEvent(String shiftId) {
        if(!String.isBlank(shiftId))
            delete new Shift__c(Id = shiftId);
    }

    @RemoteAction
    public static String deleteSlot(String slotId) {
        if(!String.isBlank(slotId)) {
            try{
                delete new Slot__c(Id = slotId);
                return 'SUCCESS';
            }catch(DmlException e) {
                HandleBusinessException.captureError('CP_SchedulePlannerController', 'deleteSlot', e);
                return 'ERROR';
            }
            
        }
        return 'ERROR';
    }
}