// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface rarity {
    function level(uint256) external view returns (uint256);

    function class(uint256) external view returns (uint256);

    function getApproved(uint256) external view returns (address);

    function ownerOf(uint256) external view returns (address);
}

interface attributes {
    function character_created(uint256) external view returns (bool);

    function ability_scores(uint256)
        external
        view
        returns (
            uint32,
            uint32,
            uint32,
            uint32,
            uint32,
            uint32
        );
}

// parece que simula ser un erc-20
contract rarity_crafting_materials {
    string public constant name = "Rarity Crafting Materials (I)";
    string public constant symbol = "Craft (I)";
    uint8 public constant decimals = 18;

    // configuracion niveles de una dungeon
    int256 public constant dungeon_health = 10;
    int256 public constant dungeon_damage = 2;
    int256 public constant dungeon_to_hit = 3;
    int256 public constant dungeon_armor_class = 2;
    uint256 constant DAY = 1 days;

    // devuelve la salud segun clase
    function health_by_class(uint256 _class)
        public
        pure
        returns (uint256 health)
    {
        if (_class == 1) {
            health = 12;
        } else if (_class == 2) {
            health = 6;
        } else if (_class == 3) {
            health = 8;
        } else if (_class == 4) {
            health = 8;
        } else if (_class == 5) {
            health = 10;
        } else if (_class == 6) {
            health = 8;
        } else if (_class == 7) {
            health = 10;
        } else if (_class == 8) {
            health = 8;
        } else if (_class == 9) {
            health = 6;
        } else if (_class == 10) {
            health = 4;
        } else if (_class == 11) {
            health = 4;
        }
    }

    // calculo de la salud añadiendole el nivel y constitucion
    function health_by_class_and_level(
        uint256 _class,
        uint256 _level,
        uint32 _const
    ) public pure returns (uint256 health) {
        int256 _mod = modifier_for_attribute(_const);
        int256 _base_health = int256(health_by_class(_class)) + _mod;
        if (_base_health <= 0) {
            _base_health = 1;
        }
        health = uint256(_base_health) * _level;
    }

    // calculo de bonus de ataque segun clase
    function base_attack_bonus_by_class(uint256 _class)
        public
        pure
        returns (uint256 attack)
    {
        if (_class == 1) {
            attack = 4;
        } else if (_class == 2) {
            attack = 3;
        } else if (_class == 3) {
            attack = 3;
        } else if (_class == 4) {
            attack = 3;
        } else if (_class == 5) {
            attack = 4;
        } else if (_class == 6) {
            attack = 3;
        } else if (_class == 7) {
            attack = 4;
        } else if (_class == 8) {
            attack = 4;
        } else if (_class == 9) {
            attack = 3;
        } else if (_class == 10) {
            attack = 2;
        } else if (_class == 11) {
            attack = 2;
        }
    }

    // calculo de bonus de ataque añadiendole el nivel
    function base_attack_bonus_by_class_and_level(
        uint256 _class,
        uint256 _level
    ) public pure returns (uint256) {
        return (_level * base_attack_bonus_by_class(_class)) / 4;
    }

    // modificador segun nivel de atributo.
    function modifier_for_attribute(uint256 _attribute)
        public
        pure
        returns (int256 _modifier)
    {
        if (_attribute == 9) {
            return -1;
        }
        return (int256(_attribute) - 10) / 2;
    }

    // calculo de bonus de ataque. Se usa la funcion creada anteriormente
    function attack_bonus(
        uint256 _class,
        uint256 _str,
        uint256 _level
    ) public pure returns (int256) {
        return
            int256(base_attack_bonus_by_class_and_level(_class, _level)) +
            modifier_for_attribute(_str);
    }

    // devuelve true o false, e indica si el jugador puede atacar a la dungeon
    function to_hit_ac(int256 _attack_bonus) public pure returns (bool) {
        return (_attack_bonus > dungeon_armor_class);
    }

    // Calculo del daño segun la fuerza del jugador
    function damage(uint256 _str) public pure returns (uint256) {
        int256 _mod = modifier_for_attribute(_str);
        if (_mod <= 1) {
            return 1;
        } else {
            return uint256(_mod);
        }
    }

    // devuelve el poder de defensa del jugador
    function armor_class(uint256 _dex) public pure returns (int256) {
        return modifier_for_attribute(_dex);
    }

    // funcion pelear con una dungeon
    function scout(uint256 _summoner) public view returns (uint256 reward) {
        // nivel del personaje
        uint256 _level = rm.level(_summoner);
        // clase del personaje
        uint256 _class = rm.class(_summoner);
        //  fuerza, destreza y constitucion del personaje
        (uint32 _str, uint32 _dex, uint32 _const, , , ) = _attr.ability_scores(
            _summoner
        );
        // salud del personaje
        int256 _health = int256(
            health_by_class_and_level(_class, _level, _const)
        );
        // salud de la dungeon
        int256 _dungeon_health = dungeon_health;
        // daño que hace el personaje
        int256 _damage = int256(damage(_str));
        // bonus de ataque del personaje
        int256 _attack_bonus = attack_bonus(_class, _str, _level);
        // indicador de si el jugador puede atacar
        bool _to_hit_ac = to_hit_ac(_attack_bonus);
        // indicador de ataque del dungeon (si nuestra defensa es menor que el golpe de la dungeon)
        bool _hit_ac = armor_class(_dex) < dungeon_to_hit;

        // si el jugador puede atacar...
        if (_to_hit_ac) {
            // ...entramos en un bucle de 10 rondas en el que ambos atacan.
            for (reward = 10; reward >= 0; reward--) {
                // le quitamos vida a la dungeon
                _dungeon_health -= _damage;
                // si le hemos vencido el bucle termina y devuelve un reward que depende
                //  de los ciclos de ataque que hayamos hecho
                if (_dungeon_health <= 0) {
                    break;
                }
                // si la dungeon nos puede atacar nos resta vida con su ataque
                if (_hit_ac) {
                    _health -= dungeon_damage;
                }
                // si nos mata se para el bucle y recibimos 0
                if (_health <= 0) {
                    return 0;
                }
            }
        }
    }

    // funcion que inicia una aventura. Devuelve una recompensa
    function adventure(uint256 _summoner) external returns (uint256 reward) {
        // comprueba que seas autorizado o dueño del personaje
        require(_isApprovedOrOwner(_summoner));
        // comprueba que no hayas hecho otra en las ultimas 24h
        require(block.timestamp > adventurers_log[_summoner]);
        // actualiza el log con la nueva fecha desde la que contabilizar la proxima adventure
        adventurers_log[_summoner] = block.timestamp + DAY;
        // calcula tu recompensa despues de la pelea
        reward = scout(_summoner);
        // mintea la recompensa y se la da al personaje
        _mint(_summoner, reward);
    }

    // inicializa el supply del material
    uint256 public totalSupply = 0;

    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    attributes constant _attr =
        attributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);

    // registro del allowance. relaciona personajes con cantidades aprovadas a terceros
    mapping(uint256 => mapping(uint256 => uint256)) public allowance;
    // registro de balances
    mapping(uint256 => uint256) public balanceOf;

    // registro de ultimo log del personaje
    mapping(uint256 => uint256) public adventurers_log;

    event Transfer(uint256 indexed from, uint256 indexed to, uint256 amount);
    event Approval(uint256 indexed from, uint256 indexed to, uint256 amount);

    // funciones que simulan ser erc-20
    function _isApprovedOrOwner(uint256 _summoner)
        internal
        view
        returns (bool)
    {
        return
            rm.getApproved(_summoner) == msg.sender ||
            rm.ownerOf(_summoner) == msg.sender;
    }

    function _mint(uint256 dst, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[dst] += amount;
        emit Transfer(dst, dst, amount);
    }

    function approve(
        uint256 from,
        uint256 spender,
        uint256 amount
    ) external returns (bool) {
        require(_isApprovedOrOwner(from));
        allowance[from][spender] = amount;

        emit Approval(from, spender, amount);
        return true;
    }

    function transfer(
        uint256 from,
        uint256 to,
        uint256 amount
    ) external returns (bool) {
        require(_isApprovedOrOwner(from));
        _transferTokens(from, to, amount);
        return true;
    }

    function transferFrom(
        uint256 executor,
        uint256 from,
        uint256 to,
        uint256 amount
    ) external returns (bool) {
        require(_isApprovedOrOwner(executor));
        uint256 spender = executor;
        uint256 spenderAllowance = allowance[from][spender];

        if (spender != from && spenderAllowance != type(uint256).max) {
            uint256 newAllowance = spenderAllowance - amount;
            allowance[from][spender] = newAllowance;

            emit Approval(from, spender, newAllowance);
        }

        _transferTokens(from, to, amount);
        return true;
    }

    function _transferTokens(
        uint256 from,
        uint256 to,
        uint256 amount
    ) internal {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }
}
