import ProposalInfoTypes "./types";
import ProposalTypes "./../proposals_backend/types";
import CompanyTypes "./../company_backend/types";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Float "mo:base/Float";

actor {
    public type HashMap<K,V> = ProposalInfoTypes.HashMap<K,V>;
    public type Result<Ok,Err> = ProposalInfoTypes.Result<Ok,Err>;
    public type Proposal = ProposalTypes.Proposal;
    public type ProposalStatus = ProposalTypes.ProposalStatus;
    public type ProposalInfo = ProposalInfoTypes.ProposalInfo;
    public type ProposalTotals = ProposalInfoTypes.ProposalTotals;
    public type Company = CompanyTypes.Company;
    
    let proposal_backend : actor {
		getCompanyProposals : shared (companyId : Nat) -> async [Proposal]; 
	} = actor ("bd3sg-teaaa-aaaaa-qaaba-cai"); 

    let company_backend : actor {
       getCompanyOnly : shared (companyId : Nat) -> async ? Company;
    } = actor ("bd3sg-teaaa-aaaaa-qaaba-cai");
     
    let proposalinfos = HashMap.HashMap<Nat, ProposalInfo>(0,Nat.equal, Hash.hash);

    public func createProposalInfo (companyId : Nat): async Result<(), Text> {
        switch(await company_backend.getCompanyOnly(companyId)){
            case(null){
                return #err("There is no company with that id");
            };
            case(_){
                let totals : ProposalTotals = {
                    draft = 0;
                    open = 0;
                    accepted = 0;
                    rejected = 0;
                };
                let newProposalInfo : ProposalInfo = {
                    companyId;
                    acceptedProposals = [];
                    rejectedProposals = [];
                    openProposals = [];
                    draftProposals = [];
                    totals;
                    averageVoterParticipation = 0.0;
                };
                proposalinfos.put(companyId, newProposalInfo);
                return #ok();
            };
        }
    };

    public func updateCompanyProposals (companyId : Nat): async () { 
        let array = await proposal_backend.getCompanyProposals(companyId);
        let allCompanyProposalsBuffer = Buffer.fromArray<Proposal>(array);

        let openProposalsBuffer = Buffer.mapFilter<Proposal, Proposal>(allCompanyProposalsBuffer, func (x) { if (x.status == #Open) { ?(x) } else { null }});
        let openProposals = Buffer.toArray(openProposalsBuffer);

        let draftProposalsBuffer = Buffer.mapFilter<Proposal, Proposal>(allCompanyProposalsBuffer, func (x) { if (x.status == #Draft) { ?(x) } else { null }});
        let draftProposals = Buffer.toArray(draftProposalsBuffer);
    
        let acceptedProposalsBuffer = Buffer.mapFilter<Proposal, Proposal>(allCompanyProposalsBuffer, func (x) { if (x.status == #Accepted) { ?(x) } else { null }});
        let acceptedProposals = Buffer.toArray(acceptedProposalsBuffer);
        var voterParticipation = 0.0;
        for(vals in acceptedProposals.vals()){
            voterParticipation += vals.voterParticipation;
        };

        let rejectedProposalsBuffer = Buffer.mapFilter<Proposal, Proposal>(allCompanyProposalsBuffer, func (x) { if (x.status == #Rejected) { ?(x) } else { null }});
        let rejectedProposals = Buffer.toArray(rejectedProposalsBuffer);
        for(vals in rejectedProposals.vals()){
            voterParticipation += vals.voterParticipation;
        };

        let totals : ProposalTotals = {
            draft = draftProposals.size();
            open = openProposals.size();
            accepted = acceptedProposals.size();
            rejected = rejectedProposals.size();
        };
        let newProposalInfo : ProposalInfo = {
            companyId;
            acceptedProposals;
            rejectedProposals;
            openProposals;
            draftProposals;
            totals;
            averageVoterParticipation = voterParticipation / Float.fromInt(totals.accepted + totals.rejected);
        };

        proposalinfos.put(companyId, newProposalInfo);
    };

    
}