// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
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

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721 is ERC165, IERC721 {
    using Strings for uint256;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (_isContract(to)) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721.balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721Enumerable.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

interface rarity {
    function level(uint256) external view returns (uint256);

    function getApproved(uint256) external view returns (address);

    function ownerOf(uint256) external view returns (address);

    function class(uint256) external view returns (uint256);

    function summon(uint256 _class) external;

    function next_summoner() external view returns (uint256);

    function spend_xp(uint256 _summoner, uint256 _xp) external;
}

interface rarity_attributes {
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

interface rarity_skills {
    function get_skills(uint256 _summoner)
        external
        view
        returns (uint8[36] memory);
}

interface rarity_gold {
    function transferFrom(
        uint256 executor,
        uint256 from,
        uint256 to,
        uint256 amount
    ) external returns (bool);
}

interface rarity_crafting_materials_i {
    function transferFrom(
        uint256 executor,
        uint256 from,
        uint256 to,
        uint256 amount
    ) external returns (bool);
}

interface codex_items_goods {
    function item_by_id(uint256 _id)
        external
        pure
        returns (
            uint256 id,
            uint256 cost,
            uint256 weight,
            string memory name,
            string memory description
        );
}

interface codex_items_armor {
    function get_proficiency_by_id(uint256 _id)
        external
        pure
        returns (string memory description);

    function item_by_id(uint256 _id)
        external
        pure
        returns (
            uint256 id,
            uint256 cost,
            uint256 proficiency,
            uint256 weight,
            uint256 armor_bonus,
            uint256 max_dex_bonus,
            int256 penalty,
            uint256 spell_failure,
            string memory name,
            string memory description
        );
}

interface codex_items_weapons {
    struct weapon {
        uint256 id;
        uint256 cost;
        uint256 proficiency;
        uint256 encumbrance;
        uint256 damage_type;
        uint256 weight;
        uint256 damage;
        uint256 critical;
        int256 critical_modifier;
        uint256 range_increment;
        string name;
        string description;
    }

    function get_proficiency_by_id(uint256 _id)
        external
        pure
        returns (string memory description);

    function get_encumbrance_by_id(uint256 _id)
        external
        pure
        returns (string memory description);

    function get_damage_type_by_id(uint256 _id)
        external
        pure
        returns (string memory description);

    function item_by_id(uint256 _id)
        external
        pure
        returns (weapon memory _weapon);
}

interface codex_base_random {
    function d20(uint256 _summoner) external view returns (uint256);
}

contract rarity_crafting is ERC721Enumerable {
    // numero que representa el id de los nft
    uint256 public next_item;

    // cantidad de experiencia que consume el crafteo
    uint256 constant craft_xp_per_day = 250e18;

    // se inicializan los contratos de los que se nutre
    rarity constant _rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);

    rarity_attributes constant _attr =
        rarity_attributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);

    rarity_crafting_materials_i constant _craft_i =
        rarity_crafting_materials_i(0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A);

    rarity_gold constant _gold =
        rarity_gold(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);

    rarity_skills constant _skills =
        rarity_skills(0x51C0B29A1d84611373BA301706c6B4b72283C80F);

    codex_base_random constant _random =
        codex_base_random(0x7426dBE5207C2b5DaC57d8e55F0959fcD99661D4);

    codex_items_goods constant _goods =
        codex_items_goods(0x0C5C1CC0A7AE65FE372fbb08FF16578De4b980f3);

    codex_items_armor constant _armor =
        codex_items_armor(0xf5114A952Aca3e9055a52a87938efefc8BB7878C);

    codex_items_weapons constant _weapons =
        codex_items_weapons(0xeE1a2EA55945223404d73C0BbE57f540BBAAD0D8);

    string public constant name = "Rarity Crafting (I)";
    string public constant symbol = "RC(I)";

    event Crafted(
        address indexed owner,
        uint256 check,
        uint256 summoner,
        uint256 base_type,
        uint256 item_type,
        uint256 gold,
        uint256 craft_i
    );

    // ??? teoria de que cada personaje tiene su propio contrato crafting_common
    uint256 public immutable SUMMMONER_ID;

    // al hacer deploy del contrato se asigna el id del siguiente personaje (nft) por mintear a summoner_id
    // y se crea (mintea) el nuevo personaje con clase 11 (Wizard)
    constructor() {
        SUMMMONER_ID = _rm.next_summoner();
        _rm.summon(11);
    }

    // se crea el objeto tipo item
    struct item {
        uint8 base_type;
        uint8 item_type;
        uint32 crafted;
        uint256 crafter;
    }

    // Comprueba que seas autorizado o dueño del personaje
    function _isApprovedOrOwner(uint256 _summoner)
        internal
        view
        returns (bool)
    {
        return
            _rm.getApproved(_summoner) == msg.sender ||
            _rm.ownerOf(_summoner) == msg.sender;
    }

    // devuelve la difficult class de los tres tipos de objetos
    function get_goods_dc() public pure returns (uint256 dc) {
        return 20;
    }

    function get_armor_dc(uint256 _item_id) public pure returns (uint256 dc) {
        (, , , , uint256 _armor_bonus, , , , , ) = _armor.item_by_id(_item_id);
        return 20 + _armor_bonus;
    }

    function get_weapon_dc(uint256 _item_id) public pure returns (uint256 dc) {
        codex_items_weapons.weapon memory _weapon = _weapons.item_by_id(
            _item_id
        );
        if (_weapon.proficiency == 1) {
            return 20;
        } else if (_weapon.proficiency == 2) {
            return 25;
        } else if (_weapon.proficiency == 3) {
            return 30;
        }
    }

    // unifica las funciones creadas anteriormente para devolver la difficult class de cada item
    function get_dc(uint256 _base_type, uint256 _item_id)
        public
        pure
        returns (uint256 dc)
    {
        if (_base_type == 1) {
            return get_goods_dc();
        } else if (_base_type == 2) {
            return get_armor_dc(_item_id);
        } else if (_base_type == 3) {
            return get_weapon_dc(_item_id);
        }
    }

    // devuelve el coste del objeto
    function get_item_cost(uint256 _base_type, uint256 _item_type)
        public
        pure
        returns (uint256 cost)
    {
        if (_base_type == 1) {
            (, cost, , , ) = _goods.item_by_id(_item_type);
        } else if (_base_type == 2) {
            (, cost, , , , , , , , ) = _armor.item_by_id(_item_type);
        } else if (_base_type == 3) {
            codex_items_weapons.weapon memory _weapon = _weapons.item_by_id(
                _item_type
            );
            cost = _weapon.cost;
        }
    }

    // modificador segun nivel de atributo. En este contrato se usa inteligencia
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

    // comprueba que se den todas las condiciones para poder craftear
    function craft_skillcheck(uint256 _summoner, uint256 _dc)
        public
        view
        returns (bool crafted, int256 check)
    {
        // comprueba que el personaje tenga la habilidad craft
        check = int256(uint256(_skills.get_skills(_summoner)[5]));
        if (check == 0) {
            return (false, 0);
        }
        // comprueba el nivel de inteligencia del personaje
        (, , , uint256 _int, , ) = _attr.ability_scores(_summoner);
        check += modifier_for_attribute(_int);
        if (check <= 0) {
            return (false, 0);
        }
        // numero aleatorio del 0 al 20
        check += int256(_random.d20(_summoner));
        return (check >= int256(_dc), check);
    }

    // valida el objeto que se pasa a craftear
    function isValid(uint256 _base_type, uint256 _item_type)
        public
        pure
        returns (bool)
    {
        if (_base_type == 1) {
            return (1 <= _item_type && _item_type <= 24);
        } else if (_base_type == 2) {
            return (1 <= _item_type && _item_type <= 18);
        } else if (_base_type == 3) {
            return (1 <= _item_type && _item_type <= 59);
        }
        return false;
    }

    // simula un crafteo real
    function simulate(
        uint256 _summoner,
        uint256 _base_type,
        uint256 _item_type,
        uint256 _crafting_materials
    )
        external
        view
        returns (
            bool crafted,
            int256 check,
            uint256 cost,
            uint256 dc
        )
    {
        dc = get_dc(_base_type, _item_type);
        if (_crafting_materials >= 10) {
            dc = dc - (_crafting_materials / 10);
        }
        (crafted, check) = craft_skillcheck(_summoner, dc);
        if (crafted) {
            cost = get_item_cost(_base_type, _item_type);
        }
    }

    // crafteo de un objeto
    function craft(
        uint256 _summoner,
        uint8 _base_type,
        uint8 _item_type,
        uint256 _crafting_materials
    ) external {
        // comprueba que tengas permiso sobre el personaje
        require(_isApprovedOrOwner(_summoner), "!owner");
        // comprueba que el personaje tenga configurado los atributos
        require(_attr.character_created(_summoner), "!created");
        // comprueba que el personaje no sea el dueño del contrato
        require(_summoner != SUMMMONER_ID, "hax0r");
        // compueba la validez del objeto  (que exista)
        require(isValid(_base_type, _item_type), "!valid");
        // se configura la dificultad
        uint256 _dc = get_dc(_base_type, _item_type);
        // comprueba si es un material
        if (_crafting_materials >= 10) {
            require(
                _craft_i.transferFrom(
                    SUMMMONER_ID,
                    _summoner,
                    SUMMMONER_ID,
                    _crafting_materials
                ),
                "!craft"
            );
            _dc = _dc - (_crafting_materials / 10);
        }
        // se comprueba las habilidades de crafteo del personaje
        (bool crafted, int256 check) = craft_skillcheck(_summoner, _dc);
        if (crafted) {
            uint256 _cost = get_item_cost(_base_type, _item_type);
            // se hace el pago de oro
            require(
                _gold.transferFrom(
                    SUMMMONER_ID,
                    _summoner,
                    SUMMMONER_ID,
                    _cost
                ),
                "!gold"
            );
            // se mete el objeto crfteado y se le asocia con su id
            items[next_item] = item(
                _base_type,
                _item_type,
                uint32(block.timestamp),
                _summoner
            );
            // se mintea
            _safeMint(msg.sender, next_item);
            emit Crafted(
                msg.sender,
                uint256(check),
                _summoner,
                _base_type,
                _item_type,
                _cost,
                _crafting_materials
            );
            // se le suma 1 a la variable que lleva el registro de ids
            next_item++;
        }
        // se la gasta experiencia al personaje
        _rm.spend_xp(_summoner, craft_xp_per_day);
    }

    // se crea el libro de registro donde se relaciona ids con items crafteados
    mapping(uint256 => item) public items;

    function get_type(uint256 _type_id)
        public
        pure
        returns (string memory _type)
    {
        if (_type_id == 1) {
            _type = "Goods";
        } else if (_type_id == 2) {
            _type = "Armor";
        } else if (_type_id == 3) {
            _type = "Weapons";
        }
    }

    // funcion que unifica las funciones que devuelven los tokenUris segun tipo de item
    function tokenURI(uint256 _item) public view returns (string memory uri) {
        uint256 _base_type = items[_item].base_type;
        if (_base_type == 1) {
            return get_token_uri_goods(_item);
        } else if (_base_type == 2) {
            return get_token_uri_armor(_item);
        } else if (_base_type == 3) {
            return get_token_uri_weapon(_item);
        }
    }

    // crea y devuelve los metadatos del item tipo goods
    function get_token_uri_goods(uint256 _item)
        public
        view
        returns (string memory output)
    {
        item memory _data = items[_item];
        {
            (
                ,
                uint256 _cost,
                uint256 _weight,
                string memory _name,
                string memory _description
            ) = _goods.item_by_id(_data.item_type);
            output = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
            output = string(
                abi.encodePacked(
                    output,
                    "category ",
                    get_type(_data.base_type),
                    '</text><text x="10" y="40" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "name ",
                    _name,
                    '</text><text x="10" y="60" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "cost ",
                    toString(_cost / 1e18),
                    "gp",
                    '</text><text x="10" y="80" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "weight ",
                    toString(_weight),
                    "lb",
                    '</text><text x="10" y="100" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "description ",
                    _description,
                    '</text><text x="10" y="120" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "crafted by ",
                    toString(_data.crafter),
                    '</text><text x="10" y="140" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "crafted at ",
                    toString(_data.crafted),
                    "</text></svg>"
                )
            );
        }
        output = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "item #',
                                toString(_item),
                                '", "description": "Rarity tier 1, non magical, item crafting.", "image": "data:image/svg+xml;base64,',
                                Base64.encode(bytes(output)),
                                '"}'
                            )
                        )
                    )
                )
            )
        );

        return output;
    }

    // crea y devuelve los metadatos del item tipo armor
    function get_token_uri_armor(uint256 _item)
        public
        view
        returns (string memory output)
    {
        item memory _data = items[_item];
        {
            (
                ,
                uint256 _cost,
                uint256 _proficiency,
                uint256 _weight,
                uint256 _armor_bonus,
                uint256 _max_dex_bonus,
                int256 _penalty,
                uint256 _spell_failure,
                string memory _name,
                string memory _description
            ) = _armor.item_by_id(_data.item_type);
            output = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
            output = string(
                abi.encodePacked(
                    output,
                    "category ",
                    get_type(_data.base_type),
                    '</text><text x="10" y="40" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "name ",
                    _name,
                    '</text><text x="10" y="60" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "cost ",
                    toString(_cost / 1e18),
                    "gp",
                    '</text><text x="10" y="80" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "weight ",
                    toString(_weight),
                    "lb",
                    '</text><text x="10" y="100" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "proficiency ",
                    _armor.get_proficiency_by_id(_proficiency),
                    '</text><text x="10" y="120" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "armor bonus ",
                    toString(_armor_bonus),
                    '</text><text x="10" y="140" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "max dex ",
                    toString(_max_dex_bonus),
                    '</text><text x="10" y="160" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "penalty ",
                    toString(_penalty),
                    '</text><text x="10" y="180" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "spell failure ",
                    toString(_spell_failure),
                    "%",
                    '</text><text x="10" y="200" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "description ",
                    _description,
                    '</text><text x="10" y="220" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "crafted by ",
                    toString(_data.crafter),
                    '</text><text x="10" y="240" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "crafted at ",
                    toString(_data.crafted),
                    "</text></svg>"
                )
            );
        }
        output = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "item #',
                                toString(_item),
                                '", "description": "Rarity tier 1, non magical, item crafting.", "image": "data:image/svg+xml;base64,',
                                Base64.encode(bytes(output)),
                                '"}'
                            )
                        )
                    )
                )
            )
        );
    }

    // crea y devuelve los metadatos del item tipo weapon
    function get_token_uri_weapon(uint256 _item)
        public
        view
        returns (string memory output)
    {
        item memory _data = items[_item];
        {
            codex_items_weapons.weapon memory _weapon = _weapons.item_by_id(
                _data.item_type
            );
            output = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
            output = string(
                abi.encodePacked(
                    output,
                    "category ",
                    get_type(_data.base_type),
                    '</text><text x="10" y="40" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "name ",
                    _weapon.name,
                    '</text><text x="10" y="60" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "cost ",
                    toString(_weapon.cost / 1e18),
                    "gp",
                    '</text><text x="10" y="80" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "weight ",
                    toString(_weapon.weight),
                    "lb",
                    '</text><text x="10" y="100" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "proficiency ",
                    _weapons.get_proficiency_by_id(_weapon.proficiency),
                    '</text><text x="10" y="120" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "encumbrance ",
                    _weapons.get_encumbrance_by_id(_weapon.encumbrance),
                    '</text><text x="10" y="140" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "damage 1d",
                    toString(_weapon.damage),
                    " ",
                    _weapons.get_damage_type_by_id(_weapon.damage_type),
                    '</text><text x="10" y="160" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "(modifier) x critical (",
                    toString(_weapon.critical_modifier),
                    ") x ",
                    toString(_weapon.critical),
                    '</text><text x="10" y="180" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "range ",
                    toString(_weapon.range_increment),
                    "ft",
                    '</text><text x="10" y="200" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "description ",
                    _weapon.description,
                    '</text><text x="10" y="220" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "crafted by ",
                    toString(_data.crafter),
                    '</text><text x="10" y="240" class="base">'
                )
            );
            output = string(
                abi.encodePacked(
                    output,
                    "crafted at ",
                    toString(_data.crafted),
                    "</text></svg>"
                )
            );
        }
        output = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string(
                            abi.encodePacked(
                                '{"name": "item #',
                                toString(_item),
                                '", "description": "Rarity tier 1, non magical, item crafting.", "image": "data:image/svg+xml;base64,',
                                Base64.encode(bytes(output)),
                                '"}'
                            )
                        )
                    )
                )
            )
        );
    }

    function toString(int256 value) internal pure returns (string memory) {
        string memory _string = "";
        if (value < 0) {
            _string = "-";
            value = value * -1;
        }
        return string(abi.encodePacked(_string, toString(uint256(value))));
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
