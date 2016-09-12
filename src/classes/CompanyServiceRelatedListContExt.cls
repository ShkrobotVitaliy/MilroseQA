public with sharing class CompanyServiceRelatedListContExt {

    public Boolean rerenderHightLowPrice {
        get {
            if(rerenderHightLowPrice == null) {
                /*Profile profile = UserServices.getProfile();
                rerenderHightLowPrice = true;
                if( profile.Name == UserServices.PROFILE_STAFF_ACCOUNTANT ||
                    profile.Name == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
                    profile.Name == UserServices.PROFILE_PARTNER ||
                    profile.Name == UserServices.PROFILE_ACCOUNT_MANAGER ||
                    profile.Name.contains( UserServices.PROFILE_PROJECT_MANAGER )
                   ) {
                    rerenderHightLowPrice = false;
                }*/
                rerenderHightLowPrice = false;
            }
            return rerenderHightLowPrice;
        }
        set;
    }

    public CompanyServiceRelatedListContExt(ApexPages.StandardController controller) {

    }

}