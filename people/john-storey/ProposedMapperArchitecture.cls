public class adcvd_MapperFactory
{
    private Map<SObjectType, adcvd_ISObjectMapper> mapperMap = new Map<SObjectType, adcvd_ISObjectMapper>();

    public adcvd_ISObjectMapper getMap(SObjectType sobjType)
    {
        return mapperMap.get(sobjType);
    }

    public adcvd_ISObjectMapper getMap(SObjectType sobjType, Id sobjId)
    {

        return mapperMap.get(sobjType);
    }

    public adcvd_ISObjectMapper put(adcvd_ISObjectMapper instance)
    {
        mapperMap.put(instance.getSObjectType(), instance);
        return instance;
    }
}

public interface adcvd_ISObjectMapper
{
    
}

public abstract class adcvd_SObjectMapper implements adcvd_ISObjectMapper
{

	protected adcvd_ISObjectMapper instance = null;

	protected Map<Id, SObject> idToUnlockedSObjectMap = new Map<Id, SObject>();
	protected Map<Id, SObject> idToAllSObjectMap = new Map<Id, SObject>();

	protected adcvd_SObjectMapper() {}

	protected adcvd_SObjectMapper(Set<Id> idSet)
    {
		if (idToUnlockedPetitionMap.isEmpty())
        {
			for (SObject sobj : fflib_SObjectSelector.newInstance().selectById(idSet))
            {
				addPetToMap(sobj);
			}
		}
	}

	protected virtual static adcvd_ISObjectMapper getInstance()
    {
		if (instance == null)
        {
			Set<Id> idSet = new Set<Id>();
            for (Id sobjId : adcvd_MapperFactory.getMap(getSObject()).keySet())
            {
                idSet.addAll(adcvd_MapperFactory.getMap(getSObjectType(), sobjId).keyset());
            }
            instance = new adcvd_SObjectMapper(idSet);
            ADCVD_CaseMapper.mapperMap.put(getSObjectType(), instance);
		}

		return instance;
	}

    public abstract SObjectType getSObjectType()
    {
        // must be implemented
    }

	public virtual Map<Id, SObject> getMap()
    {
		return getMap(false);
	}

	public virtual Map<Id, SObject> getMap(Boolean includeLocked)
    {
		if (includeLocked)
			return idToAllPetitionMap;
        else
			return idToUnlockedPetitionMap;
	}

	public void add(SObject sobj)
    {
		if (!(Boolean)sobj.get('Locked__c'))
			idToUnlockedPetitionMap.put(p.Id, p);
        else
    		idToAllPetitionMap.put(p.id, p);
	}
}