// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract codex {
    string public constant index = "Spells";
    string public constant class = "Bard";
    string public constant school = "Conjuration";
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
        if (_id == 2) {
            return summon_instrument();
        }
    }

    function summon_instrument()
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
        id = 2;
        name = "Summon Instrument";
        verbal = true;
        somatic = true;
        focus = false;
        divine_focus = false;
        xp_cost = 0;
        time = 2;
        range = 1;
        duration = 60;
        saving_throw_type = 0;
        saving_throw_effect = 0;
        spell_resistance = false;
        description = "This spell summons one handheld musical instrument of your choice. This instrument appears in your hands or at your feet (your choice). The instrument is typical for its type. Only one instrument appears per casting, and it will play only for you. You cant summon an instrument too large to be held in two hands.";
    }
}
