class Estudiante {
  const carreras = #{}
  const materiasCursadas = []

  method inscribirseACarrera(carrera) {
    self.validarInscripcionCarrera(carrera)
    carreras.add(carrera)
  }

  method validarInscripcionCarrera(carrera) {
    if (carreras.contains(carrera)) {
      self.error("El estudiante ya esta inscripto a esta carrera")
    }
  }

  method carreras() = carreras

  method laMateriaPerteneceAAlgunaCarrera(unaMateria) {
    return carreras.any({carrera => carrera.lePerteneceLaMateria(unaMateria)})
  }

  method estaInscriptoEn(carrera) {
    return carreras.contains(carrera)
  }

  method finalizarCursadaDeMateria(materia, nota) {
    self.validarMateriaEnCarreras(materia)
    self.validarMateriaAprobada(materia)
    self.validarNota(nota)
    
    const materiaCursada = new HistoriaAcademica(materia = materia, nota = nota)
    materiasCursadas.add(materiaCursada)
    
  }

  method validarMateriaAprobada(materia) {
    if (self.laMateriaEstaAprobada(materia)) {
      self.error("La materia ya se encuentra aprobada")
    }
  }

  method validarMateriaEnCarreras(materia){
    if (not self.laMateriaPerteneceAAlgunaCarrera(materia)) {
      self.error("Esta materia no es valida para cursar")
    }
  }


  method validarNota(nota) {
    if (not nota.between(1, 10)) {
      self.error("La nota no es valida")
    }
  }

  method materiasAprobadas() {
    return materiasCursadas.filter({materia => materia.nota() >= 6})
  }

  method laMateriaEstaAprobada(materia){
    return self.materiasAprobadas().any({materiaCursada => materiaCursada.materia() == materia})
  }

  method cantMateriasAprobadas() {
    return self.materiasAprobadas().size()
  }

  method promedioDeMateriasAprobadasEn(carrera){
    self.validarPromedioDe(carrera)
    return self.materiasAprobadasDe(carrera).sum({materia => materia.nota()}) / self.cantMateriasAprobadasDe(carrera)
  }

  method validarPromedioDe(carrera) {
    if (not self.estaInscriptoEn(carrera) || self.materiasAprobadasDe(carrera).isEmpty()) {
        self.error("El estudiante no está inscripto a esta carrera")
    }
  }

  method materiasAprobadasDe(carrera){
    return self.materiasAprobadas().filter({materiaAprobada => carrera.lePerteneceLaMateria(materiaAprobada.materia())})
  }

  method cantMateriasAprobadasDe(carrera) {
    return self.materiasAprobadasDe(carrera).size()
  }

  method promedioDeMateriasAprobadas() {
    return self.materiasAprobadas().sum({materia => materia.nota()}) / self.cantMateriasAprobadas()
  }

  method validarPromedio() {
    if(self.materiasAprobadas().isEmpty()) {
      self.error("No cuenta con materias aprobadas")
    }
  }

  method registroDeCursadaDeLa(materia) {
    return materiasCursadas.filter({materiaCursada => materiaCursada.materia() == materia})
  }

  method inscribirseAMateria(materia) {
    self.validarMateriaEnCarreras(materia)
    self.validarMateriaAprobada(materia)
    self.validarInscripcionMateria(materia)
    self.validarRequisitosDe(materia)

    materia.anotarA(self)
  }

  method validarInscripcionMateria(materia) {
    if (self.estaCursandoLaMateria(materia)) {
      self.error("Ya te encuentras cursando esta materia")
    }
  }

  method estaCursandoLaMateria(materia) {
    return materia.estudiantes().contains(self)
  }

  method validarRequisitosDe(materia) {
    if(not self.cumpleCorrelativas(materia)) {
      self.error("No te puedes anotar a esta materia porque faltan cursar las correlativas")
    }
  }

  method cumpleCorrelativas(materia){
    return materia.requisitos().all({materiaReq => self.laMateriaEstaAprobada(materiaReq)})
  }

  method puedeCursarLaMateria(materia) {
    return self.laMateriaPerteneceAAlgunaCarrera(materia) && not self.laMateriaEstaAprobada(materia) && not self.estaCursandoLaMateria(materia) && self.cumpleCorrelativas(materia)
  }

  method materiasHabilitadasDe(carrera) {
    return carrera.materiasHabilitadas(self)
  }
}

class Carrera {
  const property materias = #{}

  method lePerteneceLaMateria(nombreMateria) {
    return materias.contains(nombreMateria)
  }

  method materiasHabilitadas(estudiante) {
    return materias.filter({materiaActual => estudiante.puedeCursarLaMateria(materiaActual)})
  }
}

class HistoriaAcademica {
  var property nota
  var property materia
}

class Materia {
  var requisitos = #{}
  const estudiantes = #{}

  method agregarRequisitos(_value) {
    requisitos.add(_value)
  }

  method requisitos() = requisitos

  method anotarA(estudiante) {
    estudiantes.add(estudiante)
  }

  method estudiantes() = estudiantes 
}