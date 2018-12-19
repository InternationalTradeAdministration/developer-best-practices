public class core_Utils
{
    public enum TextCase {Lower, Upper}

    public class UtilsException extends Exception { }
    public class UtilsArgumentException extends Exception { }

    public static final Organization org;

    public static final BusinessHours defaultBusinessHours;

    static
    {
        org = [select Id, Name, Division, GeocodeAccuracy
                    , Phone, Fax, PrimaryContact, DefaultLocaleSidKey, LanguageLocaleKey
                    , ReceivesInfoEmails, ReceivesAdminInfoEmails, PreferencesRequireOpportunityProducts
                    , FiscalYearStartMonth, UsesStartDateAsFiscalYearName, DefaultAccountAccess
                    , DefaultContactAccess, DefaultOpportunityAccess, DefaultLeadAccess, DefaultCaseAccess
                    , DefaultCalendarAccess, DefaultPricebookAccess, DefaultCampaignAccess, ComplianceBccEmail
                    , UiSkin, SignupCountryIsoCode, TrialExpirationDate, OrganizationType, NamespacePrefix
                    , InstanceName, IsSandbox, WebToCaseDefaultOrigin, MonthlyPageViewsUsed, MonthlyPageViewsEntitlement
                    , IsReadOnly, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById
                 from Organization
                limit 1];

        defaultBusinessHours = [select Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime
                                     , MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime
                                     , WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime
                                     , FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime
                                     , TimeZoneSidKey, SystemModstamp, CreatedDate, CreatedById
                                     , LastModifiedDate, LastModifiedById
                                  from BusinessHours
                                 where IsDefault = true
                                   and IsActive = true
                                 limit 1];
    }

    @TestVisible
    private core_Utils() {}

    /**
     *
     */
    public static String clean ( final String input )
    {
        return String.isEmpty( input ) ? input : input.normalizeSpace();
    }

    public static String clean_DigitsOnly(final String value)
    {
        String v = clean(value);

        if (value == null || string.isEmpty(value))
        {
            return value;
        }

        return v.replaceAll('\\D', '');
    }

    public static Object convertValToDisplayType( Schema.DisplayType dt, String fieldValue )
    {
        if (dt == null)
        {
            throw new UtilsArgumentException('Call to mmlib_Utils.convertValToType(Schema.SoapType, string) cannot have a null parameter for SoapType');
        }

        if (Schema.DisplayType.Boolean == dt)
        {
            fieldValue = clean(fieldValue.toLowerCase());

            if ('true'.equalsIgnoreCase(fieldValue)
                || 't'.equalsIgnoreCase(fieldValue)
                || 'y'.equalsIgnoreCase(fieldValue)
                || '1'.equalsIgnoreCase(fieldValue))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else if (Schema.DisplayType.Date == dt)
        {
            return Date.valueOf( clean(fieldValue) );
        }
        else if (Schema.DisplayType.DateTime == dt)
        {
            return DateTime.valueOfGMT( clean(fieldValue).replace('T',' ').replace('z','') );
        }
        else if (Schema.DisplayType.Double == dt)
        {
            return Double.valueOf( clean(fieldValue) );
        }
        else if (Schema.DisplayType.Integer == dt)
        {
            return Integer.valueOf( clean(fieldValue) );
        }
        else if (Schema.DisplayType.Phone == dt)
        {
            return stripPhoneNumber( fieldValue );
        }

        return clean(fieldValue);
    }

    public static Object convertValToType(Schema.SoapType st, String fieldValue)
    {
        if (st == null)
        {
            throw new UtilsArgumentException('Call to mmlib_Utils.convertValToType(Schema.SoapType, string) cannot have a null parameter for SoapType');
        }

        if (Schema.SoapType.Boolean == st)
        {
            fieldValue = fieldValue.toLowerCase();

            if ('true'.equalsIgnoreCase(fieldValue)
                || 't'.equalsIgnoreCase(fieldValue)
                || 'y'.equalsIgnoreCase(fieldValue)
                || '1'.equalsIgnoreCase(fieldValue))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else if (Schema.SoapType.Date == st)
        {
            return Date.valueOf(fieldValue);
        }
        else if (Schema.SoapType.DateTime == st)
        {
            return DateTime.valueOfGMT(fieldValue.replace('T',' ').replace('z',''));
        }
        else if (Schema.SoapType.Double == st)
        {
            return Double.valueOf(fieldValue);
        }
        else if (Schema.SoapType.Integer == st)
        {
            return Integer.valueOf(fieldValue);
        }

        return fieldValue;
    }

    /**
     *  Method returns the child relationship name for an object.  Say you have two objects, Foo__c and Bar__c.  Bar__c
     *  is a "child" object of Foo and has a Lookup relationship to Foo__c.  The Lookup field on Bar__c is RelatedFoo__c.
     *  When that Lookup field is defined on the Bar__c object, it also defines the "child relationship" name that Foo__c
     *  will use in order to reference the child Bar__c records.  This method returns that relationship name.
     *
     *  @param Schema.SOBjectType parentSObject
     *  @param Schema.SOBjectType childSObject
     *  @param Schema.SOBjectField child SObject's Lookup Field to the parent SObject
     *  @return String value which is the child relationship name
     *
     *  @usage mmlib_Utils.findChildRelationshipName( Account.SObjectType, Contact.SObjectType, Contact.AccountId ) will return "Contacts".
     */
    public static String findChildRelationshipName( final Schema.SOBjectType parentSObject
                                                  , final Schema.SOBjectType childSObject
                                                  , final Schema.SOBjectField childLookupField )
    {
        String output = null;

        if ( parentSObject != null
            && childSObject != null
            && childLookupField != null)
        {
            for ( Schema.ChildRelationship cr : parentSObject.getDescribe().getChildRelationships() )
            {
                if ( childSObject == cr.getChildSObject()
                    && childLookupField == cr.getField()
                    )
                {
                    output = cr.getRelationshipName();
                    break;
                }
            }
        }

        return output;
    }

    public static String findPicklistLabelByValue(final Schema.SOBjectField picklistField, String value)
    {
        String output = null;

        if ( picklistField != null
            && String.isNotBlank( value )
            )
        {
            for ( Schema.PicklistEntry picklistEntry : picklistField.getDescribe().getPicklistValues() )
            {
                if ( value.equalsIgnoreCase( picklistEntry.getValue() ) )
                {
                    output = picklistEntry.getLabel();
                    break;
                }
            }
        }

        return output;
    }

    /**
     *  Given a format pattern "EEE, dd MMM yyyy HH:mm:ss Z"  i.e. "Sat, 06 May 2017 13:46:13 +0000"
     *  this method will return a Datetime object
     */
    public static Datetime formatDatetimeFromLongFormatString( final string longFormatString )
    {
        datetime output = null;

        try
        {
            string working = '';

            system.debug( 'longFormatString == >' + longFormatString + '<');

            // year component
            working += longFormatString.mid( 12, 4 );

            // month component
            string workingMonth = longFormatString.mid( 8, 3 ) ;

            if ( 'JAN'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-01';
            }
            else if ( 'FEB'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-02';
            }
            else if ( 'MAR'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-03';
            }
            else if ( 'APR'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-04';
            }
            else if ( 'MAY'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-05';
            }
            else if ( 'JUN'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-06';
            }
            else if ( 'JUL'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-07';
            }
            else if ( 'AUG'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-08';
            }
            else if ( 'SEP'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-09';
            }
            else if ( 'OCT'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-10';
            }
            else if ( 'NOV'.equalsIgnoreCase( workingMonth ) )
            {
                working += '-11';
            }
            else
            {
                working += '-12';
            }

            // day component
            working += '-' + longFormatString.mid( 5, 2 );

            // hour component
            working += ' ' + longFormatString.mid( 17, 2 );

            // minute component
            working += ':' + longFormatString.mid( 20, 2 );

            // second component
            working += ':' + longFormatString.mid( 23, 2 );

            system.debug( 'working datetime string = '+ working );

            output = datetime.valueOfGmt( working );

        }
        catch (Exception e)
        {
            system.debug( 'Unable to correctly parse longFormatString >'+longFormatString+'< -- exception: '+ e.getMessage());
        }

        return output;
    }

    public static String formatSoqlDatetimeUTC(Datetime userTimezoneDatetime)
    {
        String year = String.valueOf(userTimezoneDatetime.yearGmt());
        String month = String.valueOf(userTimezoneDatetime.monthGmt()).leftPad(2);
        String day = String.valueOf(userTimezoneDatetime.dayGmt()).leftPad(2);
        String hour = String.valueOf(userTimezoneDatetime.hourGmt()).leftPad(2);
        String minute = String.valueOf(userTimezoneDatetime.minuteGmt()).leftPad(2);
        String second = String.valueOf(userTimezoneDatetime.secondGmt()).leftPad(2);

        return (year+'-'+month+'-'+day+'T'+hour+':'+minute+':'+second+'Z').replace(' ', '0');
    }

    public static String formatSoqlDate(Date dateValue)
    {
        String year = String.valueOf(dateValue.year());
        String month = String.valueOf(dateValue.month()).leftPad(2);
        String day = String.valueOf(dateValue.day()).leftPad(2);

        return (year + '-' + month + '-' + day).replace(' ', '0');
    }

    public static String generateGuid()
    {
        return EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
    }

    public static map<Id, list<SObject>> generateSObjectMapByIdField( final List<SObject> sObjects
                                                                    , final Schema.SObjectField idFieldToBeKey)
    {
        if (idFieldToBeKey == null)
        {
            System.assertEquals(Schema.DisplayType.Id, idFieldToBeKey.getDescribe().getType());
        }

        map<Id, list<SObject>> outputMap = new map<Id, list<SObject>>();

        Id idValue = null;

        if (sObjects != null && ! sObjects.isEmpty())
        {
            for (SObject sobj : sObjects)
            {
                idValue = (Id)sobj.get(idFieldToBeKey);

                if ( ! outputMap.containsKey(idValue) )
                {
                    outputMap.put( idValue, new list<SObject>() );
                }

                outputMap.get( idValue ).add( sobj );
            }
        }

        return outputMap;
    }

    public static map<String, SObject> generateSObjectMapByUniqueField( final List<SObject> sObjects
                                                                      , final Schema.SObjectField stringFieldToBeKey)
    {
        map<String, SObject> outputMap = new map<String, SObject>();

        String stringValue = null;

        if (sObjects != null && ! sObjects.isEmpty())
        {
            for (SObject sobj : sObjects)
            {
                stringValue = (String)sobj.get(stringFieldToBeKey);

                if ( ! outputMap.containsKey( stringValue ) )
                {
                    outputMap.put( stringValue, sobj );
                }
            }
        }

        return outputMap;
    }

    public static Map<Id, SObject> generateOneToOneSObjectMapByIdField
    (
        final List<SObject> sObjects,
        final Schema.SObjectField identifierFieldToBeKey
    )
    {
        if (identifierFieldToBeKey == null)
        {
            System.assertEquals(Schema.DisplayType.Id, identifierFieldToBeKey.getDescribe().getType());
        }

        Map<Id, SObject> outputMap = new Map<Id, SObject>();

        if (sObjects != null && !sObjects.isEmpty())
        {
            for (SObject sobj : sObjects)
            {
                outputMap.put(
                        (Id)sobj.get(identifierFieldToBeKey),
                        sobj
                );
            }
        }

        return outputMap;
    }

    public static Set<Id> generateIdSetFromField( final List<SObject> sObjects
                                                , final Schema.SObjectField idFieldToBeKey)
    {
        return generateIdSetFromField( sObjects, idFieldToBeKey, false );
    }

    public static Set<Id> generateIdSetFromField( final List<SObject> sObjects
                                                , final Schema.SObjectField idFieldToBeKey
                                                , final boolean isBlankValueIncluded)
    {
        Set<Id> outputSet = new Set<Id>();
        Id idValue = null;

        if (sObjects != null && ! sObjects.isEmpty())
        {
            for (SObject sobj : sObjects)
            {
                idValue = (Id)sobj.get(idFieldToBeKey);
                if (idValue != null ||
                   (idValue == null && isBlankValueIncluded))
                {
                    outputSet.add( idValue );
                }
            }
        }

        return outputSet;
    }

    public static Set<String> generateStringSetFromField( final List<SObject> sObjects
                                                        , final Schema.SObjectField stringFieldToBeKey)
    {
        return generateStringSetFromField( sObjects, stringFieldToBeKey, false );
    }

    public static Set<String> generateStringSetFromField( final List<SObject> sObjects
                                                        , final Schema.SObjectField stringFieldToBeKey
                                                        , final boolean isBlankValueIncluded)
    {
        Set<String> outputSet = new Set<String>();
        String stringValue = null;

        if (sObjects != null && ! sObjects.isEmpty())
        {
            for (SObject sobj : sObjects)
            {
                stringValue = (String)sobj.get(stringFieldToBeKey);
                if (stringValue != null ||
                   (stringValue == null && isBlankValueIncluded))
                {
                    outputSet.add( stringValue );
                }
            }
        }

        return outputSet;
    }

    /**
     *  Method determines the Unix/Linux CronTab entry string that matches the supplied datetime.
     *  The Crontab format string represents time as
     *      Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
     *
     *  @param Datetime value
     *  @return String representation of the Datetime for use in a crontab operation.
     *
     *  @see System.Schedule( String, String, System.Schedulable )
     */
    public static String generateCronTabStringFromDatetime( final DateTime input)
    {
        String output = null;

        if ( input != null )
        {
            output = input.second() + ' '
                    + input.minute() + ' '
                    + input.hour() + ' '
                    + input.day() + ' '
                    + input.month() + ' '
                    + '? '
                    + input.year();
        }

        return output;
    }

    public static Boolean isValidAddress( Address addr )
    {
        // Data requirements: Street && State && Country && (City || Postal Code)
        return String.isNotEmpty(addr.getStreet())
                && String.isNotEmpty(addr.getState())
                && String.isNotEmpty(addr.getCountry())
                && ( String.isNotEmpty(addr.getCity())
                    || String.isNotEmpty(addr.getPostalCode())
                    );
    }

    /**
     *
     */
    public static String stripPhoneNumber( final String phoneNumber )
    {
        return String.isNotBlank(phoneNumber) ? clean( phoneNumber.replaceAll('[^0-9]', '') ) : '';
    }

    public static Boolean possiblyNullStringsAreEqual(String one, String two)
    {
        Boolean result = true;

        if (one != two)
        {
            result = false;
        }

        if (one != null && !one.equalsIgnoreCase(two))
        {
            result = false;
        }

        return result;
    }

    public static Boolean dateTimesMatchWithinNSeconds(DateTime one, DateTime two, Integer numberOfSeconds)
    {
        if (one == null || two == null || numberOfSeconds == null)
        {
            return false;
        }

        return Math.abs(one.millisecond() - two.millisecond()) <= numberOfSeconds * 1000;
    }

    public static List<SelectOption> getSelectOptionList(SObjectField field)
    {
        List<SelectOption> selectOptionList = new List<SelectOption>();

        if (field == null)
        {
            return selectOptionList;
        }

        DescribeFieldResult descr = field.getDescribe();

        if ( DisplayType.Picklist != descr.getType()
            && DisplayType.MultiPicklist != descr.getType() )
        {
            return selectOptionList;
        }

        for (PicklistEntry pe: descr.getPicklistValues())
        {
            if (pe.isActive())
            {
                selectOptionList.add(new SelectOption(pe.getLabel(), pe.getValue()));
            }
        }

        return selectOptionList;
    }

    public static SelectOption getBlankSelectOption()
    {
        return new SelectOption('', ''); // Label.mmlib_PICKLIST_EMPTY_SELECT_OPTION
    }

    public static list<SelectOption> getSelectOptions(List<SObject> objects)
    {
        return getSelectOptions(objects, false);
    }

    public static list<SelectOption> getSelectOptions(List<SObject> objects, boolean addBlank)
    {
        return getSelectOptions(objects, objects.getSobjectType().getDescribe().fields.getMap().get('Name'), addBlank);
    }

    public static list<SelectOption> getSelectOptions(List<SObject> objects, Schema.SObjectField fieldForLabel, boolean addBlank)
    {
        final list<SelectOption> options = new list<SelectOption>();

        if (addBlank)
        {
            options.add(getBlankSelectOption());
        }

        if (objects != null)
        {
            for (sObject obj : objects)
            {
                options.add(new SelectOption(obj.id, (string) obj.get( string.valueOf(fieldForLabel) )));
            }
        }

        return options;
    }

    public static list<SelectOption> getSelectOptions(list<Schema.RecordTypeInfo> recordTypes)
    {
        return getSelectOptions(recordTypes, false, false, true);
    }

    public static list<SelectOption> getSelectOptions( list<Schema.RecordTypeInfo> recordTypes
                                                     , boolean includeMasterType
                                                     , boolean includeOnlyIfCurrentUserHasAccess
                                                     , boolean addBlank)
    {
        final list<SelectOption> options = new list<SelectOption>();

        if (addBlank)
        {
            options.add(getBlankSelectOption());
        }

        if (recordTypes != null)
        {
            for(Schema.RecordTypeInfo recordType : recordTypes)
            {
                if ( (recordType.getName() != 'Master'
                        || ( recordType.getName() == 'Master'
                            && includeMasterType
                            )
                        )
                    && ( ! includeOnlyIfCurrentUserHasAccess
                        || (includeOnlyIfCurrentUserHasAccess && recordType.isAvailable()))
                    )
                {
                    options.add(new SelectOption(recordType.getRecordTypeId(), recordType.getName()));
                }
            }
        }

        return options;
    }

    public static List<String> forceToCase(List<String> valueList, TextCase convertToCase)
    {
        if (valueList == null || valueList.isEmpty())
        {
            return valueList;
        }

        List<String> resultList = new List<String>();

        for (String s : valueList)
        {
            if (TextCase.Lower == convertToCase)
            {
                resultList.add(s.toLowerCase());
            }

            if (TextCase.Upper == convertToCase)
            {
                resultList.add(s.toUpperCase());
            }
        }

        return resultList;
    }

    public static void convertToLowerCaseKeyMap(Map<String, Object> sourceMap, Map<String, Object> targetMap)
    {
        for (String k : sourceMap.keyset())
        {
            targetMap.put(k.toLowerCase(), sourceMap.get(k));
        }
    }
    public static List<String> extractFieldNamesFromFieldset(Fieldset fs)
    {
        List<String> result = new List<String>();
        
        if (fs == null)
        {
            return result;
        }

        for (FieldsetMember fsm : fs.getFields())
        {
            result.add(fsm.getFieldPath());
        }

        return result;
    }
}