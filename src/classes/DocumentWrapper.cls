public class DocumentWrapper{
    //public Document document {get;set;}
    public String documentId {get;set;}
    //public String documentName {get;set;}
    //public String documentDescription {get;set;}
    public Boolean isAttached {get;set;}

    public DocumentWrapper( Document document ) {
        this.documentId = document.Id;
        //this.documentName = document.Name;
        //this.documentDescription = document.Description;
    }
}