public with sharing class AFEnrollSaveCaseClientController {
    @AuraEnabled
    public static AFEnrollService.SaveEnrollmentCaseResponse saveEnrollmentCase(String requestJSON) {
        system.debug('  saveEnrollmentCase::requestJSON ' + requestJSON);
        
        AFEnrollService.SaveEnrollmentCaseRequest request =
            (AFEnrollService.SaveEnrollmentCaseRequest) JSON.deserialize(requestJSON, AFEnrollService.SaveEnrollmentCaseRequest.class);
        system.debug('  saveEnrollmentCase::request ' + request);
        
        AFEnrollService service = new AFEnrollService();
        return service.saveEnrollmentCase(request);
    }
}