// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract codex {
    string public constant index = "Spells";
    string public constant class = "Bard";
    string public constant school = "Enchantment";
    uint256 public constant level = 0;

    function spell_by_id(uint256 _id)
        external
        pure
        returns (
            uint256 id,
            string memory name,
            bool verbal,
            bool somatic,
            bool focus,
            bool divine_focus,
            uint256 xp_cost,
            uint256 time,
            uint256 range,
            uint256 duration,
            uint256 saving_throw_type,
            uint256 saving_throw_effect,
            bool spell_resistance,
            string memory description
        )
    {
        if (_id == 6) {
            return daze();
        } else if (_id == 7) {
            return lullaby();
        }
    }

    function daze()
        public
        pure
        returns (
            uint256 id,
            string memory name,
            bool verbal,
            bool somatic,
            bool focus,
            bool divine_focus,
            uint256 xp_cost,
            uint256 time,
            uint256 range,
            uint256 duration,
            uint256 saving_throw_type,
            uint256 saving_throw_effect,
            bool spell_resistance,
            string memory description
        )
    {
        id = 6;
        name = "Daze";
        verbal = true;
        somatic = true;
        focus = false;
        divine_focus = false;
        xp_cost = 0;
        time = 1;
        range = 2;
        duration = 1;
        saving_throw_type = 3;
        saving_throw_effect = 3;
        spell_resistance = true;
        description = "This enchantment clouds the mind of a humanoid creature with 4 or fewer Hit Dice so that it takes no actions. Humanoids of 5 or more HD are not affected. A dazed subject is not stunned, so attackers get no special advantage against it.";
    }

    function lullaby()
        public
        pure
        returns (
            uint256 id,
            string memory name,
            bool verbal,
            bool somatic,
            bool focus,
            bool divine_focus,
            uint256 xp_cost,
            uint256 time,
            uint256 range,
            uint256 duration,
            uint256 saving_throw_type,
            uint256 saving_throw_effect,
            bool spell_resistance,
            string memory description
        )
    {
        id = 7;
        name = "Lullaby";
        verbal = true;
        somatic = true;
        focus = false;
        divine_focus = false;
        xp_cost = 0;
        time = 1;
        range = 3;
        duration = 1;
        saving_throw_type = 3;
        saving_throw_effect = 3;
        spell_resistance = true;
        description = "Any creature within the area that fails a Will save becomes drowsy and inattentive, taking a -5 penalty on Listen and Spot checks and a -2 penalty on Will saves against sleep effects while the lullaby is in effect. Lullaby lasts for as long as the caster concentrates, plus up to 1 round per caster level thereafter.";
    }
}
