/**
 * Test class for the TaskProcessor class
 */
@IsTest
public with sharing class TaskProcessorTest {
    /**
     * @description Test the getProcess method
     */
    @IsTest
    static void testGetProcess() {
        Process__c process = new Process__c(
            Name = 'Test Process'
        );
        insert process;

        Test.startTest();
        Map<String, Object> result = TaskProcessor.getProcess(process.Id);
        Test.stopTest();

        process = [
            SELECT Id, Name, CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate
            FROM Process__c
            WHERE Id = :process.Id
        ];

        Assert.isNotNull(result, 'Should not be null');
        Assert.areEqual(process.Id, result.get('id'), 'Should be the same ID');
        Assert.areEqual(process.Name, result.get('name'), 'Should be the same Name');
        Assert.areEqual(process.CreatedBy.Name, result.get('createdBy'), 'Should be the same Created By');
        Assert.areEqual(process.CreatedDate, result.get('createdDate'), 'Should be the same Created Date');
        Assert.areEqual(process.LastModifiedBy.Name, result.get('lastModifiedBy'), 'Should be the same Last Modified By');
        Assert.areEqual(process.LastModifiedDate, result.get('lastModifiedDate'), 'Should be the same Last Modified Date');
    }

    @IsTest
    static void testCreateStageTasks() {
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

        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Test.startTest();
        Map<String, Object> result = TaskProcessor.createStageTasks(account.Id, stage.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'Should not be null');
        Assert.areEqual(1, result.get('count'), 'Should be 1');
        Assert.areEqual(1, ((List<Id>)result.get('taskIds')).size(), 'Should be 1');

        Task task = [SELECT Id, Subject FROM Task WHERE TaskDefinitionRef__c = :taskDefinition.Id];
        Assert.isNotNull(task, 'Should not be null');
        Assert.areEqual(task.Id, ((List<Id>)result.get('taskIds'))[0], 'Should be the same Task Definition ID');
        Assert.areEqual(taskDefinition.Name, task.Subject, 'Should be the same Task Definition Name');
    }

    @IsTest
    static void testCreateStageTasksNoDefinitions() {
        Process__c process = new Process__c(
            Name = 'Test Process'
        );
        insert process;

        ProcessStage__c stage = new ProcessStage__c(
            Name = 'Test Stage',
            ProcessRef__c = process.Id
        );
        insert stage;

        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Test.startTest();
        Map<String, Object> result = TaskProcessor.createStageTasks(account.Id, stage.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'Should not be null');
        Assert.areEqual(0, result.get('count'), 'Should be 0');
        Assert.areEqual(0, ((List<Id>)result.get('taskIds')).size(), 'Should be 0');
    }

    @IsTest
    static void testCreateStageTasksStageNotFound() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Id fakeStageId = Id.valueOf(Schema.ProcessStage__c.SObjectType.getDescribe().getKeyPrefix() + '000000000000AAA');
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            Map<String, Object> result = TaskProcessor.createStageTasks(account.Id, fakeStageId);
        } catch (TaskProcessorException e) {
            exceptionThrown = true;
            Assert.areEqual('Stage not found', e.getMessage(), 'Should be the same Message');
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Should be an exception thrown');
    }

    @IsTest
    static void testGetProcessStatsRecordInProcess() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Process__c process = new Process__c(
            Name = 'Test Process'
        );
        insert process;

        ProcessMember__c processMember = new ProcessMember__c(
            RecordId__c = account.Id,
            ProcessRef__c = process.Id
        );
        insert processMember;

        Test.startTest();
        Map<String, Object> result = TaskProcessor.getProcessStats(account.Id, process.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'Should not be null');
        Assert.areEqual(0, result.get('count'), 'Should be 0');
        Assert.areEqual(0, ((List<Id>)result.get('taskIds')).size(), 'Should be 0');
        Assert.areEqual(0, result.get('completed'), 'Should be 0');
    }

    @IsTest
    static void testGetProcessStatsRecordNotInProcess() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Process__c process = new Process__c(
            Name = 'Test Process'
        );
        insert process;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            Map<String, Object> result = TaskProcessor.getProcessStats(account.Id, process.Id);
        } catch (TaskProcessorException e) {
            exceptionThrown = true;
            Assert.areEqual('Process member not found', e.getMessage(), 'Should be the same Message');
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Should be an exception thrown');
    }
}