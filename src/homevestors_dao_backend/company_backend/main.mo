import Types "./types";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Float "mo:base/Float";

actor{
    type Result <Ok, Err> = Types.Result<Ok,Err>;
    type Property = Types.Property;
    type Company = Types.Company;
    type InitialAssets = Types.InitialAssets;
    type Assets = Types.Assets;
    type CompanyNFTs = Types.CompanyNFTs;
    type CompanyDAO = Types.CompanyDAO;
    type PropertyAddress = Types.PropertyAddress;
    type PropertyFinancials = Types.PropertyFinancials;
    type PropertyMortgage = Types.PropertyMortgage;
    type PropertyTenants = Types.PropertyTenants;
    type PropertyMarket = Types.PropertyMarket; 
    type PropertyDescription = Types.PropertyDescription;
    
    var companyId : Nat = 0;
    let companies = HashMap.HashMap<Nat, Company>(0, Nat.equal, Hash.hash);
    var currentYear = 2024;

    public func changeCurrentYear (year:Nat): async (){
        currentYear := year;
    };

    func _createMortgage (company : Text, apr : Int, monthlyPayment : Float, fixed : Bool,  fixedDuration : Nat, mortgageTerm : Nat, docs : [Text]): PropertyMortgage{
        let mortgage : PropertyMortgage = {
            company;
            apr; 
            monthlyAmount = monthlyPayment; 
            annualAmount = monthlyPayment * 12; 
            fixedRate = fixed;
            fixedDuration;
            fixedUntil = Time.now();
            mortgageTerm;
            mortgageEnd = Time.now();
            docs; 
        };
        return mortgage;
    };

    func _createFinancials (purchasePrice : Nat, monthlyRent: Nat, mortgage : PropertyMortgage): PropertyFinancials {
        let financials : PropertyFinancials = {
            purchasePrice; 
            monthlyRent; 
            projectedRent = monthlyRent*12; 
            yield = monthlyRent*12/purchasePrice;
            mortgage;
        };
        return financials;
    };

    func _propertyAddress (propertyName : Text, addressLine1 : Text, addressLine2 : Text, addressLine3 : Text, county : Text, outcode : Text, postcode : Text): PropertyAddress {
        let address : PropertyAddress = {
            name = propertyName;
            addressLine1; 
            addressLine2; 
            addressLine3;
            county; 
            outcode;
            postcode;
        };
        return address;
    };

    func _propertyTenants (occupied : Bool, name : ? Text, phone : ? Nat, email : ? Text, tenancyStarted : ? Time.Time, rentalAmount : Float): PropertyTenants {
        let tenants : PropertyTenants = {
            occupied; 
            name = switch(name){case(null){null}; case(? val){?val}};
            phone = switch(phone){case(null){null}; case(? val){?val}};
            email = switch(email){case(null){null}; case(? val){?val}};
            tenancyStarted = switch(tenancyStarted){case(null){null}; case(? val){?val}}; 
            rentalAmount; 
            enquiries = [];
        };
        return tenants;
    };

    func _propertyMarket (marketDescription : Text, averageStreetValue : Nat, averagePricePerSqFtonStreet : Nat, averageRentForOutcode : Nat, averageYield : Int, affordability : Nat, floodZone : Bool, schoolScore: Nat): PropertyMarket{
        let propertyMarket : PropertyMarket = {
            marketDescription; 
            averageStreetValue; 
            averagePricePerSqFtonStreet; 
            averageRentForOutcode;
            averageYield;
            affordability; 
            floodZone; 
            schoolScore;
        };
        return propertyMarket;
    };

    func _propertyDescription (description: Text, beds : Nat, baths : Nat, yearBuilt : Nat, lastRenovation : Nat, sqFootage : Nat, pricePerSquareFoot : Nat, images : [Text]): PropertyDescription {
        let propertyDescription : PropertyDescription = {
            description; 
            beds;
            baths;
            propertyAge = currentYear - yearBuilt;
            yearBuilt;
            lastRenovation; 
            sqFootage; 
            pricePerSquareFoot; 
            images;
        };
        return propertyDescription;
    };

    func _createProperty (address : PropertyAddress, financials : PropertyFinancials, tenants : PropertyTenants, description : PropertyDescription, market : PropertyMarket, titleDeeds : Text, uprn : Nat64): Property {
    let property : Property = {
        address; 
        financials; 
        tenants;
        description;
        market;
        titleDeeds;
        uprn;
    };
    return property;
   };

   func _createCompanyDAO (daoCanister : Principal, assetCanister : Principal, snsIdentity : Nat, snsAccountPrincipal: Principal): CompanyDAO {
    let companyDAO : CompanyDAO = {
        daoCanister;
        assetCanister;
        snsIdentity;
        snsAccountPrincipal;
    };
    return companyDAO;
   };

   func _companyNFTs (canisterLgNFT : Principal, canisterSmNFT : Principal): CompanyNFTs {
    //This is incomplete - need to make intercanister calls to the nft canister to get this details
    let companyNFT : CompanyNFTs = {
        canisterLgNFT;
        lgNFTs = 0;
        eachLgOwn = 0; 
        canisterSmNFT;
        smNFTs = 0; 
        eachSmOwn = 0; 
    };
    return companyNFT;
   };

   func _currentAssets (propertyValuation : Float, propertyValuationLow : Float, propertyValuationHigh : Float): Assets {
    //This function is also incomplete - need to be able to make calls to asset canister to get balances and sns account as well
    let currentAssets : Assets = {
        currentValue = 0;
        propertyValuation;
        propertyValuationLow;
        propertyValuationHigh;
        stakedHVD = 0;
        liquidHVD = 0;
        stakedValue = 0;
        liquidValue = 0;
        treasury = 0;
    };
    return currentAssets;
   };

   func _initialAssets (initialValue : Float, originalTreasury : Float, propertyPurchasePrice : Nat, priceHVD : Float): InitialAssets {
    //in future plan to make priceHVD redundant through use of http outcalls - but requires price feed
    let initialAssets : InitialAssets = {
        initialValue; 
        originalTreasury;
        propertyPurchasePrice; 
        airdroppedHVD = originalTreasury / priceHVD;
        totalInvested = initialValue + originalTreasury; 
    };
    return initialAssets; 
   };

    public func createCompany (
        //Each functions parameters are on a new line 
    mortgageCompany : Text, apr : Int, monthlyPayment : Float, fixed : Bool,  fixedDuration : Nat, mortgageTerm : Nat, docs : [Text],
    purchasePrice : Nat, monthlyRent: Nat,
    propertyName : Text, addressLine1 : Text, addressLine2 : Text, addressLine3 : Text, county : Text, outcode : Text, postcode : Text,
    occurpied : Bool, name : ? Text, phone : ? Nat, email : ? Text, tenancyStarted : ? Time.Time, rentalAmount : Float,
    marketDescription : Text, averageStreetValue : Nat, averagePricePerSqFtonStreet : Nat, averageRentForOutcode : Nat, averageYield : Int, affordability : Nat, floodZone : Bool, schoolScore: Nat,
    descriptionText: Text, beds : Nat, baths : Nat, yearBuilt : Nat, lastRenovation : Nat, sqFootage : Nat, pricePerSquareFoot : Nat, images : [Text],
    titleDeeds : Text, uprn : Nat64,
    daoCanister : Principal, assetCanister : Principal, snsIdentity : Nat, snsAccountPrincipal: Principal,
    canisterLgNFT : Principal, canisterSmNFT : Principal,
    propertyValuation : Float, propertyValuationLow : Float, propertyValuationHigh : Float,
    initialValue : Float, originalTreasury : Float, propertyPurchasePrice : Nat, priceHVD : Float,
    companyName : Text, utr : Text
    ): async () {
        let mortgage : PropertyMortgage = _createMortgage(mortgageCompany, apr, monthlyPayment, fixed, fixedDuration, mortgageTerm, docs); 
        let financials : PropertyFinancials = _createFinancials(purchasePrice, monthlyRent, mortgage);
        let address : PropertyAddress = _propertyAddress(propertyName, addressLine1, addressLine2, addressLine3, county, outcode, postcode);
        let tenants : PropertyTenants = _propertyTenants(occurpied, name, phone, email, tenancyStarted, rentalAmount);
        let market : PropertyMarket = _propertyMarket(marketDescription, averageStreetValue, averagePricePerSqFtonStreet, averageRentForOutcode, averageYield, affordability, floodZone, schoolScore);
        let description : PropertyDescription = _propertyDescription(descriptionText, beds, baths, yearBuilt, lastRenovation, sqFootage, pricePerSquareFoot, images);
        let property : Property = _createProperty(address, financials, tenants, description, market, titleDeeds, uprn);
        let dao = _createCompanyDAO(daoCanister, assetCanister, snsIdentity, snsAccountPrincipal);
        let nft = _companyNFTs(canisterLgNFT, canisterSmNFT);
        let currentAssets = _currentAssets(propertyValuation, propertyValuationLow, propertyValuationHigh);//may want to include dao in this function when I can make balance calls
        let initialAssets = _initialAssets(initialValue, originalTreasury, propertyPurchasePrice, priceHVD);
        
        let company : Company = {
            companyId; 
            name = companyName;
            utr; 
            initialAssets;
            currentAssets;
            nft;
            dao; 
            property;
        };

        companies.put(companyId, company);
        companyId +=1;
        return;
    };

    public func getCompany (companyId : Nat): async Result<Company,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company);
            };
        };
    };
    
    public func getCompanyNFTs (companyId : Nat): async Result<CompanyNFTs,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.nft);
            };
        };
    };

    public func getCompanyDAO (companyId : Nat): async Result<CompanyDAO,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.dao);
            };
        };
    };

    public func getCompanyOnly (companyId : Nat): async  ? Company {
       return companies.get(companyId);
    };

    public func getCompanyInitialAssets (companyId : Nat): async Result<InitialAssets,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.initialAssets);
            };
        };
    };

    public func getCompanyAssets (companyId : Nat): async Result<Assets,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.currentAssets);
            };
        };
    };

    //Get property funcions
    public func getProperty (companyId : Nat): async Result<Property,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property);
            };
        };
    };

    public func getPropertyAddress (companyId : Nat): async Result<PropertyAddress,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property.address);
            };
        };
    };

    public func getPropertyMarket (companyId : Nat): async Result<PropertyMarket,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property.market);
            };
        };
    };

    public func getPropertyDescription (companyId : Nat): async Result<PropertyDescription,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property.description);
            };
        };
    };

    public func getPropertyTenants (companyId : Nat): async Result<PropertyTenants,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property.tenants);
            };
        };
    };

    public func getPropertyFinancials (companyId : Nat): async Result<PropertyFinancials,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property.financials);
            };
        };
    };

    public func getPropertyMortgage (companyId : Nat): async Result<PropertyMortgage,Text> {
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                return #ok(company.property.financials.mortgage);
            };
        };
    };

    //Update functions
    public func updateCompaniesCurrentAssets (companyId : Nat, priceHVD : Float): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //let dao = company.dao;
                let assets = company.currentAssets;
                //This will need to be a call to HVD token canister to get balance passing in ledger principal from company info
                let stakedHVD : Float= 10.0; //This will need to be an intercanister call to sns using principal
                let liquidHVD : Float = 10.0; //This will need to be an intercanister call to asset canister of company
                let treasury : Float = 10.0;//This will need to be an intercanister call to asset canister of company
                let stakedValue = Float.mul(stakedHVD, priceHVD); 
                let liquidValue = Float.mul(liquidHVD, priceHVD);
                let currentValue = stakedValue + liquidValue + treasury + assets.propertyValuation;
                
                let currentAssets = {
                    currentValue;
                    propertyValuation = assets.propertyValuation;
                    propertyValuationLow = assets.propertyValuationLow;
                    propertyValuationHigh = assets.propertyValuationHigh;
                    stakedHVD;
                    liquidHVD;
                    stakedValue;
                    liquidValue;
                    treasury;
                };

                let companyNew = {
                    companyId; 
                    name = company.name; 
                    utr = company.utr;
                    initialAssets = company.initialAssets;
                    currentAssets;
                    nft = company.nft;
                    dao = company.dao;
                    property = company.property;

                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };


    public func updatePropertyValue (companyId : Nat, propertyValuation : Float, propertyValuationLow : Float, propertyValuationHigh : Float): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let assets = company.currentAssets;
                let currentAssets = {
                    currentValue = assets.stakedValue + assets.liquidValue + assets.treasury + propertyValuation;
                    propertyValuation = propertyValuation;
                    propertyValuationLow = propertyValuationLow;
                    propertyValuationHigh = propertyValuationHigh;
                    stakedHVD = assets.stakedValue;
                    liquidHVD = assets.liquidHVD;
                    stakedValue = assets.stakedValue;
                    liquidValue = assets.liquidValue;
                    treasury = assets.treasury;
                };
                let companyNew = {
                    companyId; 
                    name = company.name; 
                    utr = company.utr;
                    initialAssets = company.initialAssets;
                    currentAssets;
                    nft = company.nft;
                    dao = company.dao;
                    property = company.property;

                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };

    public func updatePropertyTenants (companyId : Nat, tenants : PropertyTenants): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let property = company.property;
                let newProperty = {
                    address = property.address; 
                    financials = property.financials;
                    tenants; 
                    description = property.description; 
                    market = property.market; 
                    titleDeeds = property.titleDeeds; 
                    uprn = property.uprn;
                };
                
                let companyNew = {
                    companyId = company.companyId; 
                    name = company.name; 
                    utr = company.utr; 
                    initialAssets = company.initialAssets;
                    currentAssets = company.currentAssets;
                    nft = company.nft; 
                    dao = company.dao; 
                    property = newProperty;
                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };


    public func updatePropertyDescription (companyId : Nat, description : PropertyDescription): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let property = company.property;
                let newProperty = {
                    address = property.address; 
                    financials = property.financials;
                    tenants = property.tenants; 
                    description; 
                    market = property.market; 
                    titleDeeds = property.titleDeeds; 
                    uprn = property.uprn;
                };
                
                let companyNew = {
                    companyId = company.companyId; 
                    name = company.name; 
                    utr = company.utr; 
                    initialAssets = company.initialAssets;
                    currentAssets = company.currentAssets;
                    nft = company.nft; 
                    dao = company.dao; 
                    property = newProperty;
                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };


    public func updatePropertyFinancials (companyId : Nat, financials : PropertyFinancials): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let property = company.property;
                let newProperty = {
                    address = property.address; 
                    financials;
                    tenants = property.tenants; 
                    description = property.description; 
                    market = property.market; 
                    titleDeeds = property.titleDeeds; 
                    uprn = property.uprn;
                };
                
                let companyNew = {
                    companyId = company.companyId; 
                    name = company.name; 
                    utr = company.utr; 
                    initialAssets = company.initialAssets;
                    currentAssets = company.currentAssets;
                    nft = company.nft; 
                    dao = company.dao; 
                    property = newProperty;
                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };


    public func updatePropertyMortgage (companyId : Nat, mortgage : PropertyMortgage): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                let property = company.property;
                let finances = property.financials;

                let financials = {
                    purchasePrice = finances.purchasePrice;
                    monthlyRent = finances.monthlyRent;
                    projectedRent = finances.projectedRent;
                    yield = finances.yield;
                    mortgage;
                };

                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let newProperty = {
                    address = property.address; 
                    financials;
                    tenants = property.tenants; 
                    description = property.description; 
                    market = property.market; 
                    titleDeeds = property.titleDeeds; 
                    uprn = property.uprn;
                };
                
                let companyNew = {
                    companyId = company.companyId; 
                    name = company.name; 
                    utr = company.utr; 
                    initialAssets = company.initialAssets;
                    currentAssets = company.currentAssets;
                    nft = company.nft; 
                    dao = company.dao; 
                    property = newProperty;
                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };

    public func updatePropertyMarket (companyId : Nat, market : PropertyMarket): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let property = company.property;
                let newProperty = {
                    address = property.address; 
                    financials = property.financials;
                    tenants = property.tenants; 
                    description = property.description; 
                    market; 
                    titleDeeds = property.titleDeeds; 
                    uprn = property.uprn;
                };
                
                let companyNew = {
                    companyId = company.companyId; 
                    name = company.name; 
                    utr = company.utr; 
                    initialAssets = company.initialAssets;
                    currentAssets = company.currentAssets;
                    nft = company.nft; 
                    dao = company.dao; 
                    property = newProperty;
                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };

    public func updateTitleDeeds (companyId : Nat, titleDeeds : Text): async Result <(),Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(? company){
                //This will need to be a call to HVD token canister to get balance passing in sns principal from company info
                let property = company.property;
                let newProperty = {
                    address = property.address; 
                    financials = property.financials;
                    tenants = property.tenants; 
                    description = property.description; 
                    market = property.market; 
                    titleDeeds; 
                    uprn = property.uprn;
                };
                
                let companyNew = {
                    companyId = company.companyId; 
                    name = company.name; 
                    utr = company.utr; 
                    initialAssets = company.initialAssets;
                    currentAssets = company.currentAssets;
                    nft = company.nft; 
                    dao = company.dao; 
                    property = newProperty;
                };
                companies.put(companyId, companyNew);
                return #ok();
            };
        };
    };

    public func getDaoCanisterId (companyId : Nat): async Result<Principal,Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("No company with that Id");
            };
            case (? company){
                return #ok(company.dao.daoCanister);
            };
        };
    };

    public func getAssetCanisterId (companyId : Nat): async Result<Principal,Text>{
        switch(companies.get(companyId)){
            case(null){
                return #err("No company with that Id");
            };
            case (? company){
                return #ok(company.dao.assetCanister);
            };
        };
    };

    public func deleteCompany (companyId : Nat) : async Result<(),Text> {
        switch(companies.remove(companyId)){
            case(null){
                return #err("There is no company with that ID");
            };
            case(_){
                return #ok();
            };
        };
    };
}; 
