class FormValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{3,50}$").hasMatch(value.trim())) {
      return 'Ingresa un nombre válido (letras, 3-50 carac.)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'El teléfono es obligatorio';
    if (!RegExp(r"^[0-9]{9,11}$").hasMatch(value.trim())) {
      return 'Número de teléfono inválido';
    }
    return null;
  }
}