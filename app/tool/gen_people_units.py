#!/usr/bin/env python3
"""Draft generator for People & Culture units (unit_042..unit_051).
10 challenges auto-generated per unit from its glossary; all review_required.
Run from app/:  python3 tool/gen_people_units.py
"""
import json, os, random
random.seed(11)
OUT = "assets/content"

UNITS = [
    ("unit_042", "Extended Family", "Abusua", "abusua", "a-bu-si-a",
     "the wider family — grandparents, uncles, aunts, and clan.",
     "The Akan family is matrilineal (abusua): your mother’s brother (wɔfa) is a key elder.",
     [("abusua","family / clan"),("nana","grandparent"),("nana barima","grandfather"),
      ("nana baa","grandmother"),("wɔfa","maternal uncle"),("sewaa","aunt"),
      ("wɔfaase","nephew / niece"),("nua","sibling"),("mma","children"),("ba","child")]),
    ("unit_043", "Describing People", "Nnipa", "onipa", "o-ni-pa",
     "describing people — looks and simple traits.",
     "Pair with greetings: ‘Ɔyɛ onipa papa’ = He/she is a good person.",
     [("onipa","person"),("barima","man"),("ɔbaa","woman"),("abɔfra","child"),
      ("tenten","tall"),("tiaa","short"),("kɛseɛ","big"),("ketewa","small"),
      ("fɛfɛ","beautiful"),("papa","good / kind")]),
    ("unit_044", "Emotions & Feelings", "Atenka", "anigyeɛ", "a-ni-gye-ɛ",
     "feelings — joy, sadness, and the body’s needs.",
     "Say how you feel: ‘M’ani agye’ = I am happy. ‘Ɛkɔm de me’ = I’m hungry.",
     [("anigyeɛ","joy / happiness"),("awerɛhoɔ","sadness"),("abufuo","anger"),
      ("suro","fear"),("dɔ","love"),("ahotɔ","peace / calm"),("ɛkɔm","hunger"),
      ("sukɔm","thirst"),("brɛ","tiredness"),("yareɛ","sickness")]),
    ("unit_045", "Friendship", "Nnamfoɔ", "adamfoɔ", "a-dam-fo-ɔ",
     "friendship — sharing, helping, and trust.",
     "Call a friend warmly: ‘Me adamfo pa’ = my good friend.",
     [("adamfoɔ","friend"),("nnamfoɔ","friends"),("boa","to help"),("kyɛ","to share"),
      ("tie","to listen"),("dɔ","love"),("hyia","to meet"),("nokorɛ","truth"),
      ("gye di","to trust / believe"),("ka","to say / tell")]),
    ("unit_046", "Respect & Elders", "Obuo", "ɔpanyin", "ɔ-pa-nyin",
     "respect — elders, honour, and manners.",
     "Greet elders first and with both hands; never with the left hand alone.",
     [("ɔpanyin","elder"),("mpanyimfoɔ","elders"),("obuo","respect"),("di ni","to honour"),
      ("kotow","to bow"),("amammerɛ","tradition / custom"),("suban","character"),
      ("tie","to obey / listen"),("nana","elder / grandparent"),("animuonyam","honour")]),
    ("unit_047", "Proverbs & Wisdom", "Mmɛ", "ɛbɛ", "ɛ-bɛ",
     "proverbs (mmɛ) — the language of Akan wisdom.",
     "Elders speak in proverbs. ‘Ɛbɛ’ = a proverb; wisdom (nyansa) is prized.",
     [("ɛbɛ","proverb"),("mmɛ","proverbs"),("anansesɛm","folktale (Ananse story)"),
      ("abakɔsɛm","history"),("nyansa","wisdom"),("kɔkɔbɔ","advice / warning"),
      ("kasakoa","idiom / figurative speech"),("kyerɛ","to teach / show"),
      ("tete","ancient / of old"),("asɛm","a matter / word")]),
    ("unit_048", "Adinkra Meanings", "Adinkra", "adinkra", "a-din-kra",
     "Adinkra — the meanings behind Ghana’s iconic symbols.",
     "Adinkra symbols carry proverbs. Sankofa: go back and fetch it.",
     [("Sankofa","go back and fetch it"),("Gye Nyame","except God"),
      ("Dwennimmen","humility and strength"),("Akoma","patience and love"),
      ("Nkyinkyim","life’s twists and turns"),("Adinkrahene","leadership"),
      ("Fihankra","security and brotherhood"),("Aya","endurance"),
      ("Nyame Dua","God’s presence"),("Akofena","courage")]),
    ("unit_049", "Naming & Day Names", "Kra din", "kra din", "kra-din",
     "Akan day names — your soul name from the day you were born.",
     "Everyone has a kra din. Born on Friday? Kofi (m) or Afua (f).",
     [("Kwadwo","a boy born on Monday"),("Adwoa","a girl born on Monday"),
      ("Kwaku","a boy born on Wednesday"),("Akua","a girl born on Wednesday"),
      ("Yaw","a boy born on Thursday"),("Yaa","a girl born on Thursday"),
      ("Kofi","a boy born on Friday"),("Afua","a girl born on Friday"),
      ("Kwame","a boy born on Saturday"),("Ama","a girl born on Saturday")]),
    ("unit_050", "Chieftaincy", "Ahenni", "ɔhene", "ɔ-he-ne",
     "chieftaincy — chiefs, stools, and royal custom.",
     "The chief (ɔhene) sits on the ancestral stool (ahennwa); the ɔkyeame speaks for him.",
     [("ɔhene","chief / king"),("ɔhemmaa","queen mother"),("ahennwa","royal stool"),
      ("ɔkyeame","linguist / spokesperson"),("ahemfie","palace"),("adehyeɛ","royalty"),
      ("abusuapanyin","family head"),("amanhene","paramount chief"),
      ("akofena","state sword"),("atumpan","talking drums")]),
    ("unit_051", "Spirituality", "Ɔsom", "Onyame", "o-nya-me",
     "spirituality — God, ancestors, and the soul.",
     "Onyame is God; the kra is the soul you receive at birth (your day name).",
     [("Onyame","God"),("Onyankopɔn","the Supreme God"),("ɔbosom","deity"),
      ("nsamanfoɔ","ancestors"),("honhom","spirit"),("ɔkɔmfoɔ","traditional priest"),
      ("mpaeɛ","prayer"),("afɔreɛ","offering / sacrifice"),("kra","soul"),
      ("sunsum","spirit / personality")]),
]

