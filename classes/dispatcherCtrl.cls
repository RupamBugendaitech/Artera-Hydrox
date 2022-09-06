public with sharing class dispatcherCtrl {

   
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
        public static String getAllResources(){
            try {
                List<resWraCls> resWrapper = new List<resWraCls>();
                Date today    = Date.today();
                Date tomorrow = today.addDays(1);     
                String bgColor;
                String title;
                String retString;
                List<Artera_Resource__c> resList = [SELECT Id,Name,Artera_Region__r.Name, (SELECT Id,Name
                ,Type__c FROM Hydro_X_Job_Allocations__r WHERE Job_Assignment_Date_Field__c=:tomorrow)
                                                    FROM Artera_Resource__c
                                                    WHERE Worker_Status__c = 'Active' AND Job_Title__c LIKE 'CDL Operator%' ];
    
                for(Artera_Resource__c obj : resList ){
                    if(obj.Hydro_X_Job_Allocations__r.size()==0){
                        bgColor = 'slds-badge cus-font';title  = 'Available'; 
                    }else if(obj.Hydro_X_Job_Allocations__r.size()==1){
                        bgColor = 'slds-badge slds-theme_success';title  = 'Scheduled';
                    }else if(obj.Hydro_X_Job_Allocations__r.size()>=2){
                        bgColor = 'slds-badge slds-theme_error';title  = 'Scheduled';
                    } 
    
                    if(obj.Hydro_X_Job_Allocations__r.size() > 0){
    
                        for(Artera_Job_Allocation__c atAlloc : obj.Hydro_X_Job_Allocations__r){
                            if(atAlloc.Type__c=='Leave'){
                                bgColor = 'slds-badge slds-theme_error';
                                title  = 'Unavailable';
                            }
                        }
    
                    }
                    
                    resWrapper.add(new resWraCls(obj.Name, obj.Artera_Region__r.Name, title, bgColor));
                }
    
                if(!resWrapper.isEmpty()){
                    retString =  JSON.serialize(resWrapper);
                }
                return retString;
                
            } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
        }
    
        @AuraEnabled(cacheable = true)
        public static String getAllResourcesByFilters(String resource,Date fDate,  List<String> fRegion){
            try {
                List<resWraCls> resWrapper = new List<resWraCls>();
                Date today    = Date.today();
                Date tomorrow = today.addDays(1);    
                String bgColor;
                String title;
                String retString;
                String jobTitle = 'CDL Operator%';
                String jobTitleNon = 'Non-CDL%';
                String filter = '%' + resource + '%';   
                String status = 'Active';   
                List<Artera_Resource__c> extQuery; 
                
                system.debug('Res '+resource+' date '+fDate+' Region '+fRegion );
    
                String fetchQuery = 'SELECT Id,Name,Artera_Region__r.Name, (SELECT Id,Name,Type__c FROM Hydro_X_Job_Allocations__r ';
    
                if(fDate!= null ){
                    fetchQuery +=' WHERE Job_Assignment_Date_Field__c=:fDate) ';
                }else{
                    fetchQuery +=' WHERE Job_Assignment_Date_Field__c=:tomorrow) ';
                }   
    
                //fetchQuery += ' FROM Artera_Resource__c WHERE Worker_Status__c =:status AND (Job_Title__c LIKE :jobTitle OR Job_Title__c LIKE :jobTitleNon)';
                fetchQuery += ' FROM Artera_Resource__c WHERE Worker_Status__c =:status AND Job_Title__c LIKE :jobTitle ';
    
                if(!fRegion.isEmpty()){
                    fetchQuery += ' AND Artera_Region__c IN : fRegion ';
                }
    
                if(resource != null){
                    fetchQuery += ' AND Name LIKE :filter ';
                }
     
                system.debug('queryy '+fetchQuery);
                // if(String.isNotBlank(resource)){
                //         extQuery = [SELECT Id,Name,Artera_Region__r.Name, (SELECT Id,Name,Type__c FROM Hydro_X_Job_Allocations__r WHERE Job_Assignment_Date_Field__c=:tomorrow) FROM Artera_Resource__c WHERE  Name LIKE :filter AND Worker_Status__c = 'Active'];
                //     }else{
                //         extQuery = [SELECT Id,Name,Artera_Region__r.Name, (SELECT Id,Name,Type__c FROM Hydro_X_Job_Allocations__r WHERE Job_Assignment_Date_Field__c=:tomorrow) FROM Artera_Resource__c WHERE Worker_Status__c = 'Active'];
                //     }
                for(Artera_Resource__c obj : Database.query(fetchQuery) ){
                    if(obj.Hydro_X_Job_Allocations__r.size()==0){
                        bgColor = 'slds-badge cus-font'; title  = 'Available';
                    }else if(obj.Hydro_X_Job_Allocations__r.size()==1){
                        bgColor = 'slds-badge slds-theme_success'; title  = 'Scheduled';
                    }else if(obj.Hydro_X_Job_Allocations__r.size()>=2){
                        bgColor = 'slds-badge slds-theme_error';
                        title  = 'Scheduled';
                    } 
    
                    if(obj.Hydro_X_Job_Allocations__r.size() > 0){
    
                        for(Artera_Job_Allocation__c atAlloc : obj.Hydro_X_Job_Allocations__r){
                            if(atAlloc.Type__c=='Leave'){
                                bgColor = 'slds-badge slds-theme_error';title  = 'Unavailable';
                            }
                        }
    
                    }
    
    
                    resWrapper.add(new resWraCls(obj.Name, obj.Artera_Region__r.Name, title, bgColor));
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