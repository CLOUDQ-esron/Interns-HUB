public class InventoryItemsTriggerHandler {
    Public static void beforeInsert(List<Inventory_Item__c> newITList){
        
        Map<Id, Vendor__c> mapOfVendor = InventoryItemsHelper.createMapOfVendors(newITList);
        Map<String,Inventory_Reorder_Config__mdt> mapOfMDT = InventoryItemsHelper.createMapOfInventoryReorderConfigmdt();
        for(Inventory_Item__c tempIT : newITList){
            if(tempIT.SKU__c != null && tempIT.Supplier__c !=null && tempIT.Stock_On_Hand__c != null){
                if(tempIT.Minimum_Threshold__c == null){
                    tempIT.Minimum_Threshold__c = mapOfMDT.get(tempIT.SKU__c).Reorder_If_Below__c;
                }
                tempIT.Next_Reorder_Date__c = Date.today().addDays(Integer.valueOf(mapOfVendor.get(tempIT.Supplier__c).Delivery_Lead_Time__c));
                if(tempIT.Stock_On_Hand__c == 0 && mapOfMDT.get(tempIT.SKU__c).Force_Freezing_If_Zero__c == true){
                    tempIT.Is_Frozen__c = true;
                }
            }
        }
    }
    Public static void afterInsert(List<Inventory_Item__c> newITList){
        for(Inventory_Item__c tempIT : newITList){
            if(tempIT.Stock_On_Hand__c < tempIT.Minimum_Threshold__c && tempIT.Auto_Reorder__c == true){
                InventoryItemsHelper.createProcurementRequest(tempIT, 'Inventory Items reorder Procurement request', 100);
                InventoryItemsQueueable notifyWarehouse = new InventoryItemsQueueable('Custom_Notification_for_Warehouse_Team', tempIT.Id, '005gK000001TXxhQAG');
                system.enqueueJob(notifyWarehouse);
            }
        }
    }
    
    Public static void beforeUpdate(List<Inventory_Item__c> newITList, Map<Id, Inventory_Item__c> oldMapofIT){
        for(Inventory_Item__c tempIT : newITList){
            if(tempIT.Stock_On_Hand__c < tempIT.Minimum_Threshold__c){
                tempIT.Auto_Reorder__c = true;
                if(tempIT.Stock_On_Hand__c <= 0){
                    tempIT.Is_Frozen__c = true;
                }
            }
            Boolean isOpenProcurements = InventoryItemsHelper.checkOpenProcurementResults(tempIT.Id);
            if(oldMapofIT.get(tempIT.Id).Supplier__c != tempIT.Supplier__c && isOpenProcurements == true){
                tempIT.addError('The Supplier cannot be changed when there are open Procurement Requests');
            }
        }
    }
    Public static void afterUpdate(List<Inventory_Item__c> newITList, Map<Id, Inventory_Item__c> oldMapofIT){
        Map<String,Inventory_Reorder_Config__mdt> mapOfMDT = InventoryItemsHelper.createMapOfInventoryReorderConfigmdt();
        List<Id> urgentITs = new List<Id>();
        for(Inventory_Item__c tempIT : newITList){
            if(oldMapofIT.get(tempIT.Id).Stock_On_Hand__c != tempIT.Stock_On_Hand__c && oldMapofIT.get(tempIT.Id).Stock_On_Hand__c != null && tempIT.Stock_On_Hand__c != null){
                InventoryItemsHelper.createStockAuditLog(tempIT.Id, oldMapofIT.get(tempIT.Id).Stock_On_Hand__c, tempIT.Stock_On_Hand__c, 'A simple log');
            }
            if(tempIT.Auto_Reorder__c == true && (tempIT.Stock_On_Hand__c < tempIT.Minimum_Threshold__c)){
                InventoryItemsHelper.createProcurementRequest(tempIT, 'Inventory stock has breached minimum threshold', 100);
            }
            if(tempIT.Stock_On_Hand__c < tempIT.Minimum_Threshold__c){
                urgentITs.add(tempIT.Id);
            }
        }
        InventoryItemsFuture.logUrgentInventoryItems(urgentITs);
    }
    Public static void beforeDelete(List<Inventory_Item__c> oldITList, Map<Id, Inventory_Item__c> oldMapofIT){
        Id UserId = UserInfo.getUserId();
        for(Inventory_Item__c tempIT : oldITList){
            Boolean isOpenProcurements = InventoryItemsHelper.checkOpenProcurementResults(tempIT.Id);
            Boolean userHasPermission = InventoryItemsHelper.getPermissionOfUser();
            if(isOpenProcurements == true){
                tempIT.addError('Inventory Item cannot be deleted when there are open Procurement Requests');
            }       
            if(tempIT.Is_Frozen__c == true){
                if(userHasPermission == false){
                    tempIT.addError('Frozen Inventory Items can only be deleted by the Inventory Manager');
                }
            }
        }
    }
    Public static void afterDelete(List<Inventory_Item__c> oldITList, Map<Id, Inventory_Item__c> oldMapofIT){
        for(Inventory_Item__c tempIT : oldITList){
            InventoryItemsHelper.createStockAuditLog(null, oldMapofIT.get(tempIT.Id).Stock_On_Hand__c, tempIT.Stock_On_Hand__c, 'Delete');
        }       
    }
    Public static void afterUndelete(List<Inventory_Item__c> newITList){
        
        List<Id> urgentITs = new List<Id>();
        for(Inventory_Item__c tempIT : newITList){
            if(tempIT.Auto_Reorder__c == true && (tempIT.Stock_On_Hand__c < tempIT.Minimum_Threshold__c)){
                InventoryItemsHelper.createProcurementRequest(tempIT, 'Inventory stock has breached minimum threshold', 100);
            }
            if(tempIT.Stock_On_Hand__c < tempIT.Minimum_Threshold__c){
                urgentITs.add(tempIT.Id);
            }
        }
        InventoryItemsFuture.logUrgentInventoryItems(urgentITs);       
    }
}