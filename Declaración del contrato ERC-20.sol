// Declaración del contrato ERC-20
pragma solidity ^0.8.0;

contract MiToken {
    string public nombre;  // Nombre del token (ej. "MiToken")
    string public simbolo;  // Símbolo del token (ej. "MIT")
    uint8 public decimales;  // Cantidad de decimales (generalmente 18)
    uint256 public suministroTotal;  // Suministro total de tokens
    address public propietario;  // Dirección del propietario del contrato

    // Mapeo para mantener un registro del saldo de tokens por dirección
    mapping(address => uint256) public saldo;

    // Mapeo para gestionar las asignaciones de autorización
    mapping(address => mapping(address => uint256)) public asignacionDeAutorización;

    event Transfer(address indexed remitente, address indexed destinatario, uint256 cantidad);
    event Aprobación(address indexed propietario, address indexed autorizado, uint256 cantidad);

    // Constructor para inicializar el contrato
    constructor(
        string memory _nombre,
        string memory _simbolo,
        uint8 _decimales,
        uint256 _suministroInicial
    ) {
        nombre = _nombre;
        simbolo = _simbolo;
        decimales = _decimales;
        suministroTotal = _suministroInicial * 10 ** uint256(decimales);
        propietario = msg.sender;
        saldo[msg.sender] = suministroTotal;
    }

    // Función para realizar una transferencia de tokens
    function transferencia(address destinatario, uint256 cantidad) public returns (bool) {
        require(destinatario != address(0), "La dirección del destinatario no puede ser cero");
        require(saldo[msg.sender] >= cantidad, "Saldo insuficiente");

        saldo[msg.sender] -= cantidad;
        saldo[destinatario] += cantidad;
        emit Transfer(msg.sender, destinatario, cantidad);
        return true;
    }

    // Función para aprobar a otro usuario a gastar tokens en tu nombre
    function aprobar(address autorizado, uint256 cantidad) public returns (bool) {
        asignacionDeAutorización[msg.sender][autorizado] = cantidad;
        emit Aprobación(msg.sender, autorizado, cantidad);
        return true;
    }

    // Función para realizar una transferencia desde una dirección autorizada
    function transferenciaDesde(address remitente, address destinatario, uint256 cantidad) public returns (bool) {
        require(remitente != address(0), "La dirección del remitente no puede ser cero");
        require(destinatario != address(0), "La dirección del destinatario no puede ser cero");
        require(saldo[remitente] >= cantidad, "Saldo insuficiente");
        require(asignacionDeAutorización[remitente][msg.sender] >= cantidad, "No tiene autorización para transferir esta cantidad");

        saldo[remitente] -= cantidad;
        saldo[destinatario] += cantidad;
        asignacionDeAutorización[remitente][msg.sender] -= cantidad;
        emit Transfer(remitente, destinatario, cantidad);
        return true;
    }

    // Función para consultar el saldo de una dirección
    function consultarSaldo(address cuenta) public view returns (uint256) {
        return saldo[cuenta];
    }

    // Función para consultar la asignación de autorización entre dos direcciones
    function consultarAsignaciónDeAutorización(address propietario, address autorizado) public view returns (uint256) {
        return asignacionDeAutorización[propietario][autorizado];
    }

    // Función para permitir al propietario transferir la propiedad del contrato
    function transferenciaDePropietario(address nuevoPropietario) public {
        require(msg.sender == propietario, "Solo el propietario actual puede transferir la propiedad del contrato");
        require(nuevoPropietario != address(0), "La dirección del nuevo propietario no puede ser cero");

        propietario = nuevoPropietario;
    }
}
