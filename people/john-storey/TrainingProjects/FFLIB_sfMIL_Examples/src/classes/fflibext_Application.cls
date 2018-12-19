public class fflibext_Application
{
    public class fflibext_ApplicationException extends Exception { }

    @TestVisible
    private static List<SObjectType> unitOfWorkFactorySObjectTypeList;

    @TestVisible
    private static Map<Type, Type> serviceFactoryTypeMap;

    @TestVisible
    private static Map<SObjectType, Type> selectorFactoryTypeMap;

    @TestVisible
    private static Map<SObjectType, Type> domainFactoryTypeMap;

    static
    {
        Map<String, Schema.SObjectType> schemaGlobalDescribe = Schema.getGlobalDescribe();

        unitOfWorkFactorySObjectTypeList = new List<SObjectType>();

        serviceFactoryTypeMap = new Map<Type, Type>();

        selectorFactoryTypeMap = new Map<SObjectType, Type>();

        domainFactoryTypeMap = new Map<SObjectType, Type>();

        // ----- Selectors ---------
        List<ApplicationFactory_Selector__mdt> selectorConfigRecords =
        [
            select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SObjectType__c, SelectorClass__c 
            from ApplicationFactory_Selector__mdt
            order by SObjectType__c, DeveloperName
        ];

        for ( ApplicationFactory_Selector__mdt cr : selectorConfigRecords )
        {
            if ( schemaGlobalDescribe.containsKey( cr.SObjectType__c ) )
            {
                selectorFactoryTypeMap.put( schemaGlobalDescribe.get( cr.SObjectType__c ), Type.forName( cr.SelectorClass__c ) );
            }
            else
            {
                throw 
                    new fflibext_ApplicationException(
                        'Application Selector Factory configuration \'' + cr.DeveloperName + 
                        '\' specification of SObjectType ' + cr.SObjectType__c + 
                        ' was not found.  Please have the system administrator make adjustments.');
            }
        }

        // ----- Domains ----------
        List<ApplicationFactory_Domain__mdt> domainConfigRecords =
        [
            select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SObjectType__c, DomainClass__c 
            from ApplicationFactory_Domain__mdt
            order by SObjectType__c, DeveloperName
        ];

        for ( ApplicationFactory_Domain__mdt cr : domainConfigRecords )
        {
            if ( schemaGlobalDescribe.containsKey( cr.SObjectType__c ) )
            {
                domainFactoryTypeMap.put( schemaGlobalDescribe.get( cr.SObjectType__c ), Type.forName( cr.DomainClass__c ) );
            }
            else
            {
                throw 
                    new fflibext_ApplicationException(
                        'Application Domain Factory configuration \'' + cr.DeveloperName + 
                        '\' specification of SObjectType ' + cr.SObjectType__c + 
                        ' was not found.  Please have the system administrator make adjustments.');
            }
        }

        // ----- Services ----------
        List<ApplicationFactory_Service__mdt> serviceConfigRecords =
        [
            select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SObjectType__c, ServiceImplementationClass__c 
            from ApplicationFactory_Service__mdt
            order by SObjectType__c, DeveloperName
        ];

        for ( ApplicationFactory_Service__mdt cr : serviceConfigRecords )
        {
            serviceFactoryTypeMap.put( Type.forName( cr.SObjectType__c ), Type.forName( cr.ServiceImplementationClass__c ) );
        }

        // ----- Units of Work ----------
        List<ApplicationFactory_UnitOfWork__mdt> uowConfigRecords =
        [
            select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SObjectType__c 
            from ApplicationFactory_UnitOfWork__mdt
            order by SObjectType__c, DeveloperName
        ];

        for ( ApplicationFactory_UnitOfWork__mdt cr : uowConfigRecords )
        {
            if ( schemaGlobalDescribe.containsKey( cr.SObjectType__c ) )
            {
                unitOfWorkFactorySObjectTypeList.add( schemaGlobalDescribe.get( cr.SObjectType__c ) );
            }
            else
            {
                throw 
                    new fflibext_ApplicationException(
                        'Application Unit of Work Factory configuration \'' + cr.DeveloperName + 
                        '\' specification of SObjectType ' + cr.SObjectType__c + 
                        ' was not found.  Please have the system administrator make adjustments.');
            }
        }
    }

    public static final fflibext_Application.UnitOfWorkFactory UnitOfWork = new fflibext_Application.UnitOfWorkFactory(unitOfWorkFactorySObjectTypeList);

    public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory( serviceFactoryTypeMap );

    public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory( selectorFactoryTypeMap );

    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory( fflibext_Application.Selector, domainFactoryTypeMap );

    public class UnitOfWorkFactory
    {
        private List<SObjectType> m_objectTypes;

        private fflibext_ISObjectUnitOfWork m_mockUow;

        public UnitOfWorkFactory(List<SObjectType> objectTypes)
        {
            m_objectTypes = objectTypes.clone();
        }

        public fflibext_ISObjectUnitOfWork newInstance()
        {
            if(m_mockUow!=null)
                return m_mockUow;
            return new fflibext_SObjectUnitOfWork(m_objectTypes);
        }

        public fflibext_ISObjectUnitOfWork newInstance(fflib_SObjectUnitOfWork.IDML dml)
        {
            if(m_mockUow!=null)
                return m_mockUow;
            if ( dml == null )
            {
                throw new fflibext_ApplicationException('No fflib_SObjectUnitOfWork.IDML instance provided as parameter.');
            }
            return new fflibext_SObjectUnitOfWork(m_objectTypes, dml);
        }

        public fflibext_ISObjectUnitOfWork newInstance(List<SObjectType> objectTypes)
        {
            if(m_mockUow!=null)
                return m_mockUow;

            return new fflibext_SObjectUnitOfWork(m_objectTypes);
        }

        @TestVisible
        private void setMock(fflibext_ISObjectUnitOfWork mockUow)
        {
            m_mockUow = mockUow;
        }
    }
}