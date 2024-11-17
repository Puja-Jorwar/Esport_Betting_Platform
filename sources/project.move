module EsportBetting::esports_bet {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;
    
    #[test_only]
    use aptos_framework::account;

    const ENO_BETTING_ACTIVE: u64 = 1;
    const EINVALID_TEAM: u64 = 2;

    struct BettingPool has key {
        total_bets: u64,
        team1_total: u64,
        team2_total: u64,
        bettors: vector<address>,
        bet_amounts: vector<u64>,
        bet_teams: vector<u8>,
        is_active: bool
    }

    public fun create_betting_pool(owner: &signer) {
        let pool = BettingPool {
            total_bets: 0,
            team1_total: 0,
            team2_total: 0,
            bettors: vector::empty(),
            bet_amounts: vector::empty(),
            bet_teams: vector::empty(),
            is_active: true
        };
        move_to(owner, pool);
    }

    public fun place_bet(
        bettor: &signer, 
        pool_owner: address, 
        amount: u64, 
        team: u8
    ) acquires BettingPool {
        let pool = borrow_global_mut<BettingPool>(pool_owner);
        assert!(pool.is_active, ENO_BETTING_ACTIVE);
        assert!(team == 1 || team == 2, EINVALID_TEAM);

        let bettor_addr = signer::address_of(bettor);
        let coins = coin::withdraw<AptosCoin>(bettor, amount);
        coin::deposit(pool_owner, coins);

        vector::push_back(&mut pool.bettors, bettor_addr);
        vector::push_back(&mut pool.bet_amounts, amount);
        vector::push_back(&mut pool.bet_teams, team);
        
        pool.total_bets = pool.total_bets + amount;
        if (team == 1) {
            pool.team1_total = pool.team1_total + amount;
        } else {
            pool.team2_total = pool.team2_total + amount;
        };
    }

    #[test]
    public fun test_create_betting_pool() {
        let owner = account::create_account_for_test(@betting_module);
        create_betting_pool(&owner);
        
        let pool = borrow_global<BettingPool>(@betting_module);
        assert!(pool.total_bets == 0, 0);
        assert!(pool.is_active == true, 1);
    }
}