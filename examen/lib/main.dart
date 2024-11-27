/// Interfaz para un creador de pruebas.
abstract class PruebaFactory {
  Prueba crearPrueba();
}

/// Factory para crear una prueba simple.
class PruebaSimpleFactory implements PruebaFactory {
  final String id;
  final double notaMaxima;

  PruebaSimpleFactory({required this.id, required this.notaMaxima});

  @override
  Prueba crearPrueba() {
    return PruebaSimple(id: id, notaMaxima: notaMaxima);
  }
}

/// Factory para crear una prueba compuesta.
class PruebaCompuestaFactory implements PruebaFactory {
  final String id;
  final double notaMaxima;
  final List<Prueba> subPruebas;
  final bool calcularPorMedia;

  PruebaCompuestaFactory({
    required this.id,
    required this.notaMaxima,
    required this.subPruebas,
    this.calcularPorMedia = true,
  });

  @override
  Prueba crearPrueba() {
    if (subPruebas.isEmpty) {
      throw ArgumentError('Las pruebas compuestas deben tener subpruebas.');
    }
    return PruebaCompuesta(
      id: id,
      notaMaxima: notaMaxima,
      subPruebas: subPruebas,
      calcularPorMedia: calcularPorMedia,
    );
  }
}

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

  double calcularNota();

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
      return 0.0;
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

  void mostrarResultados() {
    for (final alumno in alumnos.values) {
      print('Alumno: ${alumno.nombre}, Nota Final: ${alumno.calcularNotaFinal()}');
    }
  }
}

void main() {
  // Se crea una prueba usando las factories.
  final pruebaSimpleFactory1 = PruebaSimpleFactory(id: 'T1', notaMaxima: 10);
  final pruebaSimpleFactory2 = PruebaSimpleFactory(id: 'T2', notaMaxima: 10);

  final pruebaSimple1 = pruebaSimpleFactory1.crearPrueba();
  final pruebaSimple2 = pruebaSimpleFactory2.crearPrueba();

  pruebaSimple1.notaAlumno = 8.0;
  pruebaSimple2.notaAlumno = 9.0;
  pruebaSimple1.marcarConcluida();
  pruebaSimple2.marcarConcluida();

  final pruebaCompuestaFactory = PruebaCompuestaFactory(
    id: 'PC1',
    notaMaxima: 10,
    subPruebas: [pruebaSimple1, pruebaSimple2],
  );

  final pruebaCompuesta = pruebaCompuestaFactory.crearPrueba();
  pruebaCompuesta.marcarConcluida();

  final alumno = Alumno(nombre: 'Juan');
  alumno.agregarPrueba(pruebaCompuesta);

  final asignatura = Asignatura(nombre: 'Matemáticas');
  asignatura.agregarAlumno(alumno);

  asignatura.mostrarResultados();
}
