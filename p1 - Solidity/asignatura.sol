// Álvaro Díaz del Mazo
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract Asignatura {
    
    /// Versión 2020 - Teoría
    uint public version = 2020;
    /**
     * address del profesor que ha desplegado el contrato.
     * El contrato lo despliega el profesor.
     */

    address public profesor;
    
    /// Nombre de la asignatura
    string public nombre;
    
    /// Curso académico
    string public curso;
    
    // Usuario que ha desplegado el contrato
    address public owner;
    
    // Direccion de usuario del coordinador de una asignatura
    address public coordinador;
    
    // Boolean para ver si la asignatura está cerrada o no
    /* Si la asignatura está cerrada=true:
    - No matricular nuevos alumnos - Hecho
    - No añadir profesores - Hecho
    - No crear evaluaciones - Hecho
    - No poner notas - Hecho */ 
    bool public cerrada;
    
    // Diccionario con los nombres de los profesores asociados a su direccion de usuario
    mapping(address => string) public datosProfesor;
    
    // Direcciones de usuario de los profesores
    address[] public profesores;
    
    /**
     * Datos de una evaluación
     */
    struct Evaluacion {
        string nombreEval;
        uint fecha;
        uint puntos;
    }
    
    /// Evaluaciones de la asignatura
    Evaluacion[] evaluaciones;
    
    /// Datos de un getAlumno
    struct DatosAlumno{
        string nombre;
        string email;
        string dni;
    }
    
    /// Acceder a los datos de un alumno dada su dirección
    mapping(address => DatosAlumno) public datosAlumno;
    
    /// Array con las direcciones de los alumnos matriculados
    address[] public matriculas;
    
    /// Tipos de notas: no presentado, nota entre 0 y 10, y matricula
    enum TipoNota { NP, AP, MH }
    
    /**
     * Datos de una nota.
     * La calificación está multiplicada por 100 porque no hay decimales
     */
     struct Nota {
        TipoNota tipo;
        uint calificacion;
    }
    
    // Dada pa direccion de un alumno, y el indice de la evaluación, devuelve
    // la nota del alumno
    mapping (address => mapping (uint => Nota)) public calificaciones;
    
    /**
     * constructor
     * 
     * @param _nombre Nombre de la asignatura
     * @param _curso Curso académico
     */
     constructor(string memory _nombre, string memory _curso) {
         
        bytes memory bn = bytes(_nombre);
        require(bn.length != 0, "El nombre de la asignatura no puede ser vacio");
         
        bytes memory bc = bytes(_curso);
        require(bc.length != 0, "El curso academico de la asignatura no puede ser vacio");
         
        nombre = _nombre;
        curso = _curso;
        profesor = msg.sender;
        owner = msg.sender;
        cerrada = false;
    }
    
    /**
     * Metodo para consultar el nombre de la asignatura
     * 
     * @return nombre El nombre de la asignatura
    */
    function getNombre() public view returns (string memory){
        return nombre;
    }
     
    /**
     * Metodo para consultar el curso de la asignatura
     * 
     * @return curso El curso de la asignatura
    */
    function getCurso() public view returns (string memory){
        return curso;
    }
     
    /**
     * Metodo para consultar la direccion del propietario del contrato
     * 
     * @return owner Direccion del propietario del contrato
    */
    function getOwner() public view returns (address){
        return owner;
    }
    
    /**
     * Devuelve el nombre de un profesor en base a su Direccion
     * 
     * @param dirProfesor Direccion de usuario del profesor
     * @return nombre Nombre del profesor
     */
     function getNombreProfesor(address dirProfesor) public view returns (string memory){
         
         string memory nombreProfesor = datosProfesor[dirProfesor];
         bytes memory bnp = bytes(nombreProfesor);
         require(bnp.length != 0, "La direccion de usuario del profesor no existe");
         return datosProfesor[dirProfesor];
     }
     
     /**
      * Devuelve los datos de un alumno
      * 
      * @param dirAlumno Direccion del alumno
      * @return datos del alumno
      */
      function getDatosAlumno(address dirAlumno) public view returns (DatosAlumno memory){
          return datosAlumno[dirAlumno];
      }
      
    /**
     * Devuelve la calificacion de un alumno
     * 
     * @param dirAlumno direccion de un alumno
     * @param indice indice de la evaluacion
     * @return Nota del alumno
     */
     function getNota(address dirAlumno, uint indice) public view returns (Nota memory){
         return calificaciones[dirAlumno][indice];
     } 
     
    /**
      * Cambiar el valor de la propiedad coordinador
      * 
      * @param coord Direccion del coordinador
    */
    function setCoordinador(address coord) soloOwner soloAbierta public {
        coordinador = coord;
    }
      
    /**
     * Metodo para cerrar una asignatura
     * 
    */
    function cerrar() soloCoordinador public{
        cerrada = true;
    }
    
    /**
     * Añadir un profesor a una asignatura.No puede ser vacio el nombre, no se puede añadir un profesor varias veces,
     * y da igual que varios profesores tengan el mismo nombre
     * 
     * @param dirProfesor direccion de usuario del profesor
     * @param nombreProfesor Nombre del profesor
    */
    function addProfesor(address dirProfesor, string memory nombreProfesor) soloOwner soloAbierta public {
        
        bytes memory bn = bytes(nombreProfesor);
        require(bn.length != 0, "El nombre del profesor no puede estar vacio");
        require(cerrada = false, "No se puede anadir un profesor a una asignatura cerrada");
        
        string memory existeProf = getNombreProfesor(dirProfesor);
        bytes memory bep = bytes(existeProf);
        require(bep.length == 0, "No se puede anadir a un profesor varias veces");
        
        profesores.push(dirProfesor);
        datosProfesor[dirProfesor] = nombreProfesor;
    }
    
    /**
     * Numero de profesores anadidos
     * 
     * @return Numero de profesores anadidos
     */
    function profesoresLength() public view returns (uint) {
        return profesores.length;
    }
    
    
     
    /**
     * El numero de evaluaciones creadas
     * 
     * @return El numero de evaluaciones creadas
     */
     function evaluacionesLength () public view returns (uint) {
        return evaluaciones.length;
    }
    
    /**
     * Crear una prueba de evaluación de la asignatura. Por ejemplo, el primer parcial, o la
     * practica 1
     * 
     * Las evaluaciones se meterán en el array evaluaciones, y nos referimos a ellas por su posición en el array
     * 
     * @param _nombre El nombre de la evaluación
     * @param _fecha La fecha de evaluación (segundos desde el 1/1/1970)
     * @param _puntos Los puntos que proporciona a la nota final
     * 
     * @return La posición en el array de evaluaciones
     */
     function creaEvaluacion (string memory _nombre, uint _fecha, uint _puntos) soloAbierta soloCoordinador public returns (uint) {
        
        //require(cerrada == false, "La asignatura esta cerrada y no se puede crear una evaluacion");
        
        bytes memory bn = bytes(_nombre);
        require(bn.length != 0, "El nombre de la evaluacion no puede ser vacio");
        
        evaluaciones.push (Evaluacion (_nombre, _fecha, _puntos));
        return evaluaciones.length - 1;
    }
    
    /**
     * El numero de alumnos matrículados
     * 
     * @return El numero de alumnos matriculados
     */
     function matriculasLenght () public view returns (uint) {
        return matriculas.length;
    }
    
    /**
     * Los alumnos pueden automatriculare con el metodo automatrícula
     * 
     * Impedir que se pueda meter un nombre vacío
     * 
     * @param _nombre El nombre del alumno
     * @param _email El email del alumno
     */
    function automatricula (string memory _nombre, string memory _email, string memory _dni) soloAbierta noMatriculados public {
        
        //require(cerrada == false, "La asignatura esta cerrada y no se pueden matricular nuevos alumnos");
        
        bytes memory bn = bytes(_nombre);
        require(bn.length != 0, "El nombre no puede ser vacio");
        bytes memory bdni = bytes(_dni);
        require(bdni.length != 0, "El dni no puede ser vacio");
        
        string memory existeDNI = getDatosAlumno(msg.sender).dni;
        bytes memory bedni = bytes(existeDNI);
        require(bedni.length == 0, "El dni ya existe");
        
        DatosAlumno memory datos = DatosAlumno(_nombre,_email,_dni);
        
        datosAlumno[msg.sender] = datos;
        
        matriculas.push(msg.sender);
    
    }
    
    /**
     * Permite a un alumno obtener sus propios datos
     * 
     * @return _nombre El nombre del alumno que invoca el metodo
     * @return _email El email del alumno que invoca el metodo
     * @return _dni El dni del alumno que invoca el metodo
    */
    function quienSoy() soloMatriculados public view returns (string memory _nombre, string memory _email, string memory _dni){
        DatosAlumno memory datos = datosAlumno[msg.sender];
        _nombre = datos.nombre;
        _email = datos.email;
        _dni = datos.dni;
    }
    
    /**
     * Poner la nota de una alumno en una evaluación
     * 
     * @param alumno La dirección del alumno
     * @param evaluacion El índice de una evaluación en el array de evaluaciones
     * @param tipo tipo de nota
     * @param calificacion La calificación, multiplicada por 100 porque no hay decimales
     */
    function califica(address alumno, uint evaluacion, TipoNota tipo, uint calificacion) soloProfesor soloAbierta public{
        
        //require(cerrada == false, "La asignatura esta cerrada y no se pueden poner notas");
        
        require(estaMatriculado(alumno), "Solo se pueden calificar a un alumno matriculado");
        require(evaluacion < evaluaciones.length, "No se puede calificar una evaluacion que no existe");
        require(calificacion <= 100, "No se puede calificar con una nota superior a la maxima permitida");
        
        Nota memory nota = Nota(tipo, calificacion);
        
        calificaciones[alumno][evaluacion] = nota;
    }
    
    /**
     * Consulta si una direccion pertenece a un alumno matriculado
     * 
     * @param alumno La direccion de un alumno
     * 
     * @return true si es un alumno matriculado
     */
     function estaMatriculado(address alumno) private view returns (bool){
         
         string memory _nombre = datosAlumno[alumno].nombre;
         bytes memory b = bytes(_nombre);
         return b.length != 0;
     }
     
     /**
      * Devuelve el tipo de nota y la calificación que ha sacado el alumno que invoca el metodo en la evaluacion pasada como parametro
      * 
      * @param evaluacion Indice de una evaluacion en el array de evaluaciones
      * 
      * @return tipo El tipo de nota que ha sacado el alumno
      * @return calificacion La calificacion que ha sacado el alumno
      */
      function miNota(uint evaluacion) soloMatriculados public view returns (TipoNota tipo, uint calificacion){
          
          require(evaluacion < evaluaciones.length, "El indice de la evaluacion no existe");
          Nota memory nota = calificaciones[msg.sender][evaluacion];
          
          tipo = nota.tipo;
          calificacion = nota.calificacion;
      }
    
    
    /**
     * Modificador para que una funcion solo la pueda ejecutar el profesor.
     *
     * Se usa en creaEvaluacion y en califica.
     */
     modifier soloProfesor() {
         require(msg.sender == profesor, "Solo permitido al profesor");
         _;
     }
     
     /**
     * Modificador para que una funcion solo la pueda un alumno matriculado.
     *
     */
     modifier soloMatriculados(){
         require(estaMatriculado(msg.sender), "Solo permitido a alumnos matriculados");
         _;
     }
     
     /**
      * Modificador para que una funcion solo la pueda ejecutar un alumno no matriculado aun
      */
     modifier noMatriculados(){
         require(!estaMatriculado(msg.sender), "Solo permitio a alumnos no matriculados");
         _;
     }
     
     /**
      * Modificador para que una funcion solo la pueda ejecutar el owner del contrato
      * 
      * Se usa en setCoordinador y addProfesor
      */
     modifier soloOwner(){
         require(msg.sender == owner, "Solo permitido al owner del contrato");
         _;
     }
     
     /**
      * Modificador para que una funcion solo la pueda ejecutar el coordinador de la asignatura
      * 
      * Se usa en cerrar y crearEvaluacion
      */
     modifier soloCoordinador(){
         require(msg.sender == coordinador, "Solo permitido al coordinador de la asignatura");
         _;
     }
     
     /**
      * Modificador para que una funcion solo pueda llamarse si la asignatura no esta cerrada
      * 
      * Se usa en setCoordinador, addProfesor, automatricula, crearEvaluacion, califica
      */
      modifier soloAbierta(){
          require(cerrada == false, "Solo permitido si la asignatura esta abierta");
          _;
      }
     
     /**
      * No se permite la recepcion de dinero
      */
      receive() external payable{
          revert("No se permite la recepcion de dinero");
      }

}
