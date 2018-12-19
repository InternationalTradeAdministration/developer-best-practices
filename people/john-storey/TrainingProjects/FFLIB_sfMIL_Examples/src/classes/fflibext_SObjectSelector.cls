public abstract class fflibext_SObjectSelector
    extends fflib_SObjectSelector
{
    private static Map<SObjectType, Set<String>> standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap = new Map<SObjectType, Set<String>>();

    static
    {
        // Put the fields in as strings and not SObjectFields because sometimes you want to exclude
        //  a field that is only present in certain orgs.  Account.OperatinHoursId and Account.NameLocal
        //  are two such fields.
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.put( User.SObjectType, new Set<string>() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( User.SObjectType).add( 'SmallBannerPhotoUrl'.toLowerCase() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( User.SObjectType).add( 'MediumBannerPhotoUrl'.toLowerCase() );

        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.put( Account.SObjectType, new Set<string>() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( Account.SObjectType).add( 'OperatingHoursId'.toLowerCase() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( Account.SObjectType).add('NameLocal'.toLowerCase() );
    }

    private List<Schema.FieldSet> sObjectFieldSetList = null;

    public fflibext_SObjectSelector()
    {
        super(true);
        incorporateAdditionalSObjectFields();
    }

    public fflibext_SObjectSelector(Boolean includeFieldSetFields)
    {
        super( includeFieldSetFields );
        incorporateAdditionalSObjectFields();
    }
    
    public fflibext_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS)
    {
        super( includeFieldSetFields, enforceCRUD, enforceFLS );
        incorporateAdditionalSObjectFields();
    }

    public fflibext_SObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS, Boolean sortSelectFields)
    {
        super( includeFieldSetFields, enforceCRUD, enforceFLS, sortSelectFields );
        system.debug( 'includeFieldSetFields == ' + includeFieldSetFields);
        incorporateAdditionalSObjectFields();
    }

    private void incorporateAdditionalSObjectFields()
    {
        List<ApplicationFactory_SelectorFieldset__mdt> fieldsetsToIncludeList =
        [
            select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SObjectType__c, IsActive__c
            from ApplicationFactory_SelectorFieldset__mdt
            where IsActive__c = true and SObjectType__c = :this.getSObjectType().getDescribe().getName()
        ];

        Map<String, Schema.FieldSet> fieldSetMap = null;

        for (ApplicationFactory_SelectorFieldset__mdt customMetadataRecord : fieldsetsToIncludeList)
        {
            if ( getSObjectType().getDescribe().getName().equalsIgnoreCase( customMetadataRecord.SObjectType__c ) )
            {
                this.sObjectFieldSetList = new List<Schema.FieldSet>();

                fieldSetMap = getSObjectType().getDescribe().fieldSets.getMap();
                
                if ( fieldSetMap.containsKey( customMetadataRecord.QualifiedApiName.toLowerCase() ) )
                {
                    this.sObjectFieldSetList.add( fieldSetMap.get( customMetadataRecord.QualifiedApiName ) );
                }
                else 
                {
                    System.debug(LoggingLevel.ERROR, 'ApplicationFactory_SelectorFieldset__mdt record ' + customMetadataRecord.QualifiedApiName + ' specifies field set of ' + customMetadataRecord.QualifiedApiName + ' which was not found.');
                }
            }
            else 
            {
                System.debug(LoggingLevel.ERROR, 'ApplicationFactory_SelectorFieldset__mdt record ' + customMetadataRecord.QualifiedApiName + ' specifies SObjectType__c of ' + customMetadataRecord.SObjectType__c + ' which was not found.');
            }
        }
    }

    public override virtual List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return this.sObjectFieldSetList;
    }

    abstract Schema.SObjectType getSObjectType();

    abstract List<Schema.SObjectField> getAdditionalSObjectFieldList();

    public virtual List<Schema.SObjectField> getSObjectFieldList()
    {
        List<Schema.SObjectField> workingFieldList = new List<Schema.SObjectField>();
        workingFieldList.addAll( getStandardFields() );
        workingFieldList.addAll( getAdditionalSObjectFieldList() );
        return workingFieldList;
    }

    private List<Schema.SObjectField> getStandardFields()
    {
        List<Schema.SObjectField> standardFields = new List<Schema.SObjectField>();

        for (Schema.SObjectField field : getSObjectType().getDescribe().fields.getMap().values())
        {
            if
            (
                string.valueOf( field ).startsWith('INVALID FIELD') || 
                (
                    standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.containsKey( getSObjectType() ) && 
                    standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get(getSObjectType()).contains(String.valueOf( field ).toLowerCase())
                )
            )
            {
                system.debug(LoggingLevel.FINEST, 'field : ' + field + ' ignored');
                continue;
            }

            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (!fieldDescribe.isCustom())
            {
                standardFields.add(field);
                system.debug(LoggingLevel.FINEST, 'field : ' + field + ' added');
            }
            else
            {
                system.debug(LoggingLevel.FINEST, 'field : ' + field + ' ignored');
            }
        }
        return standardFields;
    }

    public fflibext_SObjectSelector addQueryFactoryParentSelect(fflib_QueryFactory parentQueryFactory, Schema.SObjectField relationshipField)
    {
        this.configureQueryFactoryFields( parentQueryFactory, relationshipField.getDescribe().getRelationshipName());
        return this;
    }

    public String selectSObjectsByIdQuery()
    {
        return newQueryFactory().setCondition('id in :idSet').toSOQL();
    }
}