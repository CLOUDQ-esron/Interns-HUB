/**
 * @description       : 
 * @author            : Esron R
 * @group             : 
 * @last modified on  : 27-06-2025
 * @last modified by  : Esron R
**/
public class Dummy {
    // Primitive Data Types
    public Integer intValue = 10;
    public Double doubleValue = 20.5;
    public Long longValue = 123456789L;
    public Decimal decimalValue = 99.99;
    public Boolean boolValue = true;
    public String stringValue = 'Apex String';
    public Date dateValue = Date.today();
    public Time timeValue = Time.now();
    public Datetime dateTimeValue = Datetime.now();
    public Id idValue = UserInfo.getUserId();
    public Blob blobValue = Blob.valueOf('Blob Example');

    // sObject
    public Account accountValue = new Account(Name='Test Account');

    // Collections
    public List<String> stringList = new List<String>{'A', 'B', 'C'};
    public Set<Integer> intSet = new Set<Integer>{1, 2, 3};
    public Map<String, Integer> stringIntMap = new Map<String, Integer>{'One'=>1, 'Two'=>2};


    // Object
    public Object objectValue = 'Generic Object';

    // Methods to demonstrate usage
    public void demoMethod() {
        System.debug(intValue);
        System.debug(doubleValue);
        System.debug(longValue);
        System.debug(decimalValue);
        System.debug(boolValue);
        System.debug(stringValue);
        System.debug(dateValue);
        System.debug(timeValue);
        System.debug(dateTimeValue);
        System.debug(idValue);
        System.debug(blobValue);
        System.debug(accountValue);
        System.debug(stringList);
        System.debug(intSet);
        System.debug(stringIntMap);
        System.debug(objectValue);
    }
}