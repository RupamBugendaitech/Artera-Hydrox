public with sharing class TruckAvailabiltyCtrl {

    @AuraEnabled(cacheable = true)
    public static List<Artera_Region__c> getRegionList(){
        try {
            List<Artera_Region__c> region = new List <Artera_Region__c> ();
            region = [select Id, Name from Artera_Region__c ];
            region.sort();
            return region;
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }


    @AuraEnabled(cacheable = true)
    public static String getAllAsset(){
        try {
            List<resWraCls> resWrapper = new List<resWraCls>();
            Date today    = Date.today();
            Date tomorrow = today.addDays(1);     
            String bgColor;
            String title;
            String retString;
            List<Asset__c> resList = [SELECT Id,Name,Region__r.Name,(SELECT Id,Name FROM Jobs__r WHERE Job_Date__c=:tomorrow) FROM Asset__c];

            for(Asset__c obj : resList ){

                if(obj.Jobs__r.size()==0){
                    bgColor = 'slds-badge cus-font';title  = 'Available'; 
                }else if(obj.Jobs__r.size()>0 &&  obj.Jobs__r.size()<2){
                    bgColor = 'slds-badge slds-theme_success';title  = 'Scheduled';
                }else if(obj.Jobs__r.size()>=2){
                    bgColor = 'slds-badge slds-theme_error';title  = 'Scheduled';
                } 
                resWrapper.add(new resWraCls(obj.Name, obj.Region__r.Name, title, bgColor));
            }

            if(!resWrapper.isEmpty()){
                retString =  JSON.serialize(resWrapper);
            }
            return retString;
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled(cacheable = true)
    public static String getAllAssetsByFilters(String resource,Date fDate,List<String> fRegion){
        try {
            List<resWraCls> resWrapper = new List<resWraCls>();
            Date today    = Date.today();
            Date tomorrow = today.addDays(1);   
            String bgColor;
            String title;
            String retString;
            String filter = '%' + resource + '%';   
            List<Asset__c> extQuery;             
            String fetchQuery = 'SELECT Id,Name,Region__r.Name, (SELECT Id,Name FROM Jobs__r ';

            if(fDate!= null){
                fetchQuery +=' WHERE Job_Date__c=:fDate) ';
            }else{
                fetchQuery +=' WHERE Job_Date__c=:tomorrow) ';
            }   

            fetchQuery += ' FROM Asset__c  ';

            if(resource != null || !fRegion.isEmpty()){
                fetchQuery += ' WHERE ';
            }

            if(resource != null){
                fetchQuery += ' Name LIKE :filter ';
            }

            if(!fRegion.isEmpty()){
                if(resource == null){
                    fetchQuery += ' Region__c IN : fRegion  ';
                }else{
                    fetchQuery += ' AND Region__c IN : fRegion  ';
                }
                
            }

 
            system.debug('queryy '+fetchQuery);
            
            for(Asset__c obj : Database.query(fetchQuery) ){
                if(obj.Jobs__r.size()==0){
                    bgColor = 'slds-badge cus-font'; title  = 'Available';
                }else if(obj.Jobs__r.size()==1){
                    bgColor = 'slds-badge slds-theme_success'; title  = 'Scheduled';
                }else if(obj.Jobs__r.size()>=2){
                    bgColor = 'slds-badge slds-theme_error';
                    title  = 'Scheduled';
                } 
                resWrapper.add(new resWraCls(obj.Name, obj.Region__r.Name, title, bgColor));
            }

            if(!resWrapper.isEmpty()){
                retString =  JSON.serialize(resWrapper);
            }
             
            
            return retString;
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }
 
    
    public class resWraCls{ 
        public String Name;
        public String Region;
        public String Title;
        public String BgColor; 

        public resWraCls(String Name, String Region, String Title, String BgColor){
        
            this.Name = Name;
            this.Region = Region;
            this.Title = Title;
            this.BgColor = BgColor;    
                
        }
    }
}