def challenge(gloss, i):
    twi, en = gloss[i]
    if i % 2 == 0:
        prompt = f"How do you say ‘{en}’ in Twi?"; correct = twi
        pool = [t for (t, _) in gloss if t != twi]
    else:
        prompt = f"What does ‘{twi}’ mean?"; correct = en
        pool = [e for (_, e) in gloss if e != en]
    options = random.sample(pool, 3)
    idx = random.randint(0, 3)
    options.insert(idx, correct)
    return {"prompt": prompt, "type": "recall", "options": options,
            "correct_index": idx}

for (uid, title, sub, head, pron, gloss_txt, culture, gl) in UNITS:
    doc = {
        "unit_id": uid, "unit_title": title, "review_required": True,
        "review_note": "AI-drafted vocabulary — verify Twi with a native speaker before release.",
        "vocabulary_spotlight": {
            "headword": head, "gloss": gloss_txt,
            "phonetic_bridge": {"pronunciation": pron},
            "example_sentences": [", ".join(t for (t, _) in gl[:3]) + "."],
            "culture_note": culture,
        },
        "grammar_mechanics": {
            "focus": f"Talking about {title.lower()}",
            "explanation": "Key vocabulary: " +
                ", ".join(f"{t} ({e})" for (t, e) in gl) + ".",
            "patterns": [f"{t} = {e}" for (t, e) in gl[:3]],
        },
        "lineage_challenges": [challenge(gl, i) for i in range(len(gl))],
        "glossary": [{"twi": t, "en": e} for (t, e) in gl],
    }
    with open(os.path.join(OUT, f"{uid}.json"), "w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, indent=2)
    print("wrote", uid, "-", title)
print("done:", len(UNITS), "units")
