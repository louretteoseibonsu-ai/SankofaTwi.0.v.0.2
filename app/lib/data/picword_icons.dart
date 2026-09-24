/// Registry for the picture-match illustrations (see assets/images/picwords/).
///
/// [kPicwordEntries] is the canonical set — one row per artwork, with its Twi
/// headword, filename stem and English gloss. The picture-match drill uses it
/// two ways: to find which glossary words *have* art, and to pull generic
/// distractor tiles from the shared pool so a unit needs only one illustrated
/// word to earn a picture rung.
///
/// Add a row here when new artwork lands — nothing else needs to change.
library;

const String kPicwordDir = 'assets/images/picwords';

class PicwordEntry {
  final String twi; // headword (lowercase)
  final String stem; // filename stem, e.g. 01_nsuo
  final String en; // English gloss shown on the labelled rung
  const PicwordEntry(this.twi, this.stem, this.en);
}

const List<PicwordEntry> kPicwordEntries = [
  PicwordEntry('nsuo', '01_nsuo', 'water'),
  PicwordEntry('aduane', '02_aduane', 'food'),
  PicwordEntry('kaa', '03_kaa', 'car'),
  PicwordEntry('fie', '04_fie', 'house'),
  PicwordEntry('bankye', '05_bankye', 'cassava'),
  PicwordEntry('borɔdeɛ', '06_borodee', 'plantain'),
  PicwordEntry('nkwan', '07_nkwan', 'soup'),
  PicwordEntry('nam', '08_nam', 'meat'),
  PicwordEntry('nsuomnam', '09_nsuomnam', 'fish'),
  PicwordEntry('sika', '10_sika', 'money'),
  PicwordEntry('akonnwa', '11_akonnwa', 'stool'),
  PicwordEntry('mpaboa', '12_mpaboa', 'sandals'),
  PicwordEntry('ntoma', '13_ntoma', 'cloth'),
  PicwordEntry('dua', '14_dua', 'tree'),
  PicwordEntry('kwadu', '15_kwadu', 'banana'),
  PicwordEntry('abɔfra', '16_abofra', 'child'),
  PicwordEntry('akokɔ', '17_akoko', 'chicken'),
  PicwordEntry('ɔkraman', '18_okraman', 'dog'),
  PicwordEntry('owia', '19_owia', 'sun'),
  PicwordEntry('ɔsram', '20_osram', 'moon'),
  PicwordEntry('ɛna', '21_ena', 'mother'),
  PicwordEntry('agya', '22_agya', 'father'),
  PicwordEntry('nana', '23_nana', 'elder'),
  PicwordEntry('akoma', '24_akoma', 'heart'),
  PicwordEntry('tii', '25_tii', 'tea'),
  PicwordEntry('ogya', '26_ogya', 'fire'),
  PicwordEntry('mako', '27_mako', 'pepper'),
  PicwordEntry('aburoo', '28_aburoo', 'maize'),
  PicwordEntry('kɛntɛn', '29_kenten', 'basket'),
  PicwordEntry('dadesɛn', '30_dadesen', 'pot'),
  PicwordEntry('ekyɛ', '31_ekye', 'hat'),
  PicwordEntry('atadeɛ', '32_atadee', 'clothes'),
  PicwordEntry('osuo', '33_osuo', 'rain'),
  PicwordEntry('mununkum', '34_mununkum', 'cloud'),
  PicwordEntry('twene', '35_twene', 'drum'),
  PicwordEntry('benkum', '36_benkum', 'left'),
  PicwordEntry('nifa', '37_nifa', 'right'),
  PicwordEntry('bɔɔl', '38_bool', 'football'),
  PicwordEntry('nwoma', '39_nwoma', 'book'),
  PicwordEntry('krataa', '40_krataa', 'paper'),
  PicwordEntry('fɔn', '41_fon', 'phone'),
  PicwordEntry('kamera', '42_kamera', 'camera'),
  PicwordEntry('kawa', '43_kawa', 'ring'),
  PicwordEntry('akyɛdeɛ', '44_akyede', 'gift'),
  PicwordEntry('mfoni', '45_mfoni', 'picture'),
  PicwordEntry('kaba', '46_kaba', 'dress'),
];

/// Spelling variants that should reuse an existing icon.
const Map<String, String> _aliases = {
  'bɔɔlo': '38_bool',
  'mfonin': '45_mfoni',
  'kente': '13_ntoma',
  'awia': '19_owia',
  'ataadeɛ': '32_atadee',
};

final Map<String, String> _iconByTwi = {
  for (final e in kPicwordEntries) e.twi.toLowerCase(): e.stem,
  ..._aliases,
};

/// The icon filename stem for [twi], or null if there's no artwork for it.
String? picwordIcon(String twi) => _iconByTwi[twi.trim().toLowerCase()];

/// Full asset path for an icon stem, e.g. `01_nsuo` → assets/images/picwords/01_nsuo.png
String picwordAsset(String stem) => '$kPicwordDir/$stem.png';
