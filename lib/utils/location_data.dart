/// Données des localisations et sous-localisations de Tunisie
class LocationData {
  static const Map<String, List<String>> locations = {
    'Tunis': [
      'Centre Tunis',
      'Bab Bhar',
      'Médina',
      'Lac 1',
      'Lac 2',
      'El Menzah',
      'Ariana',
    ],
    'Monastir': [
      'Centre Monastir',
      'Skanes',
      'Khniss',
      'Teboulba',
      'Moknine',
      'Bekalta',
    ],
    'Mahdia': [
      'Centre Mahdia',
      'Hiboun',
      'Ksour Essef',
      'El Jem',
      'Chorbane',
      'Melloulech',
    ],
    'Sousse': [
      'Centre Sousse',
      'Hammam Sousse',
      'Port El Kantaoui',
      'Kalaa Kebira',
      'Msaken',
      'Enfidha',
    ],
    'Sfax': [
      'Centre Sfax',
      'Sfax Ville',
      'Sakiet Ezzit',
      'Sakiet Eddaier',
      'El Ain',
      'Thyna',
    ],
    'Nabeul': [
      'Centre Nabeul',
      'Hammamet',
      'Kelibia',
      'Menzel Temime',
      'Korba',
      'Grombalia',
    ],
    'Bizerte': [
      'Centre Bizerte',
      'Menzel Bourguiba',
      'Mateur',
      'Ras Jebel',
      'Sejnane',
    ],
    'Gabès': [
      'Centre Gabès',
      'Mareth',
      'Matmata',
      'El Hamma',
      'Menzel El Habib',
    ],
  };

  static List<String> get cities => locations.keys.toList()..sort();

  static List<String> getSubLocations(String city) {
    return locations[city] ?? [];
  }
}
