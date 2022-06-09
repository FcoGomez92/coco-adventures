// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract codex {
    string constant index = "Spells";
    string constant class = "Wizard";

    // registro de paginas?. Una pagina es un address. Tienen que ir asociadas a un school y un nivel.
    mapping(uint256 => mapping(uint256 => address)) public pages;

    // se crea la variable loremaster
    address public loremaster;

    constructor() {
        // al hacer deploy se asigna el msg.sender (el que hace el deploy) a loremaster
        loremaster = msg.sender;
    }

    // funcion intermediaria que revisa que el que llama a una funcion sea el loremaster. Si no es asi se revoca la llamada
    modifier lm() {
        require(msg.sender == loremaster);
        _;
    }

    // funcion para reasignar al loremaster. Solo puede hacerlo el actual loremaster
    function setLoremaster(address _loremaster) external lm {
        loremaster = _loremaster;
    }

    // añade una nueva pagina al libro de registros definido arriba
    function addPage(
        uint256 _school,
        uint256 _level,
        address _page
    ) external lm {
        pages[_school][_level] = _page;
    }

    //  devuelve el nombre de un school segun id
    function school(uint256 id)
        external
        pure
        returns (string memory description)
    {
        if (id == 0) {
            return "Abjuration";
        } else if (id == 1) {
            return "Conjuration";
        } else if (id == 2) {
            return "Divination";
        } else if (id == 3) {
            return "Enchantment";
        } else if (id == 4) {
            return "Evocation";
        } else if (id == 5) {
            return "Illusion";
        } else if (id == 6) {
            return "Necromancy";
        } else if (id == 7) {
            return "Transmutation";
        } else if (id == 8) {
            return "Universal";
        }
    }

    // Devuelve el casting time segun id
    function casting_time(uint256 id)
        external
        pure
        returns (string memory description)
    {
        if (id == 0) {
            return "1 free action";
        } else if (id == 1) {
            return "1 standard action";
        } else if (id == 2) {
            return "full-round action";
        } else if (id == 3) {
            return "10 full-round actions";
        }
    }

    // Devuelve el rango segun id
    function range(uint256 id)
        external
        pure
        returns (string memory description)
    {
        if (id == 0) {
            return "Personal";
        } else if (id == 1) {
            return "Touch";
        } else if (id == 2) {
            return "Close";
        } else if (id == 3) {
            return "Medium";
        } else if (id == 4) {
            return "Long";
        } else if (id == 5) {
            return "Unlimited";
        }
    }

    // Devuelve el saving_throw_type segun id
    function saving_throw_type(uint256 id)
        external
        pure
        returns (string memory description)
    {
        if (id == 0) {
            return "None";
        } else if (id == 1) {
            return "Fortitude";
        } else if (id == 2) {
            return "Reflex";
        } else if (id == 3) {
            return "Will";
        }
    }

    // Devuelve el saving_throw_effect segun id
    function saving_throw_effect(uint256 id)
        external
        pure
        returns (string memory description)
    {
        if (id == 0) {
            return "None";
        } else if (id == 1) {
            return "Partial";
        } else if (id == 2) {
            return "Half";
        } else if (id == 3) {
            return "Negates";
        }
    }

    // Devuelve el spell_effect segun id
    function spell_effect(uint256 id)
        external
        pure
        returns (string memory description)
    {
        if (id == 0) {
            return "None";
        } else if (id == 1) {
            return "HP";
        } else if (id == 2) {
            return "AC";
        } else if (id == 3) {
            return "Strength";
        } else if (id == 4) {
            return "Dexterity";
        } else if (id == 5) {
            return "Constitution";
        } else if (id == 6) {
            return "Intelligence";
        } else if (id == 7) {
            return "Wisdom";
        } else if (id == 8) {
            return "Charisma";
        } else if (id == 9) {
            return "Time"; // e.g. slow
        } else if (id == 10) {
            return "Space"; // e.g. summons (items/monsters), duplicates, curses/enchantments, illusions
        } else if (id == 11) {
            return "Condition"; // listed in conditions.sol
        }
    }
}
