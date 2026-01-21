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
}