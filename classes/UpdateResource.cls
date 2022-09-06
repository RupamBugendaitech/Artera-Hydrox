global class UpdateResource implements Schedulable {
    global void execute(SchedulableContext sc){
        List<Artera_Resource__c> SobjLst = [select id,Home_WorkLocation__c,Artera_Region__c,Supervisor_Name__c from Artera_Resource__c ];
        List<Artera_Region__c> prodLst = [SELECT ID, Name FROM Artera_Region__c];
        List<User> UserLst = [SELECT ID,EmployeeNumber FROM User];
        Map<String,Id> discCode = new Map<String,Id>();
        Map<String,Id> UserCode = new Map<String,Id>();
        
        
        
        for (Artera_Region__c Ar: prodLst) {
            discCode.put(Ar.Name,Ar.Id);
        }
        for (User Us: UserLst) {
            UserCode.put(Us.EmployeeNumber,Us.Id);
        }
        
        
        
        
        for (Artera_Resource__c obj: SobjLst){
            obj.Artera_Region__c=discCode.get(obj.Home_WorkLocation__c);
            obj.Supervisor__c=UserCode.get(obj.Supervisor_Name__c);    
            
        }
        System.debug('Resource' +SobjLst);
        Update SobjLst;
        
    }
}