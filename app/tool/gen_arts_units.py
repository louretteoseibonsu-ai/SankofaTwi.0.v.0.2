#!/usr/bin/env python3
"""Draft generator for Arts & Media units (unit_052..unit_064).
10 challenges auto-generated per unit from its glossary; all review_required.
NOTE: modern/media topics use accepted Ghanaian loanwords — review carefully.
Run from app/:  python3 tool/gen_arts_units.py
"""
import json, os, random
random.seed(19)
OUT = "assets/content"

UNITS = [
    ("unit_052", "Instruments", "Nnwontodeɛ", "twene", "twe-ne",
     "instruments — the drums, flutes, and strings of Akan music.",
     "The atumpan ‘talking drums’ can imitate speech and send messages.",
     [("atumpan","talking drums"),("fɔntɔmfrɔm","big drum"),("dɔnnɔ","hourglass drum"),
      ("seperewa","harp-lute"),("atɛntɛbɛn","bamboo flute"),("dawuro","gong"),
      ("nnawuta","twin bells"),("firikyiwa","castanet"),("twene","drum"),("sankuo","lute / guitar")]),
    ("unit_053", "Drumming", "Twene", "twene", "twe-ne",
     "drumming — the heartbeat of every celebration.",
     "The master drummer (ɔkyerɛma) leads; the drums ‘speak’ proverbs.",
     [("twene","drum"),("bɔ twene","to drum"),("atumpan","talking drums"),
      ("ɔkyerɛma","master drummer"),("nnwom","songs"),("asaw","dance"),
      ("agorɔ","performance"),("dawuro","gong"),("dɔnnɔ","hourglass drum"),("anigyeɛ","joy")]),
    ("unit_054", "Dance", "Asaw", "asaw", "a-saw",
     "dance — Adowa, Kete, and modern Azonto.",
     "Adowa is a graceful royal dance; Azonto is the modern street favourite.",
     [("asaw","dance"),("saw","to dance"),("adowa","Adowa (traditional dance)"),
      ("kete","Kete (royal dance)"),("azonto","Azonto (modern dance)"),("agorɔ","performance"),
      ("nnwom","music"),("huruw","to jump"),("nan","leg / foot"),("anigyeɛ","fun")]),
    ("unit_055", "Storytelling", "Anansesɛm", "anansesɛm", "a-nan-se-sɛm",
     "storytelling — the tales of Kwaku Ananse the spider.",
     "A teller calls ‘Agoo!’ and the audience replies ‘Amee!’ before the tale begins.",
     [("anansesɛm","folktale"),("Ananse","Ananse the spider"),("asɛm","story / matter"),
      ("abakɔsɛm","history"),("nyansa","wisdom"),("tete","ancient / of old"),
      ("kyerɛ","to teach"),("tie","to listen"),("agoo","call to start a tale"),("amee","the reply")]),
    ("unit_056", "Poetry", "Anwonsɛm", "anwonsɛm", "a-nwon-sɛm",
     "poetry — praise poems (apae) and the beauty of words.",
     "Court poets recite apae (appellations) to honour a chief.",
     [("anwonsɛm","poetry"),("apae","praise poetry"),("nnwom","songs"),
      ("kasakoa","figurative speech"),("twerɛ","to write"),("kenkan","to read"),
      ("nsɛm","words"),("nyansa","wisdom"),("ɛbɛ","proverb"),("kasa","speech")]),
    ("unit_057", "Theatre", "Agorɔdie", "agorɔ", "a-go-rɔ",
     "theatre — from ‘concert party’ to the modern stage.",
     "‘Concert party’ is Ghana’s classic travelling comic theatre.",
     [("agorɔ","drama / play"),("concert","concert party"),("agorɔdifoɔ","actors"),
      ("ɔhwɛfoɔ","audience"),("nnwom","songs"),("asaw","dance"),
      ("kasa","dialogue"),("anigyeɛ","entertainment"),("sini","show / film"),("baabi","venue")]),
    ("unit_058", "Television", "Tiivii", "tiivii", "tii-vii",
     "television — watching shows and the news.",
     "‘Merehwɛ tiivii’ = I’m watching TV.",
     [("tiivii","television"),("hwɛ","to watch"),("sini","film / show"),
      ("amanneɛbɔ","news"),("agorɔ","programme"),("nnwom","music"),
      ("ɔhwɛfoɔ","viewers"),("anigyeɛ","entertainment"),("berɛ","time"),("nsɛm","topics")]),
    ("unit_059", "Radio", "Radio", "radio", "ra-dio",
     "radio — listening in for news and music.",
     "Local FM stations mix highlife, news, and lively call-ins.",
     [("radio","radio"),("tie","to listen"),("amanneɛbɔ","news"),("nnwom","songs"),
      ("kasa","to speak"),("ɔkasafoɔ","presenter"),("ɔtiefoɔ","listeners"),
      ("berɛ","time"),("nsɛm","topics"),("anigyeɛ","entertainment")]),
    ("unit_060", "News", "Amanneɛbɔ", "amanneɛbɔ", "a-man-neɛ-bɔ",
     "news — reports, the paper, and the truth.",
     "‘Amanneɛbɔ’ is the announcing of news and matters of the nation.",
     [("amanneɛbɔ","news"),("kaseɛbɔ","report"),("asɛm","story / matter"),
      ("nsɛm","matters"),("nokorɛ","truth"),("krataa","newspaper"),
      ("kenkan","to read"),("tie","to hear"),("berɛ","time"),("ɔman","nation")]),
    ("unit_061", "Photography", "Mfoni", "mfoni", "m-fo-ni",
     "photography — taking pictures and keeping memories.",
     "‘Twa me mfoni’ = take my photo.",
     [("mfoni","photo / picture"),("kamera","camera"),("twa mfoni","to take a photo"),
      ("mfonitwafoɔ","photographer"),("hann","light"),("animu","face"),
      ("kae","keepsake / memory"),("baabi","location"),("ahoɔfɛ","beauty"),("adeɛ","the subject")]),
    ("unit_062", "Kente & Cloth", "Kente", "kente", "ken-te",
     "kente — Ghana’s woven cloth, and its colours.",
     "Each kente colour carries meaning: gold for royalty, green for growth.",
     [("kente","kente cloth"),("ntoma","cloth"),("nwene","to weave"),
      ("ɔnwenfoɔ","weaver"),("adwinneɛ","design / craft"),("asaawa","thread"),
      ("kɔkɔɔ","red"),("sikakɔkɔɔ","gold"),("tuntum","black"),("fitaa","white")]),
    ("unit_063", "Visual Art", "Adwinneɛ", "adwinneɛ", "a-dwin-neɛ",
     "visual art — craft, carving, and colour.",
     "The ‘ɔdwumfoɔ’ (artisan) works wood, metal, and cloth into art.",
     [("adwinneɛ","art / craft"),("ɔdwumfoɔ","artisan"),("mfoni","picture"),
      ("ahoɔfɛ","beauty"),("adwene","design / idea"),("dua","wood"),
      ("dadeɛ","metal"),("ntoma","cloth"),("kɔkɔɔ","red"),("tuntum","black")]),
    ("unit_064", "Social Media", "Intanɛt", "intanɛt", "in-ta-nɛt",
     "social media — sharing online with friends.",
     "Share a photo: ‘Kyɛ mfoni no.’ Loanwords are common here.",
     [("intanɛt","internet"),("fɔn","phone"),("nkra","message"),("mfoni","photo"),
      ("kyɛ","to share"),("hwɛ","to view"),("adamfoɔ","friend / follower"),
      ("kasa","to chat"),("amanneɛbɔ","news"),("berɛ","time")]),
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
    return {"prompt": prompt, "type": "recall", "options": options, "correct_index": idx}

for (uid, title, sub, head, pron, gloss_txt, culture, gl) in UNITS:
    doc = {
        "unit_id": uid, "unit_title": title, "review_required": True,
        "review_note": "AI-drafted vocabulary (some modern loanwords) — verify Twi with a native speaker before release.",
        "vocabulary_spotlight": {
            "headword": head, "gloss": gloss_txt,
            "phonetic_bridge": {"pronunciation": pron},
            "example_sentences": [", ".join(t for (t, _) in gl[:3]) + "."],
            "culture_note": culture,
        },
        "grammar_mechanics": {
            "focus": f"Talking about {title.lower()}",
            "explanation": "Key vocabulary: " + ", ".join(f"{t} ({e})" for (t, e) in gl) + ".",
            "patterns": [f"{t} = {e}" for (t, e) in gl[:3]],
        },
        "lineage_challenges": [challenge(gl, i) for i in range(len(gl))],
        "glossary": [{"twi": t, "en": e} for (t, e) in gl],
    }
    with open(os.path.join(OUT, f"{uid}.json"), "w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, indent=2)
    print("wrote", uid, "-", title)
print("done:", len(UNITS), "units")
