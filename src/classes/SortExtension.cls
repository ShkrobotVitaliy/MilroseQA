public without sharing class SortExtension {
    private String sortDirection = 'ASC';
    private String sortExp = '';
    public String sortExpression {
        get {
            return this.sortExp;
        }
        set {
          //if the column is clicked on then switch between Ascending and Descending modes
          if (value == this.sortExp) {
              this.sortDirection = (this.sortDirection == 'ASC')? 'DESC' : 'ASC';
          }
          else {
              this.sortDirection = 'ASC';
          }
          this.sortExp = value;
        }
    }

    public String getSortDirection() {
        //if not column is selected
        if (this.sortExpression == null || this.sortExpression == '') {
            return 'ASC';
        }
        else {
            return this.sortDirection;
        }
     }

    public void setSortDirection(String value) {
        this.sortDirection = value;
    }

    public sortExtension(String sortExp) {
        sortExpression = sortExp;
    }
}