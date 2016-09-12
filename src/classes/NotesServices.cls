public without sharing class NotesServices {

	/**
     * Check if Note.Body has a datetime-user prefix.
     * If there is no - build it
     */
    private static String buildNotePrefix(Note noteitem) {
        if( noteItem.Body == null ) noteItem.body = '';
        Pattern patt = Pattern.compile('^(.+?\\s\\|\\s.+?\\:\n).*');
        Matcher m = patt.matcher(noteItem.body);
        return ( m.matches() ) ? '' : '<span style="font-weight: bold;">' + String.valueOf( noteItem.CreatedDate ) + ' |@| ' + noteItem.CreatedBy.Name + '</span>'+ ':\n';
    }

    public static Boolean filterAndSaveNotes( Id parentId, List<Note> notes, Note noteToAppend, String noteBody ) {
        List<Note> notesToUpsert = new List<Note>();
        /*List<Note> notesToDelete = new List<Note>();
        Note tempNote;
        for( Note noteItem : notes ) {
            if( noteItem.parentId != parentId ) {
                tempNote = noteItem.clone(false, true);
                tempNote.parentId = parentId;
                notesToUpsert.add(tempNote);
                notesToDelete.add(noteItem);
            }
        }*/

        noteToAppend.Body = ( null != noteBody ) ? noteBody : '' ;

        if( !String.isEmpty(noteToAppend.Body) ) {
            noteToAppend.parentId = parentId;
            noteToAppend.Title += ' #' + String.valueOf(notes.size()+1);
            notesToUpsert.add(noteToAppend);
        }
        try {
            UPSERT notesToUpsert;
            //DELETE notesToDelete;
        } catch( Exception e ) {
            return false;
        }
        return true;
    }

    public static List<Note> retrieveNotes( Id parentId ) {
    	return getNotesByParentIds( new Set<Id> { parentId }, true );
    }

    public static List<Note> retrieveNotes( Id parentId, Boolean doAdjustTimeZone ) {
        return getNotesByParentIds( new Set<Id> { parentId }, doAdjustTimeZone );
    }

    public static List<Note> getNotesByParentIds(Set<Id> parentIds, Boolean doAdjustTimeZone) {
    	List<Note> notes = new List<Note>();
        if ( parentIds != null && !parentIds.isEmpty() ) {
            notes = [ SELECT CreatedDate, CreatedBy.Name, CreatedById, Body, Id, Title, ParentId
                      FROM Note
                      WHERE ParentId IN : parentIds
                      ORDER BY CreatedDate, Title ];
        }
        if( doAdjustTimeZone ) {
            notes = adjustTimeZoneForNotes( notes );
        }
        return notes;
    }

    public static String joinNotes ( List<Note> notes ) {
        String totalNotesText = '';
        for( Note note: notes ) {
            totalNotesText += buildNotePrefix(note) + note.Body + '</br>';
        }
        return totalNotesText.unescapeHtml3();
    }

    public static List<Note> adjustTimeZoneForNotes ( List<Note> notes ) {
        //KDI: MRS-3888 Convert GMT to Organization Time Zone to display on Wizard
        for( Note noteItem : notes ) {
            if( !String.isBlank( noteItem.Body ) ) {
                Integer datePositionInNote = noteItem.Body.indexOf( ' |@| ' );
                if( datePositionInNote != -1 ) {
                    try {
                        String noteBody = String.valueOf( DateTime.valueOfGmt( noteItem.Body.substring( 0, datePositionInNote ) ) ) +
                                          noteItem.Body.substring( datePositionInNote );
                        noteItem.Body = noteBody;
                    } catch( Exception e ) {
                    }
                }
            }
        }
        return notes;
    }

}