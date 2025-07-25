@isTest
public class AssetTriggerTest {
	//before insert
    @isTest
    static void testBeforeInsertActive() {
        Asset__c asset = new Asset__c(Name = 'Asset Active');
		
        Test.startTest();
        insert asset;
        Test.stopTest();

        Asset__c asset1 = [SELECT Id, Status__c FROM Asset__c WHERE Name = 'Asset Active'];
        System.assertEquals('Active', asset1.Status__c);
    }
    
   
    
    //after insert
    

    @isTest
    static void testInsertionLog() {
        
        Asset__c asset = new Asset__c(Name = 'Test Logg');
        
        Test.startTest();
        insert asset;
        Test.stopTest();

        
        List<Asset_Change_Log__c> logs = [SELECT Id, Change_Type__c, Field_Changes__c, Asset__c FROM Asset_Change_Log__c WHERE Asset__c = :asset.Id];

        System.assertEquals(1, logs.size());
        System.assertEquals('Created', logs[0].Change_Type__c);
        System.assertEquals('Asset created.', logs[0].Field_Changes__c);
    }
    
    
    
    @isTest
    static void testInsertLastAndNextDate() {
        
        Asset__c asset = new Asset__c(Name = 'LastDate Asset');
        insert asset;

        
        Date pastDate = Date.today().addDays(-7);
        Date futureDate = Date.today().addDays(3);
        Asset_Inspection__c inPast = new Asset_Inspection__c (Asset__c = asset.Id,Inspection_Date__c = pastDate);
        Asset_Inspection__c inFuture = new Asset_Inspection__c ( Asset__c = asset.Id,Inspection_Date__c = futureDate );
        

        Test.startTest();
        insert inPast;
        insert inFuture;
        Test.stopTest();

        
        Asset__c updatedAsset = [SELECT Last_Inspection_Date__c, Next_Inspection_Date__c FROM Asset__c WHERE Id = :asset.Id];

        System.assertEquals(pastDate, updatedAsset.Last_Inspection_Date__c);
        System.assertEquals(futureDate, updatedAsset.Next_Inspection_Date__c);
		
        List<Asset_Change_Log__c> logs = [SELECT Asset__c, Change_Type__c, Field_Changes__c FROM Asset_Change_Log__c WHERE Asset__c = :asset.Id ];
        
        System.assertEquals(3, logs.size());
        System.assertEquals('Inspection', logs[1].Change_Type__c);
        System.assertEquals('Inspection done on This Date', logs[1].Field_Changes__c);
    }
    
   @isTest
    static void testAfterInsertNotify() {
        AssetNotifier.assetCriteria = new List<Asset_Notification_Criteria__mdt>{
            new Asset_Notification_Criteria__mdt(
                Field_To_Validate__c = 'Compliance_Level__c',
                Value_To_Validate__c = 'Warning, Critical',
                Operator_To_Validate__c = 'IN',
                Event__c = 'AFTER INSERT',
                Object_Name__c = 'Asset_Inspection__c',
                Notification_Title__c = 'Compliance Alert',
                Notification_Body__c = 'Asset created with compliance level',
                NotificationTypeDevName__c = 'customnotification',
                Is_Active__c = true
            )
                };
                    
        Asset_Inspection__c testAsset = new Asset_Inspection__c(Compliance_Level__c = 'Warning');
        Boolean shouldNotify = AssetNotifier.evaluate(testAsset, null);
        System.assertEquals(true, shouldNotify);
    }

    
    //before update
    
    
    @isTest
    static void testCannotRetire() {
        
        Asset__c asset = new Asset__c(Name = 'Test Asset',Status__c = 'Active', Next_Inspection_Date__c = Date.today().addDays(10));
        insert asset;

        asset.Status__c = 'Retired';

        Test.startTest();
        try {
            update asset;
            System.assert(false, 'Expected DMLException due to addError, but none was thrown');
        } catch (DmlException e) {
            String message = e.getMessage();
            System.assert(message.contains('Cannot retire asset with upcoming inspection'), 'Error message mismatch');
        }
        Test.stopTest();
    }

   //after update
    
    static void testAfterUpdateLog() {
        
        Asset__c asset = new Asset__c(Name = 'update', Status__c = 'Active', Location__c = 'Loc A');
        insert asset;
		asset.Status__c = 'Retired';
        asset.Location__c = 'Loc B';

        Test.startTest();
        update asset;
        Test.stopTest();

        
        List<Asset_Change_Log__c> logs = [SELECT Id, Asset__c, Change_Type__c, Field_Changes__c FROM Asset_Change_Log__c WHERE Asset__c = :asset.Id AND Change_Type__c = 'Updated'];

        System.assertEquals(1, logs.size());
        System.assertEquals('Updated', logs[0].Change_Type__c);
        System.assert(logs[0].Field_Changes__c.contains('Status') && logs[0].Field_Changes__c.contains('Location'));
    }
    

    @isTest
    static void testEvaluateAndNotify() {
       
        Asset__c asset = new Asset__c(Name = 'Test Asset', Status__c = 'Active');
        insert asset;

        asset.Status__c = 'In Maintenance';
        update asset;

        List<Asset__c> newList = [SELECT Id, Status__c FROM Asset__c WHERE Id = :asset.Id];
        Asset__c oldAsset = new Asset__c(Id = asset.Id, Status__c = 'Active');
        Map<Id, Asset__c> oldMap = new Map<Id, Asset__c>();
        oldMap.put(asset.Id, oldAsset);

		Test.startTest();
        AssetNotifier.notify(newList, oldMap, 'AFTER UPDATE', 'Asset__c');
        Test.stopTest();

       
    }

