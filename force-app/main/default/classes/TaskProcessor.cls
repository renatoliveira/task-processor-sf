/**
 * The main task processing class. This is the main entry point for the API
 * to be called by the other processes in the subscriber's application, such
 * as other flows, triggers, etc.
 */
public with sharing class TaskProcessor {
    /**
     * @description Get the process details for the given process ID
     * @param processId The ID of the process to get the details for
     * @return Map<String, Object> The process details
     */
    @AuraEnabled
    public static Map<String, Object> getProcess(Id processId){
        try {
            Process__c record = [
                SELECT Id, Name, CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate
                FROM Process__c
                WHERE Id = :processId
            ];

            return new Map<String, Object>{
                'id' => record.Id,
                'name' => record.Name,
                // 'description' => record.Description__c,
                'createdBy' => record.CreatedBy.Name,
                'createdDate' => record.CreatedDate,
                'lastModifiedBy' => record.LastModifiedBy.Name,
                'lastModifiedDate' => record.LastModifiedDate
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}