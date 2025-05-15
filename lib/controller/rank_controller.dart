const List<Map<String, dynamic>> rankTiers = [
  {"name": "Principiante", "minScans": 0},
  {"name": "Explorador", "minScans": 2},
  {"name": "Estrella", "minScans": 5},
  {"name": "Campeón", "minScans": 10},
  {"name": "Líder", "minScans": 15},
  {"name": "Maestro", "minScans": 20},
  {"name": "Leyenda", "minScans": 30},
  {"name": "Épico", "minScans": 45},
  {"name": "Divino", "minScans": 60},
  {"name": "Inmortal", "minScans": 80}
];

const List<Map<String, dynamic>> achievements = [
  {"id": "firstScan", "label": "Primer escaneo", "requiredScans": 1},
  {"id": "fiveScans", "label": "5 escaneos únicos", "requiredScans": 5},
  {"id": "tenScans", "label": "10 escaneos únicos", "requiredScans": 10},
  {"id": "twentyScans", "label": "20 escaneos únicos", "requiredScans": 20}
];
