// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface rarity {
    function level(uint256) external view returns (uint256);

    function getApproved(uint256) external view returns (address);

    function ownerOf(uint256) external view returns (address);

    function class(uint256) external view returns (uint256);
}

interface rarity_codex_feats {
    function feat_by_id(uint256 _id)
        external
        pure
        returns (
            uint256 id,
            string memory name,
            bool prerequisites,
            uint256 prerequisites_feat,
            uint256 prerequisites_class,
            uint256 prerequisites_level,
            string memory benefit
        );
}

contract rarity_feats {
    rarity constant _rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    rarity_codex_feats constant _feats_1 =
        rarity_codex_feats(0x88db734E9f64cA71a24d8e75986D964FFf7a1E10);
    rarity_codex_feats constant _feats_2 =
        rarity_codex_feats(0x7A4Ba2B077CD9f4B13D5853411EcAE12FADab89C);

    // valida que el feat que pasamos a la funcion exista
    function is_valid(uint256 feat) public pure returns (bool) {
        return (1 <= feat && feat <= 99);
    }

    // devuelve el feat segun id. Unifica las funciones homonimas de codex-feats-1 y codex-feats-2
    function feat_by_id(uint256 _id)
        public
        pure
        returns (
            uint256 id,
            string memory name,
            bool prerequisites,
            uint256 prerequisites_feat,
            uint256 prerequisites_class,
            uint256 prerequisites_level,
            string memory benefit
        )
    {
        if (_id <= 64) {
            return _feats_1.feat_by_id(_id);
        } else if (_id <= 99) {
            return _feats_2.feat_by_id(_id);
        }
    }

    // calcula el numero de feats segun nivel
    function feats_per_level(uint256 _level)
        public
        pure
        returns (uint256 amount)
    {
        amount = (_level / 3) + 1;
    }

    // calcula el numero de feats segun clase
    function feats_per_class(uint256 _class, uint256 _level)
        public
        pure
        returns (uint256 amount)
    {
        amount = feats_per_level(_level);
        if (_class == 1) {
            amount += 5;
        } else if (_class == 2) {
            amount += 4;
        } else if (_class == 3) {
            amount += 5;
        } else if (_class == 4) {
            amount += 4;
        } else if (_class == 5) {
            amount += 7;
        } else if (_class == 6) {
            amount += 2;
        } else if (_class == 7) {
            amount += 6;
        } else if (_class == 8) {
            amount += 4;
        } else if (_class == 9) {
            amount += 3;
        } else if (_class == 10) {
            amount += 1;
        } else if (_class == 11) {
            amount += 2;
        }

        if (_class == 5) {
            amount += (_level / 2) + 1;
        } else if (_class == 6) {
            if (_level >= 6) {
                amount += 3;
            } else if (_level >= 2) {
                amount += 2;
            } else {
                amount += 1;
            }
        } else if (_class == 11) {
            amount += (_level / 5);
        }
    }

    // registro que enlaza cada personaje con los 100 feats
    mapping(uint256 => bool[100]) public feats;

    // devuelve los id de los feat que tiene el personaje
    mapping(uint256 => uint256[]) public feats_by_id;

    // registra si (los feats d)el personaje se ha creado
    mapping(uint256 => bool) public character_created;

    // devuelve el la lista de feats indicando cual tiene el personaje
    function get_feats(uint256 _summoner)
        external
        view
        returns (bool[100] memory _feats)
    {
        return feats[_summoner];
    }

    // devuelve los ids de los feat que tiene el personaje
    function get_feats_by_id(uint256 _summoner)
        external
        view
        returns (uint256[] memory _feats)
    {
        return feats_by_id[_summoner];
    }

    // devuelve los nombres de los feat que tiene el personaje
    function get_feats_by_name(uint256 _summoner)
        external
        view
        returns (string[] memory _names)
    {
        _names = new string[](feats_by_id[_summoner].length);
        for (uint256 i = 0; i < _names.length; i++) {
            (, string memory _name, , , , , ) = feat_by_id(
                feats_by_id[_summoner][i]
            );
            _names[i] = _name;
        }
    }

    // valida si quien llama a la funcion es el duelo del personaje o un autorizado
    function _isApprovedOrOwner(uint256 _summoner)
        internal
        view
        returns (bool)
    {
        return
            _rm.getApproved(_summoner) == msg.sender ||
            _rm.ownerOf(_summoner) == msg.sender;
    }

    //
    function is_valid_class(uint256 _flag, uint256 _class)
        public
        pure
        returns (bool)
    {
        return (_flag & (2**(_class - 1))) == (2**(_class - 1));
    }

    // devuelve los feats base de una clase
    function get_base_class_feats(uint256 _class)
        public
        pure
        returns (uint8[7] memory _feats)
    {
        if (_class == 1) {
            _feats = [91, 75, 5, 6, 63, 0, 0];
        } else if (_class == 2) {
            _feats = [91, 75, 5, 63, 0, 0, 0];
        } else if (_class == 3) {
            _feats = [91, 5, 6, 7, 63, 0, 0];
        } else if (_class == 4) {
            _feats = [91, 5, 6, 63, 0, 0, 0];
        } else if (_class == 5) {
            _feats = [91, 75, 5, 6, 7, 63, 96];
        } else if (_class == 6) {
            _feats = [34, 24, 0, 0, 0, 0, 0];
        } else if (_class == 7) {
            _feats = [91, 75, 5, 6, 7, 63, 0];
        } else if (_class == 8) {
            _feats = [91, 75, 5, 63, 0, 0, 0];
        } else if (_class == 9) {
            _feats = [91, 75, 5, 0, 0, 0, 0];
        } else if (_class == 10) {
            _feats = [91, 0, 0, 0, 0, 0, 0];
        } else if (_class == 11) {
            _feats = [91, 88, 0, 0, 0, 0, 0];
        }
    }

    // configuracion de feats de clase
    function setup_class(uint256 _summoner) public {
        uint256 _class = _rm.class(_summoner);
        uint8[7] memory _feats = get_base_class_feats(_class);
        for (uint256 i = 0; i < 7; i++) {
            if (is_valid(_feats[i])) {
                feats[_summoner][_feats[i]] = true;
                feats_by_id[_summoner].push(_feats[i]);
            }
        }
        character_created[_summoner] = true;
    }

    // aprender feat para un personaje
    function select_feat(uint256 _summoner, uint256 _feat) external {
        require(_isApprovedOrOwner(_summoner), "!summoner");
        require(is_valid(_feat), "!feat");
        uint256 _class = _rm.class(_summoner);
        uint256 _level = _rm.level(_summoner);
        // comprueba que tenga hueco para aprender
        require(
            feats_per_class(_class, _level) > feats_by_id[_summoner].length,
            "!points"
        );
        // si es la primera vez se hace la configuracion inicial de clase
        if (!character_created[_summoner]) {
            setup_class(_summoner);
        }
        // comprueba que lo que se quiere aprender no esté ya aprendido
        require(!feats[_summoner][_feat], "known");

        // coge los datos que necesita del feat
        (
            ,
            ,
            bool _prerequisites,
            uint256 _prerequisites_feat,
            uint256 _prerequisites_class,
            uint256 _prerequisites_level,

        ) = feat_by_id(_feat);
        // si tiene prerrequisitos, entra en el condicional para comprobar que se cumplen
        if (_prerequisites) {
            if (_prerequisites_feat > 0) {
                require(feats[_summoner][_prerequisites_feat]);
            }
            require(is_valid_class(_prerequisites_class, _class), "!class");
            require(_level >= _prerequisites_level);
        }
        //  si se pasan todos los prerrequisitos o no los habia, se configura el feat al personaje
        feats[_summoner][_feat] = true;
        feats_by_id[_summoner].push(_feat);
    }
}
