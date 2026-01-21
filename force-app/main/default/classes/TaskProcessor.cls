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

    /**
     * @description For a given record in a process, get the stats for the process
     * @param parentId The ID of the parent record
     * @param processId The ID of the process to get the stats for
     * @return Map<String, Object> The process stats
     */
    public static Map<String, Object> getProcessStats(Id parentId, Id processId) {
        throw new UnsupportedOperationException('Not implemented');
    }

    public static Map<String, Object> getStageStats(Id parentId, Id stageId) {
        throw new UnsupportedOperationException('Not implemented');
    }

    /**
     * @description Create the tasks for the given stage according to the task definitions
     * @param parentId The ID of the parent record
     * @param stageId The ID of the stage to create the tasks for
     * @return Map<String, Object> The created tasks info
     */
    public static Map<String, Object> createStageTasks(Id parentId, Id stageId) {
        ProcessStage__c stage;

        try {
            stage = [
                SELECT Id, Name, ProcessRef__c, ProcessRef__r.Name
                FROM ProcessStage__c
                WHERE Id = :stageId
            ];
        } catch (QueryException e) {
            AuraHandledException result = new AuraHandledException('Stage not found');
            result.setMessage('Stage not found');
            throw result;
        }

        List<TaskDefinition__c> taskDefinitions = [
            SELECT Id, Name, StageRef__c, StageRef__r.Name
            FROM TaskDefinition__c
            WHERE StageRef__c = :stageId
        ];

        if (taskDefinitions.isEmpty()) {
            return new Map<String, Object>{
                'count' => 0,
                'taskIds' => new List<Id>()
            };
        }

        List<Task> tasks = new List<Task>();

        for (TaskDefinition__c td : taskDefinitions) {
            Task task = new Task(
                WhatId = parentId,
                Subject = td.Name,
                TaskDefinitionRef__c = td.Id
            );
            // TODO: calculate default assignee
            tasks.add(task);
        }

        List<Database.SaveResult> results = Database.insert(tasks);
        List<Id> taskIds = new List<Id>();

        for (Database.SaveResult result : results) {
            taskIds.add(result.getId());
        }

        return new Map<String, Object>{
            'count' => taskIds.size(),
            'taskIds' => taskIds
        };
    }
}