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
    
    // Dada pa dirección de un alumno, y el índice de la evaluación, devuelve
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
    }
    
    /**
     * El número de evaluaciones creadas
     * 
     * @return El número de evaluaciones creadas
     */
     function evaluacionesLength () public view returns (uint) {
        return evaluaciones.length;
    }
    
    /**
     * Crear una prueba de evaluación de la asignatura. Por ejemplo, el primer parcial, o la
     * práctica 3
     * 
     * Las evaluaciones se meterán en el array evaluaciones, y nos referimos a ellas por su posición en el array
     * 
     * @param _nombre El nombre de la evaluación
     * @param _fecha La fecha de evaluación (segundos desde el 1/1/1970)
     * @param _puntos Los puntos que proporciona a la nota final
     * 
     * @return La posición en el array de evaluaciones
     */
     function creaEvaluacion (string memory _nombre, uint _fecha, uint _puntos) soloProfesor public returns (uint) {
        
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
    function automatricula (string memory _nombre, string memory _email) noMatriculados public {
        
        bytes memory b = bytes(_nombre);
        require(b.length != 0, "El nombre no puede ser vacio");
        
        DatosAlumno memory datos = DatosAlumno(_nombre,_email);
        
        datosAlumno[msg.sender] = datos;
        
        matriculas.push(msg.sender);
    
    }
    
    /**
     * Permite a un alumno obtener sus propios datos
     * 
     * @return _nombre El nombre del alumno que invoca el metodo
     * @return _email El email del alumno que invoca el metodo
    */
    function quienSoy() soloMatriculados public view returns (string memory _nombre, string memory _email){
        DatosAlumno memory datos = datosAlumno[msg.sender];
        _nombre = datos.nombre;
        _email = datos.email;
    }
    
    /**
     * Poner la nota de una alumno en una evaluación
     * 
     * @param alumno La dirección del alumno
     * @param evaluacion El índice de una evaluación en el array de evaluaciones
     * @param tipo tipo de nota
     * @param calificacion La calificación, multiplicada por 100 porque no hay decimales
     */
    function califica(address alumno, uint evaluacion, TipoNota tipo, uint calificacion) soloProfesor public{
        
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
      * No se permite la recepcion de dinero
      */
      receive() external payable{
          revert("No se permite la recepcion de dinero");
      }

}
