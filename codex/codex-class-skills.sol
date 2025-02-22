// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// crea una interfaz del contrato codex-skill.sol para poder usar la función skill_by_id
interface codex_skills {
    function skill_by_id(uint256)
        external
        pure
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

contract codex {
    string public constant index = "Class Skills";
    string public constant class = "Any";

    // Se inicializa la interfaz creada al principio. Hace falta el address del contrato codex-skills
    codex_skills constant _codex_skills =
        codex_skills(0x67ae39a2Ee91D7258a86CD901B17527e19E493B3);

    // devuelve un listado con el nombre de las skills que tiene una clase
    function class_skills_by_name(uint256 _class)
        public
        pure
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

    // devuelve un recuento del numero de skills que tiene una clase
    function class_skills_by_count(uint256 _class)
        public
        pure
        returns (uint256 x)
    {
        bool[36] memory _skills = class_skills(_class);
        for (uint256 i = 0; i < 36; i++) {
            if (_skills[i]) {
                x++;
            }
        }
    }

    // se le pasa una id de una clase y devuelve un listado de las 36 skill marcando con true o false si la clase tiene dicha skill
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
}
