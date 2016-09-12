public with sharing class DrawingsReceivedController {
    public static final Integer MIN_NUMBER_OF_EMPTY_ROWS = 3;

    private final Project_Profile__C project;
    public List<Drawings_Received__c> drawingsReceived { get { if( drawingsReceived == null ) drawingsReceived = new List<Drawings_Received__c>(); return drawingsReceived; } set; }

    public DrawingsReceivedController( ApexPages.StandardController controller ) {
        this.project = (Project_Profile__c)controller.getRecord();
        init();
    }

    public void init() {
        Integer drawingsNumberOnPage = getExistingDrawings();
        if( this.drawingsReceived.size() < drawingsNumberOnPage ) {
            addEmptyDrawings( drawingsNumberOnPage - this.drawingsReceived.size() );
        }
        if( this.drawingsReceived.size() < MIN_NUMBER_OF_EMPTY_ROWS ) {
            addEmptyDrawings( MIN_NUMBER_OF_EMPTY_ROWS - this.drawingsReceived.size() );
        }
    }

    public transient List<SelectOption> rosters;
    public List<SelectOption> getRosters() {
        List<SelectOption> availableRosters = new List<SelectOption>();
        availableRosters.add( new SelectOption( '', '--None--' ) );
        for( Project_Roster__c rosterItem : [ SELECT Contact__r.Name, Role__c, Active__c
                                              FROM Project_Roster__c
                                              WHERE Project_Profile__c = : this.project.Id
                                                AND Contact__c != null ] ) {
            availableRosters.add( new SelectOption( rosterItem.Id, rosterItem.Contact__r.Name + ' (' + rosterItem.Role__c + ')', !rosterItem.Active__c ) );
        }
        return availableRosters;
    }

    private Integer getExistingDrawings() {
        Integer drawingsNumberOnPage = this.drawingsReceived.size();
        this.drawingsReceived = [ SELECT Project_Profile__c, Work_Type__c, From__c, Date_Requested__c, Date_Received__c
                                  FROM Drawings_Received__c
                                  WHERE Project_Profile__c = : this.project.Id
                                  ORDER BY CreatedDate, Id ];
        return drawingsNumberOnPage;
    }

    public void addEmptyDrawing() {
        addEmptyDrawings(1);
    }

    private void addEmptyDrawings( Integer numberOfRows ) {
        for( Integer currentRow = 0; currentRow < numberOfRows; currentRow++ ) {
            this.drawingsReceived.add( new Drawings_Received__c( Project_Profile__c = this.project.Id ) );
        }
    }

    public void saveDrawingsReceived() {
        List<Drawings_Received__c> drawingsReceivedToUpsert = new List<Drawings_Received__c>();
        Set<Id> drawingsReceivedToDeleteIds = new Set<Id>();
        for( Drawings_Received__c drawingReceived : drawingsReceived ) {
            if( drawingReceived.Project_Profile__c != null &&
                ( !String.isEmpty( drawingReceived.Work_Type__c ) || !String.isEmpty( drawingReceived.From__c ) || drawingReceived.Date_Requested__c != null || drawingReceived.Date_Received__c != null ) ) {
                drawingsReceivedToUpsert.add( drawingReceived );
            } else {
                drawingsReceivedToDeleteIds.add( drawingReceived.Id );
            }
        }
        drawingsReceivedToDeleteIds.remove( null );
        try {
            if( !drawingsReceivedToUpsert.isEmpty() ) {
                UPSERT drawingsReceivedToUpsert;
            }
            if( !drawingsReceivedToDeleteIds.isEmpty() ) {
                List<Drawings_Received__c> drawingsReceivedToDelete = [ SELECT Id
                                                                        FROM Drawings_Received__c
                                                                        WHERE Id IN : drawingsReceivedToDeleteIds ];
                if( !drawingsReceivedToDelete.isEmpty() ) {
                    DELETE drawingsReceivedToDelete;
                }
            }
            init();
        } catch( Exception e ) {
            MilroseDevHelper.addMessage( 'Can not save drawings received: ' + e.getMessage() );
        }
    }

}