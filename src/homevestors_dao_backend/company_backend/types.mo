import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Time "mo:base/Time";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
//import Hash "mo:base/Hash";

module {
    public type Result<A,B> = Result.Result<A,B>;
    public type HashMap<Ok,Err> = HashMap.HashMap<Ok,Err>;

    public type Company = {
        companyId : Nat;
        name : Text; 
        utr : Text;
        initialAssets : InitialAssets; 
        currentAssets : Assets;
        nft : CompanyNFTs;
        dao : CompanyDAO; 
        property : Property;
    };

    public type InitialAssets = {
        initialValue : Float;
        originalTreasury : Float;
        propertyPurchasePrice : Nat;
        airdroppedHVD : Float;
        totalInvested : Float;
    };

    public type Assets = {
        currentValue : Float;
        propertyValuation : Float; 
        propertyValuationLow : Float;
        propertyValuationHigh: Float;
        stakedHVD : Float;
        liquidHVD : Float;
        stakedValue: Float;
        liquidValue : Float;
        treasury : Float;
    };


    public type CompanyNFTs = {
        canisterLgNFT : Principal; 
        lgNFTs : Nat; 
        eachLgOwn : Int; 
        canisterSmNFT : Principal;
        smNFTs : Nat; 
        eachSmOwn : Int; 
    };

    public type CompanyDAO = {
        daoCanister : Principal; 
        assetCanister : Principal;
    };

    public type Property = {
        address : PropertyAddress;
        financials: PropertyFinancials;
        tenants: PropertyTenants;
        description : PropertyDescription; 
        market : PropertyMarket;
        titleDeeds : Text; //URL to onchain file
        uprn : Nat64;
    };

    public type PropertyAddress = {
        name : Text;
        addressLine1 : Text;
        addressLine2 : Text;
        addressLine3 : Text;
        county : Text;
        outcode : Text;
        postcode : Text;
    };

    public type PropertyFinancials = {
        purchasePrice : Nat; 
        monthlyRent : Nat;
        projectedRent : Nat;
        yield : Int; 
        mortgage: PropertyMortgage;
    };

     public type PropertyMortgage = {
        company : Text; 
        apr : Int;
        monthlyAmount : Float;
        annualAmount : Float; 
        fixedRate : Bool;
        fixedDuration : Nat;
        fixedUntil : Time.Time; 
        mortgageTerm: Nat; 
        mortgageEnd : Time.Time;
        docs: [Text];
    };

    public type PropertyTenants = {
        occupied : Bool;
        name : ?Text;
        phone : ? Nat;
        email : ? Text;
        tenancyStarted : ?Time.Time;
        rentalAmount : Float; 
        enquiries : [Text];
    };




    public type PropertyDescription = {
        description : Text;
        beds : Nat;
        baths : Nat;
        propertyAge : Nat; 
        yearBuilt : Nat; 
        lastRenovation: Nat;
        sqFootage : Nat;
        pricePerSquareFoot : Nat;
        images : [Text];
    };

    public type PropertyMarket = {
        marketDescription : Text;
        averageStreetValue : Nat;
        averagePricePerSqFtonStreet : Nat;
        averageRentForOutcode: Nat;
        averageYield : Int;
        affordability : Nat;
        floodZone : Bool;
        schoolScore : Nat;
    };

  

}