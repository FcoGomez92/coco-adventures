// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface rarity {
    function level(uint256) external view returns (uint256);

    function getApproved(uint256) external view returns (address);

    function ownerOf(uint256) external view returns (address);

    function class(uint256) external view returns (uint256);
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

interface codex_skills {
    function skill_by_id(uint256)
        external
        view
        returns (
            uint256 id,
            string memory name,
            uint256 attribute_id,
            uint256 synergy,
            bool retry,
            bool armor_check_penalty,
            string memory check,
            string memory action
        );
}

contract rarity_skills {
    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    attributes constant _attr =
        attributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);
    codex_skills constant _codex_skills =
        codex_skills(0x67ae39a2Ee91D7258a86CD901B17527e19E493B3);

    // devuelve un listado con el nombre de las skills que tiene una clase. Misma que en codex-class-skills
    function class_skills_by_name(uint256 _class)
        public
        view
        returns (string[] memory)
    {
        bool[36] memory _skills = class_skills(_class);
        uint256 x = 0;
        for (uint256 i = 0; i < 36; i++) {
            if (_skills[i]) {
                x++;
            }
        }
        string[] memory _skill_names = new string[](x);
        x = 0;
        for (uint256 i = 0; i < 36; i++) {
            if (_skills[i]) {
                (, string memory name, , , , , , ) = _codex_skills.skill_by_id(
                    i + 1
                );
                _skill_names[x++] = name;
            }
        }
        return _skill_names;
    }

    //
    function calculate_points_for_set(uint256 _class, uint8[36] memory _skills)
        public
        pure
        returns (uint256 points)
    {
        bool[36] memory _class_skills = class_skills(_class);
        for (uint256 i = 0; i < 36; i++) {
            if (_class_skills[i]) {
                points += _skills[i];
            } else {
                points += _skills[i] * 2;
            }
        }
    }

    // comprueba que la lista de skills que se le va a configurar a un personaje sea valida
    function is_valid_set(uint256 _summoner, uint8[36] memory _skills)
        public
        view
        returns (bool)
    {
        uint256 _level = rm.level(_summoner);
        uint256 _max_rank_class_skill = _level + 3;
        uint256 _max_rank_cross_skill = _max_rank_class_skill / 2;
        uint256 _class = rm.class(_summoner);
        bool[36] memory _class_skills = class_skills(_class);
        for (uint256 i = 0; i < 36; i++) {
            if (_class_skills[i]) {
                if (_skills[i] > _max_rank_class_skill) {
                    return false;
                }
            } else {
                if (_skills[i] > _max_rank_cross_skill) {
                    return false;
                }
            }
        }

        (, , , uint256 _int, , ) = _attr.ability_scores(_summoner);
        int256 _modifier = modifier_for_attribute(_int);
        uint256 _skill_points = skills_per_level(_modifier, _class, _level);
        uint256 _spent_points = calculate_points_for_set(_class, _skills);
        if (_skill_points < _spent_points) {
            return false;
        }
        return true;
    }

    // se le pasa una id de una clase y devuelve un listado de las 36 skill marcando con true o false si la clase tiene dicha skill
    // Igual que en codex-class-skills
    function class_skills(uint256 _class)
        public
        pure
        returns (bool[36] memory _skills)
    {
        if (_class == 1) {
            return [
                false,
                false,
                false,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                true,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                false,
                false
            ];
        } else if (_class == 2) {
            return [
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                true,
                true,
                false,
                true,
                false,
                false,
                true,
                false,
                true,
                true,
                true,
                true,
                false,
                true,
                true,
                false,
                false,
                true,
                true,
                true,
                true,
                false,
                false,
                true,
                true,
                true,
                false
            ];
        } else if (_class == 3) {
            return [
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            ];
        } else if (_class == 4) {
            return [
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                false,
                false,
                true,
                true,
                false,
                false,
                false,
                true,
                true,
                false,
                false,
                false,
                false,
                true,
                true,
                true,
                true,
                false,
                false,
                false
            ];
        } else if (_class == 5) {
            return [
                false,
                false,
                false,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false
            ];
        } else if (_class == 6) {
            return [
                false,
                true,
                false,
                true,
                true,
                true,
                false,
                true,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                true,
                false,
                true,
                true,
                true,
                true,
                false,
                true,
                true,
                false,
                false,
                true,
                false,
                false,
                false,
                true,
                false,
                true,
                true,
                false,
                false
            ];
        } else if (_class == 7) {
            return [
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false
            ];
        } else if (_class == 8) {
            return [
                false,
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                true,
                false,
                false,
                true,
                true,
                true,
                true,
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                true
            ];
        } else if (_class == 9) {
            return [
                true,
                true,
                true,
                true,
                false,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                false,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                true,
                false,
                true,
                true,
                true,
                false,
                false,
                true,
                false,
                true,
                true,
                true,
                true
            ];
        } else if (_class == 10) {
            return [
                false,
                false,
                true,
                false,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            ];
        } else if (_class == 11) {
            return [
                false,
                false,
                false,
                false,
                true,
                true,
                true,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                false,
                false,
                false
            ];
        }
    }

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

    function skills_per_level(
        int256 _int,
        uint256 _class,
        uint256 _level
    ) public pure returns (uint256 points) {
        points = uint256(int256(base_per_class(_class)) + _int) * (_level + 3);
    }

    function base_per_class(uint256 _class) public pure returns (uint256 base) {
        if (_class == 1) {
            return 4;
        } else if (_class == 2) {
            return 6;
        } else if (_class == 3) {
            return 2;
        } else if (_class == 4) {
            return 4;
        } else if (_class == 5) {
            return 2;
        } else if (_class == 6) {
            return 4;
        } else if (_class == 7) {
            return 2;
        } else if (_class == 8) {
            return 6;
        } else if (_class == 9) {
            return 8;
        } else if (_class == 10) {
            return 2;
        } else if (_class == 11) {
            return 2;
        }
    }

    // registro de skills de un personaje
    mapping(uint256 => uint8[36]) public skills;

    function get_skills(uint256 _summoner)
        external
        view
        returns (uint8[36] memory)
    {
        return skills[_summoner];
    }

    function _isApprovedOrOwner(uint256 _summoner)
        internal
        view
        returns (bool)
    {
        return
            rm.getApproved(_summoner) == msg.sender ||
            rm.ownerOf(_summoner) == msg.sender;
    }

    // configura las skills de un personaje
    function set_skills(uint256 _summoner, uint8[36] memory _skills) external {
        require(_isApprovedOrOwner(_summoner));
        require(_attr.character_created(_summoner));
        require(is_valid_set(_summoner, _skills));
        uint8[36] memory _current_skills = skills[_summoner];
        for (uint256 i = 0; i < 36; i++) {
            require(_current_skills[i] <= _skills[i]);
        }
        skills[_summoner] = _skills;
    }
}
