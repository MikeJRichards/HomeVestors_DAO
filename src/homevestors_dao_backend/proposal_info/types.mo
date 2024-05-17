import Proposal "./../proposals_backend/types";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";

module {
    public type Result<A,B> = Result.Result<A,B>;
    public type HashMap<Ok,Err> = HashMap.HashMap<Ok,Err>;
    public type Proposal = Proposal.Proposal;

    public type ProposalInfo = {
        companyId : Nat;
        acceptedProposals : [Proposal];
        rejectedProposals : [Proposal];
        openProposals : [Proposal];
        draftProposals : [Proposal];
        totals : ProposalTotals;
        averageVoterParticipation : Float;
    };

    public type ProposalTotals = {
        draft : Nat;
        open : Nat; 
        accepted : Nat;
        rejected : Nat;
};

}