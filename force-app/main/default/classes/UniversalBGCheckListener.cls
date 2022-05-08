/**
 * Author : Prithvi
 */
@RestResource(urlMapping='/universal_bg_listener')
global class UniversalBGCheckListener {
    
    @HttpPost global static ResponseWrapper doPost() {
        try {
            String requestJSON = RestContext.request.requestBody.toString();
            System.debug('--- requestJSON' + requestJSON);
            
            return new ResponseWrapper(true, '');
        } catch (Exception error) {
            System.debug('--- error :'+error.getMessage());
            System.debug('--- line no:'+error.getLineNumber());
            return new ResponseWrapper(false, 'Something went wrong!');
        }
    }
    
    global class ResponseWrapper {

		global Boolean success;
		global String message;
        
        global ResponseWrapper(Boolean success, String message) {
            this.success = success;
            this.message = message;
        }

    }
    
}