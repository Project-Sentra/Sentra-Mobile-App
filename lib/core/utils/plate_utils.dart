/// Canonical plate key: uppercase letters/digits only ("cag-5124" → "CAG5124").
/// Must match the backend's normalize_plate and the DB trigger, otherwise
/// the LPR camera's "CAG 5124" never matches the registered vehicle.
String normalizePlate(String plate) =>
    plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
