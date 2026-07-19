String listRefacciones(String busqueda) {
  String filtro = '%$busqueda%';

  return '''
    SELECT * FROM "tipos" 
    WHERE "nombre" LIKE '$filtro' 
    AND id NOT IN (1, 2);
  ''';
}
