public with sharing class FloorServices{
    public static final String  FLOOR_OBJECT_API_NAME = 'Floor__c';

    public static String FLOOR_TYPE_ATTIC = 'Attic';
    public static String FLOOR_TYPE_PENTHOUSE = 'Penthouse';
    public static String FLOOR_TYPE_ROOF = 'Roof';
    public static String FLOOR_TYPE_TOWER = 'Tower';
    public static String FLOOR_TYPE_BASEMENT = 'Basement';
    public static String FLOOR_TYPE_CELLAR = 'Cellar';
    public static String FLOOR_TYPE_LOBBY = 'Lobby';
    public static String FLOOR_TYPE_OPEN_SPACE = 'Open Space';
    public static String FLOOR_TYPE_MEZZANINE = 'Mezzanine';
    public static String FLOOR_TYPE_REGULAR_FLOOR = 'Regular Floor';
    public static String FLOOR_TYPE_REGULAR_TENANT_FLOOR = 'Regular Floor';
    public static String FLOOR_TYPE_BALCONY = 'Balcony';
    public static String FLOOR_TYPE_SUBCELLAR = 'Subcellar';
    public static String FLOOR_TYPE_FACADE = 'Façade';
    public static String FLOOR_TYPE_ENTIRE = 'Entire';
    public static String FLOOR_TYPE_OTHER = 'Other';
    public static String FLOOR_TYPE_OTHER_TENANT = 'Other';

    public static Map<String, String> specificationNamesMapFixed = new Map <String, String>{
                                                             FLOOR_TYPE_ATTIC => 'ATT',
                                                             FLOOR_TYPE_BALCONY => 'BAL',
                                                             FLOOR_TYPE_BASEMENT => 'BAS',
                                                             /*FLOOR_TYPE_CELLAR => 'CEL',*/ //MRS-4985
                                                             FLOOR_TYPE_LOBBY => 'LOB',
                                                             FLOOR_TYPE_OPEN_SPACE => 'OSP',
                                                             FLOOR_TYPE_ROOF => 'ROF',
                                                             FLOOR_TYPE_TOWER => 'TOW',
                                                             FLOOR_TYPE_FACADE => 'FAÇ',
                                                             FLOOR_TYPE_ENTIRE => 'ENT'
                                                          };

    public static Map<String, String> specificationNamesvariable = new Map <String, String>{
                                                            FLOOR_TYPE_MEZZANINE => 'MZ',
                                                            FLOOR_TYPE_PENTHOUSE => 'PT',
                                                            FLOOR_TYPE_CELLAR => 'C', //MRS-4985
                                                            FLOOR_TYPE_SUBCELLAR => 'SC',
                                                            FLOOR_TYPE_REGULAR_FLOOR => '',
                                                            FLOOR_TYPE_OTHER => '',
                                                            FLOOR_TYPE_OTHER_TENANT => '',
                                                            FLOOR_TYPE_REGULAR_TENANT_FLOOR => ''
    };

    public static Map<String, String> specificationNamesMezzaninePenthouse = new Map <String, String>{
        FLOOR_TYPE_MEZZANINE => 'MEZ',
        FLOOR_TYPE_PENTHOUSE => 'PEN',
        FLOOR_TYPE_CELLAR => 'C',
        FLOOR_TYPE_SUBCELLAR => 'SC'

    };

    public static Set<String> numericTypeFloors = new Set<String> { FLOOR_TYPE_PENTHOUSE };
    public static Set<String> requiredFloorNumberTypes = new Set<String> { FLOOR_TYPE_REGULAR_FLOOR,
                                                                           FLOOR_TYPE_OTHER };

    public static Set<String> requiredFloorNumberValue = new Set<String> { FLOOR_TYPE_OTHER };

    public static Set<String> notRequiredFloorNumberTypes = new Set<String> { FLOOR_TYPE_MEZZANINE,
                                                                              FLOOR_TYPE_PENTHOUSE,
                                                                              FLOOR_TYPE_CELLAR, //MRS-4985
                                                                              FLOOR_TYPE_SUBCELLAR };

    public static String getFullFloorName(String type, String floorNumber) {
        String fullName = '';

        if (null == type || String.isBlank(type)) {
            return fullName;

        }

        if (specificationNamesMapFixed.containsKey(type)) {
            fullName = specificationNamesMapFixed.get(type);

        }

        if (specificationNamesvariable.containsKey(type) && !String.isBlank(floorNumber) ) {
            if (requiredFloorNumberValue.contains(type)){
                return floorNumber;
            }
            fullName = '';
            final String floorType = specificationNamesvariable.get(type);
            List<String> charachterList = new List<String>();
            if( !String.isBlank( floorNumber ) ) {
                charachterList = floorNumber.splitByCharacterType();
            }

            for (String charItem : charachterList) {
                fullName += charItem.isNumeric() ? (floorType + charItem) : charItem;

            }

        }

        if (specificationNamesMezzaninePenthouse.containsKey(type) && String.isBlank(floorNumber) ) {
            fullName = specificationNamesMezzaninePenthouse.get(type);

        }

        return fullName;

    }

    public static Boolean floorContains( String floorType, Integer floorNumber, List<Floor__c> currentFloorsList ) {
        String allowedChars = '0123456789-,';
        for( Floor__c floorItem : currentFloorsList ) {
            if( floorItem.Floor_Type__c == floorType ) {
                String originalString = floorItem.Specification_Name__c;
                String filteredString = '';
                for( Integer charIndex = 0; charIndex < originalString.length(); charIndex++ ) {
                    String character = originalString.mid(charIndex, 1);
                    if ( character.containsOnly(allowedChars) ) filteredString += character;
                }
                List<String> floorsSplit = filteredString.split(',', 0);
                for( String floorSplitItem : floorsSplit ) {
                    if( floorSplitItem.countMatches('-') == 1 ) {
                        List<String> numbersRange = floorSplitItem.split('-', 0);
                        if( numbersRange[0].isNumeric() && numbersRange[1].isNumeric() &&
                            Integer.valueOf(numbersRange[0]) <= Integer.valueOf(numbersRange[0]) &&
                            floorNumber >= Integer.valueOf(numbersRange[0]) && floorNumber <= Integer.valueOf(numbersRange[1]) )
                                return true;
                    } else {
                        if( floorSplitItem.countMatches('-') == 0 ) {
                            if( floorSplitItem.isNumeric() && integer.valueOf(floorSplitItem) == floorNumber )
                                return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    public static Boolean isThereFloorWithType( String floorType, List<Floor__c> currentFloorsList ) {
        for( Floor__c floorItem : currentFloorsList ) {
            if( floorItem.Floor_Type__c == floorType ) return true;
        }
        return false;
    }

    public static List<Schema.PicklistEntry> floorOrder { get { if( floorOrder == null ) floorOrder = Floor__c.Floor_Type__c.getDescribe().getPicklistValues(); return floorOrder; } set; }
    public static List<FloorWrapper> sortFloorType(List<FloorWrapper> floorWrapperList) {
        map<Integer, String> floorMap = new map<Integer, String>();
        Integer i = 0;
        for( Schema.PicklistEntry item : floorOrder ) {
            floorMap.put(i, item.getValue());
            i++;
        }
        List<FloorWrapper> floorWrapperListNew = new List<FloorWrapper>();
        if(floorMap.size() > 0) {
            for(Integer j = 0; j <= floorMap.size()-1; j++) {
                for(FloorWrapper floorWrap: floorWrapperList) {
                    if(floorMap.get(j) == floorWrap.floorType)
                      if(floorWrapperListNew.size() >0) {
                        floorWrapperListNew.add(0, floorWrap);
                      } else {
                          floorWrapperListNew.add(floorWrap);
                      }
                }
            }
        } else {
            floorWrapperListNew = floorWrapperList;
        }
        return floorWrapperListNew;
    }

    public static String createFloorsString( List<FloorWrapper> floorModels, Boolean useIds ) {
        List<String> floorString = new List<String>();
        for( FloorWrapper floorModel: FloorServices.sortFloorType( floorModels ) ) {
            if( useIds ) {
                floorString.add( floorModel.floorId );
            } else {
                if( !String.isEmpty( floorModel.specificationName ) ) floorString.add( floorModel.specificationName );
            }
        }
        return floorString.isEmpty() ? '' : String.join( floorString, ',' );
    }

    public static String updateFloorsString( Id proposalId, Id projectProfileId, List<FloorWrapper> floorWrappers, Boolean isInsert ) {
        List<String> specificationNames = new List<String>();
        List<String> tenantFloorNames = new List<String>();
        String proposalDraftFloors = '';

        for (FloorWrapper floorWrapperItem : FloorServices.sortFloorType(floorWrappers) ) {
            if(String.isNotBlank(floorWrapperItem.specificationName) && floorWrapperItem.floorIsShown ) { // MRS 7109
            specificationNames.add(floorWrapperItem.specificationName);
            }

            if( String.isNotBlank(floorWrapperItem.specificationTenantName) && floorWrapperItem.floorIsShown ) { // MRS 7109
                tenantFloorNames.add(floorWrapperItem.specificationTenantName);
            }
        }
        String tenantFloorText = '';
        if(tenantFloorNames.size() > 0 ) {
            tenantFloorText = ' (Tenant Flr. ' + String.join(tenantFloorNames, ', ') + ')';
        }
        proposalDraftFloors  = String.join(specificationNames, ', ') + tenantFloorText;
        if( isInsert ) {
            try {
                if( !String.isBlank( proposalId ) ) {
                    Update new Proposal__c( Id = proposalId, Floor_s__c = proposalDraftFloors );
                }
                if( !String.isBlank( projectProfileId ) ) {
                    Update new Project_Profile__c( Id = projectProfileId, Floor_s__c = proposalDraftFloors );
                }
            } catch (DmlException e) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Failed to update floors on Proposal.' ) ) ;
            }
        }
        return proposalDraftFloors;
    }

    public static String getFloorsStringFromFloorServiceJunctions(Set<Id> setOfItems) { //G300 MRS-6827
        String res = '';
        Map<Id, Service_Floor_Junction__c> juncs = new Map<Id, Service_Floor_Junction__c>([SELECT id, floor__c
                                                    FROM Service_Floor_Junction__c

                                                    WHERE Service_Item__c IN: setOfItems]);
        if(juncs != null) {
            Set<id> junIds = new Set<Id>();
            for (Id tJunc : juncs.keySet()) {
                junIds.add(juncs.get(tJunc).floor__c);
            }

            List<Floor__c> floors = [SELECT Specification_Name__c FROM Floor__c WHERE id IN: junIds];
            if(floors != null) {
                for(Floor__c tFloor : floors) {
                    if(res.length()<1) res +='';
                    else res +=', ';
                    res += tFloor.Specification_Name__c;
                }
            }
        }

        return res;
    }

    public static List<Floor__c> floors;

    public static Map<Id, Floor__c> getRecordsByProposalId( Id proposalId ) {
        return new Map<Id, Floor__c>( getRecordsByProposalIdList( proposalId ) );
    }

    public static List<Floor__c> getRecordsByProposalIdList( Id proposalId ) {
        if( FloorServices.floors == null ) {
            FloorServices.floors = getFloorListByProposalId( proposalId );
        }
        return FloorServices.floors;
    }

    public static List<Floor__c> getFloorListByProposalId( Id proposalId ) {
        if( proposalId != null ) { // MRS 7109
            return [ SELECT Id, Floor_Type__c, Floor_Number__c, Specification_Name__c, Proposal__c, Tenant_Type__c, Tenant_Number__c, Specification_Tenant_Name__c, Floor_is_shown__c /* MRS 7109 */
                                         FROM Floor__c
                                         WHERE Proposal__c = : proposalId ];
        } else {
            return new List<Floor__c>();
        }
    }

}