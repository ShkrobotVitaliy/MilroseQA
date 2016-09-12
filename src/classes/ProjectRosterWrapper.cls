public with sharing class ProjectRosterWrapper {
    public Contact contact {get;set;}
    public String name { get; set; }
    public String email {get;set;}
    public String role { get; set; }
    public Boolean isSelect { get; set; }

    public ProjectRosterWrapper(final String name, final String email) {
         this.name     = name;
         this.email    = email;
         this.isSelect = false;
    }

    public ProjectRosterWrapper(final String name, final String email, Contact contactRecord, final String role ) {
         this.name     = name;
         this.email    = email;
         this.role     = role;
         this.isSelect = false;
         this.contact = contactRecord;
    }
}