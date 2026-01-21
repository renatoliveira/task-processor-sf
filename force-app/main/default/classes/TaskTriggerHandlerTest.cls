/**
 * Test class for the TaskTriggerHandler class
 */
@IsTest
public with sharing class TaskTriggerHandlerTest {
    @TestSetup
    static void setup(){
        Process__c process = new Process__c(
            Name = 'Test Process'
        );
        insert process;

        ProcessStage__c stage = new ProcessStage__c(
            Name = 'Test Stage',
            ProcessRef__c = process.Id
        );
        insert stage;

        TaskDefinition__c taskDefinition = new TaskDefinition__c(
            Name = 'Test Task Definition',
            StageRef__c = stage.Id,
            CompletionFormula__c = 'true'
        );
        insert taskDefinition;
    }

    @IsTest
    static void testOnAfterUpdateCompleteTask() {
        Process__c process = [SELECT Id FROM Process__c LIMIT 1];
        TaskDefinition__c taskDefinition = [SELECT Id FROM TaskDefinition__c LIMIT 1];

        Task task = new Task(
            WhatId = process.Id,
            Subject = 'Test Task',
            TaskDefinitionRef__c = taskDefinition.Id
        );
        insert task;

        Test.startTest();
        task.Description = 'Testing the update';
        update task;
        Test.stopTest();

        task = [SELECT Id, Status FROM Task WHERE Id = :task.Id];

        Assert.areEqual('Completed', task.Status, 'Should be completed');
    }

    @IsTest
    static void testOnAfterUpdateIncompleteTask() {
        Process__c process = [SELECT Id FROM Process__c LIMIT 1];
        TaskDefinition__c taskDefinition = [SELECT Id FROM TaskDefinition__c LIMIT 1];
        taskDefinition.CompletionFormula__c = 'false';
        update taskDefinition;

        Task task = new Task(
            WhatId = process.Id,
            Subject = 'Test Task',
            TaskDefinitionRef__c = taskDefinition.Id
        );
        insert task;

        Test.startTest();
        task.Description = 'Testing the update';
        update task;
        Test.stopTest();

        task = [SELECT Id, Status FROM Task WHERE Id = :task.Id];

        Assert.areNotEqual('Completed', task.Status, 'Should not be completed');
    }

    @IsTest
    static void testOnAfterUpdateCompleteMultipleTasks() {
        Process__c process = [SELECT Id FROM Process__c LIMIT 1];
        TaskDefinition__c taskDefinition = [SELECT Id FROM TaskDefinition__c LIMIT 1];
        List<Task> tasks = new List<Task>();

        for (Integer i = 0; i < 10; i++) {
            Task task = new Task(
                WhatId = process.Id,
                Subject = 'Test Task ' + i,
                TaskDefinitionRef__c = taskDefinition.Id
            );
            tasks.add(task);
        }

        insert tasks;

        for (Task t : tasks) {
            t.Description = 'Testing the update';
        }

        Test.startTest();
        update tasks;
        Test.stopTest();

        tasks = [SELECT Id, Status FROM Task WHERE Id IN :tasks];

        for (Task t : tasks) {
            Assert.areEqual('Completed', t.Status, 'Should be completed');
        }
    }
}