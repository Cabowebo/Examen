import 'dart:collection';

/// Clase base para una prueba.
abstract class Prueba {
  final String id;
  final double notaMaxima;
  double? notaAlumno;
  bool concluida;

  Prueba({
    required this.id,
    required this.notaMaxima,
    this.notaAlumno,
    this.concluida = false,
  });

  /// Método para calcular la nota de la prueba.
  double calcularNota();

  /// Marcar como concluida.
  void marcarConcluida() {
    concluida = true;
  }
}

/// Clase para pruebas simples.
class PruebaSimple extends Prueba {
  PruebaSimple({
    required String id,
    required double notaMaxima,
    double? notaAlumno,
  }) : super(id: id, notaMaxima: notaMaxima, notaAlumno: notaAlumno);

  @override
  double calcularNota() {
    return notaAlumno ?? 0.0;
  }
}

/// Clase para pruebas compuestas (media o suma).
class PruebaCompuesta extends Prueba {
  final List<Prueba> subPruebas;
  final bool calcularPorMedia;

  PruebaCompuesta({
    required String id,
    required double notaMaxima,
    required this.subPruebas,
    this.calcularPorMedia = true,
  }) : super(id: id, notaMaxima: notaMaxima);

  @override
  double calcularNota() {
    if (!subPruebas.every((prueba) => prueba.concluida)) {
      return 0.0; // No se puede calcular hasta que todas las subpruebas estén concluidas.
    }

    final sumaNotas = subPruebas.map((prueba) => prueba.calcularNota()).reduce((a, b) => a + b);
    return calcularPorMedia ? (sumaNotas / subPruebas.length) : sumaNotas;
  }

  @override
  void marcarConcluida() {
    if (subPruebas.every((prueba) => prueba.concluida)) {
      super.marcarConcluida();
    }
  }
}

/// Clase para gestionar un alumno y sus pruebas.
class Alumno {
  final String nombre;
  final Map<String, Prueba> pruebas;

  Alumno({
    required this.nombre,
    Map<String, Prueba>? pruebas,
  }) : pruebas = pruebas ?? {};

  void agregarPrueba(Prueba prueba) {
    pruebas[prueba.id] = prueba;
  }

  double calcularNotaFinal() {
    return pruebas.values.map((prueba) => prueba.calcularNota()).reduce((a, b) => a + b);
  }
}

/// Clase para gestionar una asignatura y sus alumnos.
class Asignatura {
  final String nombre;
  final Map<String, Alumno> alumnos;

  Asignatura({
    required this.nombre,
    Map<String, Alumno>? alumnos,
  }) : alumnos = alumnos ?? {};

  void agregarAlumno(Alumno alumno) {
    alumnos[alumno.nombre] = alumno;
  }

  Alumno? obtenerAlumno(String nombre) {
    return alumnos[nombre];
  }

  void mostrarResultados() {
    for (final alumno in alumnos.values) {
      print('Alumno: ${alumno.nombre}, Nota Final: ${alumno.calcularNotaFinal()}');
    }
  }
}

void main() {
  // Crear pruebas simples.
  final prueba1 = PruebaSimple(id: 'T1', notaMaxima: 10, notaAlumno: 8);
  final prueba2 = PruebaSimple(id: 'T2', notaMaxima: 10, notaAlumno: 7);

  // Crear prueba compuesta (media).
  final pruebaCompuesta = PruebaCompuesta(
    id: 'PC1',
    notaMaxima: 10,
    subPruebas: [prueba1, prueba2],
    calcularPorMedia: true,
  );
  prueba1.marcarConcluida();
  prueba2.marcarConcluida();
  pruebaCompuesta.marcarConcluida();

  // Crear un alumno.
  final alumno = Alumno(nombre: 'Juan');
  alumno.agregarPrueba(pruebaCompuesta);

  // Crear una asignatura.
  final asignatura = Asignatura(nombre: 'Matemáticas');
  asignatura.agregarAlumno(alumno);

  // Mostrar resultados.
  asignatura.mostrarResultados();
}
