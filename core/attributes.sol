// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// interfaz para usar esas funciones del contrato rarity
interface rarity {
    function level(uint256) external view returns (uint256);

    function getApproved(uint256) external view returns (address);

    function ownerOf(uint256) external view returns (address);
}

contract rarity_attributes {
    // puntos para gastar cuando se crea el personaje
    uint256 constant POINT_BUY = 32;

    // se crea la instancia del contrato rarity
    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);

    // se crea el objeto donde se definen las habilidades que tienen los personajes
    struct ability_score {
        uint32 strength;
        uint32 dexterity;
        uint32 constitution;
        uint32 intelligence;
        uint32 wisdom;
        uint32 charisma;
    }

    // registro que enlaza a un personaje con su objeto de habilidades
    mapping(uint256 => ability_score) public ability_scores;

    // registro que enlaza cada personaje con el dato de level_points gastados
    mapping(uint256 => uint256) public level_points_spent;

    // // registro que indica si un personaje ha sido creado (no solo minteado, sino configurado)
    mapping(uint256 => bool) public character_created;

    // Evento que se emite cuando se crea un personaje
    event Created(
        address indexed creator,
        uint256 summoner,
        uint32 strength,
        uint32 dexterity,
        uint32 constitution,
        uint32 intelligence,
        uint32 wisdom,
        uint32 charisma
    );

    // Evento que se emite cuando un personaje sube de nivel
    event Leveled(
        address indexed leveler,
        uint256 summoner,
        uint32 strength,
        uint32 dexterity,
        uint32 constitution,
        uint32 intelligence,
        uint32 wisdom,
        uint32 charisma
    );

    // comprueba que el que llama a la funcion sea o bien una persona autorizada o bien el dueño del personaje
    function _isApprovedOrOwner(uint256 _summoner)
        internal
        view
        returns (bool)
    {
        return
            rm.getApproved(_summoner) == msg.sender ||
            rm.ownerOf(_summoner) == msg.sender;
    }

    // gastar puntos para confifurar el personaje
    function point_buy(
        uint256 _summoner,
        uint32 _str,
        uint32 _dex,
        uint32 _const,
        uint32 _int,
        uint32 _wis,
        uint32 _cha
    ) external {
        // comprueba que tengas permiso para configurar al personaje
        require(_isApprovedOrOwner(_summoner));
        // comprueba que no se haya configurado previamente
        require(!character_created[_summoner]);
        // comprueba que la suma de los puntos de habilidadconfigurados cuadre con POINT_BUY iniciales(32)
        require(
            calculate_point_buy(_str, _dex, _const, _int, _wis, _cha) ==
                POINT_BUY
        );
        // se cambia el toggle de personaje creado a true
        character_created[_summoner] = true;

        // se enlaza el libro de registro de habilides de personaje con las habilidades configuradas
        ability_scores[_summoner] = ability_score(
            _str,
            _dex,
            _const,
            _int,
            _wis,
            _cha
        );

        emit Created(
            msg.sender,
            _summoner,
            _str,
            _dex,
            _const,
            _int,
            _wis,
            _cha
        );
    }

    // funcion que suma los puntos de habilidad configurados
    function calculate_point_buy(
        uint256 _str,
        uint256 _dex,
        uint256 _const,
        uint256 _int,
        uint256 _wis,
        uint256 _cha
    ) public pure returns (uint256) {
        return
            calc(_str) +
            calc(_dex) +
            calc(_const) +
            calc(_int) +
            calc(_wis) +
            calc(_cha);
    }

    function calc(uint256 score) public pure returns (uint256) {
        if (score <= 14) {
            return score - 8;
        } else {
            return ((score - 8)**2) / 6;
        }
    }

    function _increase_base(uint256 _summoner) internal {
        require(_isApprovedOrOwner(_summoner));
        require(character_created[_summoner]);
        uint256 _points_spent = level_points_spent[_summoner];
        require(abilities_by_level(rm.level(_summoner)) - _points_spent > 0);
        level_points_spent[_summoner] = _points_spent + 1;
    }

    // funciones para incremantar las habilidades
    function increase_strength(uint256 _summoner) external {
        _increase_base(_summoner);
        ability_score storage _attr = ability_scores[_summoner];
        _attr.strength = _attr.strength + 1;
        emit Leveled(
            msg.sender,
            _summoner,
            _attr.strength,
            _attr.dexterity,
            _attr.constitution,
            _attr.intelligence,
            _attr.wisdom,
            _attr.charisma
        );
    }

    function increase_dexterity(uint256 _summoner) external {
        _increase_base(_summoner);
        ability_score storage _attr = ability_scores[_summoner];
        _attr.dexterity = _attr.dexterity + 1;
        emit Leveled(
            msg.sender,
            _summoner,
            _attr.strength,
            _attr.dexterity,
            _attr.constitution,
            _attr.intelligence,
            _attr.wisdom,
            _attr.charisma
        );
    }

    function increase_constitution(uint256 _summoner) external {
        _increase_base(_summoner);
        ability_score storage _attr = ability_scores[_summoner];
        _attr.constitution = _attr.constitution + 1;
        emit Leveled(
            msg.sender,
            _summoner,
            _attr.strength,
            _attr.dexterity,
            _attr.constitution,
            _attr.intelligence,
            _attr.wisdom,
            _attr.charisma
        );
    }

    function increase_intelligence(uint256 _summoner) external {
        _increase_base(_summoner);
        ability_score storage _attr = ability_scores[_summoner];
        _attr.intelligence = _attr.intelligence + 1;
        emit Leveled(
            msg.sender,
            _summoner,
            _attr.strength,
            _attr.dexterity,
            _attr.constitution,
            _attr.intelligence,
            _attr.wisdom,
            _attr.charisma
        );
    }

    function increase_wisdom(uint256 _summoner) external {
        _increase_base(_summoner);
        ability_score storage _attr = ability_scores[_summoner];
        _attr.wisdom = _attr.wisdom + 1;
        emit Leveled(
            msg.sender,
            _summoner,
            _attr.strength,
            _attr.dexterity,
            _attr.constitution,
            _attr.intelligence,
            _attr.wisdom,
            _attr.charisma
        );
    }

    function increase_charisma(uint256 _summoner) external {
        _increase_base(_summoner);
        ability_score storage _attr = ability_scores[_summoner];
        _attr.charisma = _attr.charisma + 1;
        emit Leveled(
            msg.sender,
            _summoner,
            _attr.strength,
            _attr.dexterity,
            _attr.constitution,
            _attr.intelligence,
            _attr.wisdom,
            _attr.charisma
        );
    }

    function abilities_by_level(uint256 current_level)
        public
        pure
        returns (uint256)
    {
        return current_level / 4;
    }

    // devuelve los metadatos de habilidades del personaje
    // se comporta como un ERC-721 aunque este contrato no lo es
    function tokenURI(uint256 _summoner) public view returns (string memory) {
        string memory output;
        {
            string[7] memory parts;
            ability_score memory _attr = ability_scores[_summoner];
            parts[
                0
            ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

            parts[1] = string(
                abi.encodePacked(
                    "strength",
                    " ",
                    toString(_attr.strength),
                    '</text><text x="10" y="40" class="base">'
                )
            );

            parts[2] = string(
                abi.encodePacked(
                    "dexterity",
                    " ",
                    toString(_attr.dexterity),
                    '</text><text x="10" y="60" class="base">'
                )
            );

            parts[3] = string(
                abi.encodePacked(
                    "constitution",
                    " ",
                    toString(_attr.constitution),
                    '</text><text x="10" y="80" class="base">'
                )
            );

            parts[4] = string(
                abi.encodePacked(
                    "intelligence",
                    " ",
                    toString(_attr.intelligence),
                    '</text><text x="10" y="100" class="base">'
                )
            );

            parts[5] = string(
                abi.encodePacked(
                    "wisdom",
                    " ",
                    toString(_attr.wisdom),
                    '</text><text x="10" y="120" class="base">'
                )
            );

            parts[6] = string(
                abi.encodePacked(
                    "charisma",
                    " ",
                    toString(_attr.charisma),
                    "</text></svg>"
                )
            );

            output = string(
                abi.encodePacked(
                    parts[0],
                    parts[1],
                    parts[2],
                    parts[3],
                    parts[4],
                    parts[5],
                    parts[6]
                )
            );
        }
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "summoner #',
                        toString(_summoner),
                        '", "description": "Rarity is achieved via an active economy, summoners must level, gain feats, learn spells, to be able to craft gear. This allows for market driven rarity while allowing an ever growing economy. Feats, spells, and summoner gear is ommitted as part of further expansions.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