    //before delete
   

    @isTest
    static void testRecentInspection() {
        
        Asset__c asset = new Asset__c(Name = 'Test Asset');
        insert asset;

        
        Asset_Inspection__c inspection = new Asset_Inspection__c(Asset__c = asset.Id,Inspection_Date__c = Date.today().addDays(-30));
        insert inspection;

        Test.startTest();
        try {
            delete asset;
            System.assert(false, 'Expected DMLException due to recent inspection, but none was thrown');
        } catch (DmlException e) {
            String message = e.getMessage();
            System.assert(message.contains('Cannot delete Asset: Inspections exist within the last year.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteRecentInspection() {
        
        Asset__c asset = new Asset__c(Name = 'Old Inspection Asset');
        insert asset;

       
        Asset_Inspection__c oldInspection = new Asset_Inspection__c(Asset__c = asset.Id,Inspection_Date__c = Date.today().addYears(-2));
        insert oldInspection;

        Test.startTest();
        delete asset;
        Test.stopTest();

        
        List<Asset__c> dlt = [SELECT Id FROM Asset__c WHERE Id = :asset.Id];
        System.assertEquals(0, dlt.size());
    }

    
    //after delete
   

    @isTest
    static void testAfterDelete() {
        Asset__c asset = new Asset__c(Name = 'Test Asset', Category__c = 'IT');
        insert asset;
    
        Asset_Inspection__c inspection = new Asset_Inspection__c( Asset__c = asset.Id,Inspection_Date__c = Date.today().addDays(-10));
        insert inspection;
    
        List<Asset__c> deletedAssetList = [SELECT Id, Name, Category__c, Last_Inspection_Date__c, Next_Inspection_Date__c FROM Asset__c WHERE Id = :asset.Id];

    
        Test.startTest();
   		AssetLogger.logChange(deletedAssetList, 'Deleted', null);
        
    	Test.stopTest();
    
       	List<Asset_Change_Log__c> logs = [SELECT Id, Asset__c, Change_Type__c FROM Asset_Change_Log__c WHERE Asset__c = :asset.Id AND Change_Type__c = 'Deleted'];
        System.assertEquals(0, logs.size());
    }
    
    
    @isTest
    static void testMetadataNotify() {
        
        AssetNotifier.assetCriteria = new List<Asset_Notification_Criteria__mdt>{
            new Asset_Notification_Criteria__mdt(
                Field_To_Validate__c = 'Last_Inspection_Date__c',
                Value_To_Validate__c = 'TODAY() - 30',
                Operator_To_Validate__c = '<',
                Event__c = 'AFTER DELETE',
                Object_Name__c = 'Asset__c',
                Notification_Title__c = 'Deleted Asset With Inspections',
                Notification_Body__c = 'Recently inspected asset deleted',
                NotificationTypeDevName__c = 'customnotification',
                Is_Active__c = true
            )
        };
    
        
        Asset__c testAsset = new Asset__c(Last_Inspection_Date__c = Date.today().addDays(-31));
    	Boolean shouldNotify = AssetNotifier.evaluate(testAsset, null);
    	System.assertEquals(true, shouldNotify);
    }
    
    //after undelete
    @isTest
    static void testAfterUnDelete() {
        Asset__c asset = new Asset__c(Name = 'Test1 Asset', Category__c = 'IT');
        insert asset;
    
        Asset_Inspection__c inspection = new Asset_Inspection__c(
            Asset__c = asset.Id,
            Inspection_Date__c = Date.today().addYears(-2) 
        );
        insert inspection;
        
        delete asset; 
        undelete asset;

    
        List<Asset__c> undeletedAssets = [
            SELECT Id, Name, Category__c, Last_Inspection_Date__c, Next_Inspection_Date__c
            FROM Asset__c
            WHERE Id = :asset.Id ALL ROWS
        ];
    
        Test.startTest();
            AssetLogger.logChange(undeletedAssets, 'Undeleted', null);
        Test.stopTest();
    
        List<Asset_Change_Log__c> logs = [
            SELECT Id, Asset__c, Change_Type__c
            FROM Asset_Change_Log__c
            WHERE Asset__c = :asset.Id AND Change_Type__c = 'Undeleted'
        ];
        System.assertEquals(2, logs.size());
    }

    
    
    @isTest
    static void testAfterMetadataNotify() {
        
        AssetNotifier.assetCriteria = new List<Asset_Notification_Criteria__mdt>{
            new Asset_Notification_Criteria__mdt(
                Field_To_Validate__c = 'Next_Inspection_Date__c',
                Value_To_Validate__c = 'TODAY()',
                Operator_To_Validate__c = '>',
                Event__c = 'AFTER UNDELETE',
                Object_Name__c = 'Asset__c',
                Notification_Title__c = 'Upcoming Asset Inspection',
                Notification_Body__c = 'Upcoming Asset Inspection',
                NotificationTypeDevName__c = 'customnotification',
                Is_Active__c = true
            )
        };
    
        Asset__c testAsset = new Asset__c(
            Next_Inspection_Date__c = Date.today().addDays(2)
        );
    
        Boolean shouldNotify = AssetNotifier.evaluate(testAsset, null);
        System.assertEquals(true, shouldNotify, 'Expected evaluation to return true');
    }
    

    
    

}