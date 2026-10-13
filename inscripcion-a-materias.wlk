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
  method materiasCursadas() = materiasCursadas

  method laMateriaPerteneceAAlgunaCarrera(unaMateria) {
    return carreras.any({carrera => carrera.lePerteneceLaMateria(unaMateria)})
  }

  method estaInscriptoEn(carrera) {
    return carreras.contains(carrera)
  }

  method finalizarCursadaDeMateria(materia, nota) {
    self.validarMateriaEnCarreras(materia)
    self.validarMateriaAprobada(materia)
    self.validarFinDeCursada(materia)
    self.validarNota(nota)
    
    const materiaCursada = new HistoriaAcademica(materia = materia, nota = nota)
    materiasCursadas.add(materiaCursada)
    materia.estudianteTerminaCursada(self)
  }

  method validarFinDeCursada(materia) {
    if (not self.estaCursandoLaMateria(materia)) {
      self.error("No esta cursando esta materia")
    }
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
    return self.materiasAprobadas().any({registroActual => registroActual.materia() == materia})
  }

  method cantMateriasAprobadas() {
    return self.materiasAprobadas().size()
  }

  method promedioDeMateriasAprobadas() {
    self.validarPromedio()
    return self.materiasAprobadas().sum({materia => materia.nota()}) / self.cantMateriasAprobadas()
  }

  method validarPromedio() {
    if(self.materiasAprobadas().isEmpty()) {
      self.error("No cuenta con materias aprobadas")
    }
  }

  method materiasAprobadasDe(carrera){
    return self.materiasAprobadas().filter({materiaAprobada => carrera.lePerteneceLaMateria(materiaAprobada.materia())})
  }

  method cantMateriasAprobadasDe(carrera) {
    return self.materiasAprobadasDe(carrera).size()
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
    if(not self.cumpleRequisitos(materia)) {
      self.error("No te puedes anotar a esta materia porque faltan cursar las correlativas")
    }
  }

  method cumpleRequisitos(materia){
    return materia.cumpleRequisitos(self)
  }

  method puedeCursarLaMateriaDeCarrera(materia, carrera) {
    return self.estaInscriptoEn(carrera) && carrera.lePerteneceLaMateria(materia) && not self.laMateriaEstaAprobada(materia) && not self.estaCursandoLaMateria(materia) && self.cumpleRequisitos(materia)
  }

  method materiasHabilitadasDe(carrera) {
    return carrera.materiasHabilitadas(self)
  }

  method creditosAcumulados() {
    return self.materiasAprobadas().sum({materiaAprobada => materiaAprobada.creditos()})
  }

  method creditosAcumuladosEn(carrera) {
    return self.materiasAprobadasDe(carrera).sum({materiaActual => materiaActual.creditos()})
  }

}

class Carrera {
  const property materias = #{}

  method lePerteneceLaMateria(nombreMateria) {
    return materias.contains(nombreMateria)
  }

  method materiasHabilitadas(estudiante) {
    return materias.filter({materiaActual => estudiante.puedeCursarLaMateriaDeCarrera(materiaActual, self)})
  }

  method materiasDelAño(año) {
    return materias.filter({materiaActual => materiaActual.año() == año})
  }

  method aproboElAño(estudiante, año) {
    return self.materiasDelAño(año).all({materiaActual => estudiante.laMateriaEstaAprobada(materiaActual)})
  }
}

class HistoriaAcademica {
  var property nota
  var property materia

  method creditos() = materia.creditos()
}

class Materia {
  var property requisitos 
  const estudiantes = #{}
  const property creditos
  var property año
  const property carreraALaQuePertenece

  method anotarA(estudiante) {
    estudiantes.add(estudiante)
  }

  method estudiantes() = estudiantes 

  method estudianteTerminaCursada(estudiante){
    estudiantes.remove(estudiante)
  }

  method cumpleRequisitos(estudiante){
    return requisitos.cumpleRequisitos(estudiante, self)
  }
}

class RequiereCorrelativas {
  var property materiasCorrelativas = #{}

  method cumpleRequisitos(estudiante, materia) {
    return materiasCorrelativas.all({materiaActual => estudiante.laMateriaEstaAprobada(materiaActual)})
  }
}

class RequiereCreditos {
  var property creditosMinimos = 0

  method cumpleRequisitos(estudiante, materia) {
    const carrera = materia.carreraALaQuePertenece()
    const materiasAprobadasDeCarrera = estudiante.materiasAprobadasDe(carrera)
    const creditosAcumulados = materiasAprobadasDeCarrera.sum({materiaActual => materiaActual.creditos()})
    return creditosAcumulados >= creditosMinimos
  }
}

object requiereMateriasDelAñoAnterior {
  method cumpleRequisitos(estudiante, materia) {
    const carrera = materia.carreraALaQuePertenece()
    const añoPrevio = materia.año() - 1

    return carrera.aproboElAño(estudiante, añoPrevio)
  }
}

object sinRequisitos {
  method cumpleRequisitos(estudiante, materia) = true
}
