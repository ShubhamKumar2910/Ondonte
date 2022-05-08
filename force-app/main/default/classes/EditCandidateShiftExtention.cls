/**
 * Author: Deagle
 */

public without sharing class EditCandidateShiftExtention {
    public Contact candidateRecord {get;set;}
    
    List<String> queryFields = new List<String>{'LastName', 'Profile_Pic_Attachment_Id__c', 'Name', 'Profile_Picture_URL__c'};
    public EditCandidateShiftExtention(Apexpages.StandardController conStdController) {
        conStdController.addFields(queryFields);
        this.candidateRecord = (Contact)conStdController.getRecord();
    }
    
    @RemoteAction
    public static List<Shift__c> getInit(Id candidateId) {
        if(String.isEmpty(candidateId))
            return null;
        return [SELECT Id, Name, Start_DateTime__c, End_DateTime__c, Status__c FROM Shift__c WHERE Contact__c =:candidateId AND RecordTypeId = :ShiftUtility.getCandidateShiftRTId() AND Start_Date__c >= TODAY ORDER BY Start_DateTime__c DESC];
    }


    @RemoteAction
    public static String createSlot(Slot__c slot, String startTime, String endTime, String selectionString) {
        System.debug('--- Slot '+slot);
        System.debug('--- selectionString'+selectionString);
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
                        dayOfWeekMap.put((String)freqMap.get('day'), new Map<String,DateTime>{'startTime' => Datetime.newInstance((Long)freqMap.get('startTime')), 'endTime' => Datetime.newInstance((Long)freqMap.get('endTime'))});
                    }
                    ShiftUtility.createShifts(null, slot, Datetime.newInstance(Long.valueOf(startTime)), Datetime.newInstance(Long.valueOf(endTime)), null, dayOfWeekMap, true);
                }else {
                    String subFrequency = (String)selectionMap.get('subFrequency');
                    if(subFrequency == 'ON-MONTH') {
                        String dayOfMonth = (String)selectionMap.get('dayOfMonth');
                        ShiftUtility.createMonthlyShifts(null, slot, Datetime.newInstance(Long.valueOf(startTime)), Datetime.newInstance(Long.valueOf(endTime)), null, Integer.valueOf(dayOfMonth), true);
                    }else {
                        String weekOfMonth = (String)selectionMap.get('weekOfMonth');
                        String dayOFWeek = (String)selectionMap.get('dayOfWeek');
                        ShiftUtility.createWeeklyShifts(null, slot, Datetime.newInstance(Long.valueOf(startTime)), Datetime.newInstance(Long.valueOf(endTime)), null, weekOfMonth, dayOFWeek, true);
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