pragma solidity 0.5.1;

contract CryptoParty
{
    struct Participant
    {
        uint num_coins; 
        uint rating_old; 
        uint rating_new;
        uint last_update_time;
        bool isValue; 
    }
    
    struct Node {
     address parent;   
     address wallet;
     uint start_time; 
     bool isValue;
    }
    
    mapping(address => Node) nodes;
    mapping(address => Participant) public wallet_to_participant; 
    uint total_coins; 
    
	function new_root(address _wallet) public {
		
		if(nodes[_wallet].isValue)
        {
            if(now - nodes[_wallet].start_time > 24 hours)
            {
                nodes[_wallet].parent = address(0);
                nodes[_wallet].wallet = _wallet;
                nodes[_wallet].start_time = now;
            }
			
			update(_wallet);
        }
        else
        {
            nodes[_wallet] = Node({
                parent: address(0), 
                wallet: _wallet, 
                start_time: now,
                isValue: true
            });
			
			wallet_to_participant[_wallet] = Participant(0, 0, 0, now, true);
        }
		
		
    }
	
    function add(address _parent, address _wallet) public {
    
        if(nodes[_wallet].isValue)
        {
            if(now - nodes[_wallet].start_time > 24 hours)
            {
                nodes[_wallet].parent = _parent;
                nodes[_wallet].wallet = _wallet;
                nodes[_wallet].start_time = now;
                
                update(_wallet);
                
                while(validate_parent(nodes[_wallet].parent))
                {
                    _wallet = nodes[_wallet].parent;
                    update(_wallet, true);
                }
            }
        }
        else
        {
            nodes[_wallet] = Node({
                parent: _parent, 
                wallet: _wallet, 
                start_time: now,
                isValue: true
            });
			
			wallet_to_participant[_wallet] = Participant(0, 0, 0, now, true);
        }
    }
    
    function validate_parent(address p_wallet) public view returns (bool)
    {
        if(!nodes[p_wallet].isValue)
            return false; 
            
          if(now - nodes[p_wallet].start_time > 24 hours)
            return false; 
            
        return true; 
    }
    
    function update(address wallet, bool add_rating = false) public
    {
        Participant storage p = wallet_to_participant[wallet];
        
        if(!p.isValue)
            return; 
        
        if(add_rating)
            p.rating_new++;
        
        if(now - p.last_update_time > 1 hours)
        {
            uint numh = uint((now - p.last_update_time) / (1 hours));
            p.num_coins += p.rating_old;
            p.num_coins += p.rating_new * (numh - 1);
            total_coins += p.rating_old + p.rating_new * (numh - 1);
            p.rating_old = p.rating_new;
            p.last_update_time = now; 
        }
        
        wallet_to_participant[wallet] = p; 
    }
    
    function transfer(address _from, address _to, uint amount) public
    {
        require(amount > 0);
        require(wallet_to_participant[_from].isValue);
        require(wallet_to_participant[_to].isValue);
        
        Participant storage p = wallet_to_participant[_from];
        require(p.num_coins >= amount);
        
        p.num_coins -= amount; 
        wallet_to_participant[_to].num_coins += amount; 
    }
    
}