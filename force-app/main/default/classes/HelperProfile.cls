/**
 * @description       : 
 * @author            : tom.h.ansley@medtronic.com
 * @last modified on  : 08-04-2021
 * @last modified by  : tom.h.ansley@medtronic.com
**/
public with sharing class HelperProfile {

    private static Map<String, Profile> profilesByName = null;
    private static Map<String, Profile> profilesById = null;

    public static Profile getProfile(String name)
    {
        Profile profile = null;
        
        if (profilesByName == null) 
        {
            getProfiles();
        }
        
        return profilesByName.get(name);
    }
    
    public static Profile getProfile(Id profId)// you should cast your argument as an Id so that the other method isn't called instead
    {
        Profile profile = null;
        
        if (profilesById == null) 
        {
            getProfiles();
        }

        return profilesById.get(profId);
    }
    
    private static void getProfiles()
    {
    	
    	profilesByName = new Map<String, Profile>();
        profilesById = new Map<String, Profile>();
    	
        List<Profile> profiles = new List<Profile>([SELECT Id, Name FROM Profile]);
                        			
		for (Profile prof: profiles)
        {
			profilesByName.put(prof.Name, prof);
        }
        
        for (Profile prof: profiles)
        {
			profilesById.put(prof.Id, prof);
        }
    }
}