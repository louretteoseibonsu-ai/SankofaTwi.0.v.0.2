#!/usr/bin/env python3
"""Draft generator for Everyday Life lesson units (unit_029..unit_041).
Each unit: headword + 10-word glossary; the 10 challenges are auto-generated
from the glossary so they are always internally consistent. All units are
flagged review_required:true for native-speaker review.
Run from app/:  python3 tool/gen_everyday_units.py
"""
import json, os, random

random.seed(7)  # stable output
OUT = "assets/content"

# id, title, twi subtitle, headword, pronunciation, gloss, culture_note,
# glossary [(twi, en)] x10
UNITS = [
    ("unit_029", "Food & Ingredients", "Nnuane", "nnuane", "n-nu-a-ne",
     "foods — staples and ingredients you’ll meet every day.",
     "Chale — greet the seller first (open with ‘Maaha’), then name what you want. Stack it with numbers: ‘Mepɛ ɛmo mmienu.’",
     [("ɛmo","rice"),("bankye","cassava"),("borɔdeɛ","plantain"),
      ("nkwan","soup / stew"),("mako","pepper"),("nkateɛ","groundnut"),
      ("kwadu","banana"),("nam","meat"),("nkyene","salt"),("aburoo","maize / corn")]),
    ("unit_030", "Drinks", "Anonneɛ", "nsã", "n-saa",
     "drinks — what to sip, hot or cold.",
     "Ask for water anywhere: ‘Mepɛ nsuo.’ Add ‘a ɛyɛ nwunu’ for cold.",
     [("nsuo","water"),("nufusuo","milk"),("asikyire","sugar"),
      ("tii","tea"),("kɔfe","coffee"),("nsã","palm wine / liquor"),
      ("nom","to drink"),("nsãnom","a drink / beverage"),
      ("nwunu","cold"),("hye","hot")]),
    ("unit_031", "Cooking", "Noa", "noa", "no-a",
     "cooking — the fire, pot, and staples of the kitchen.",
     "Kitchen verbs pair with food words you know: ‘noa nkwan’ = cook soup.",
     [("noa","to cook"),("ogya","fire"),("dadesɛn","cooking pot"),
      ("ngo","cooking oil"),("nkyene","salt"),("mako","pepper"),
      ("nkwan","soup"),("aburoo","maize"),("esiam","flour"),("yam","to grind")]),
    ("unit_032", "At the Market", "Gua", "gua", "gu-a",
     "the market — buying, selling, and bargaining.",
     "Bargaining is expected. Ask ‘Ɛyɛ sɛn?’ then smile and say ‘Te so kakra.’",
     [("gua","market"),("tɔn","to sell"),("tɔ","to buy"),("boɔ","price"),
      ("sika","money"),("adetɔnfoɔ","trader / seller"),("kɛntɛn","basket"),
      ("adwadie","trade / business"),("te so","reduce the price"),
      ("ɛyɛ sɛn","how much is it?")]),
    ("unit_033", "Shopping", "Adetɔ", "sotɔ", "so-tɔ",
     "shopping — the shop, goods, and choosing.",
     "New or old? ‘foforɔ’ vs ‘dada’. Cheap? ‘Ne boɔ nyɛ den.’",
     [("sotɔ","shop / store"),("tɔ","to buy"),("boɔ","price"),("sika","money"),
      ("ɛyɛ sɛn","how much is it?"),("nneɛma","goods / things"),
      ("foforɔ","new"),("dada","old"),("pii","plenty / many"),("kakra","a little")]),
    ("unit_034", "Money & Prices", "Sika", "sika", "si-ka",
     "money — cedis, pesewas, and paying.",
     "Ghana’s money is the cedi (sidi). Paying: ‘Mɛtua.’",
     [("sika","money"),("sidi","cedi"),("pesewa","pesewa"),("boɔ","price"),
      ("tua","to pay"),("ka","debt / bill"),("kakra","a little"),
      ("pii","plenty"),("te so","reduce"),("ɛyɛ sɛn","how much is it?")]),
    ("unit_035", "Clothing", "Ntadeɛ", "ntoma", "n-to-ma",
     "clothing — cloth, dress, and what to wear.",
     "Kente is worn for big occasions; the batakari (smock) is a northern classic.",
     [("ntoma","cloth"),("atadeɛ","clothes / dress"),("mpaboa","footwear"),
      ("ekyɛ","hat / cap"),("kente","kente cloth"),("batakari","smock"),
      ("kaba","kaba (blouse)"),("hyɛ","to wear"),("fitaa","white"),("tuntum","black")]),
    ("unit_036", "Sports", "Agodie", "bɔɔlo", "bɔɔ-lo",
     "sport — the ball, the race, the win.",
     "Football is king. ‘Yɛbɛdi nkonim!’ = We will win!",
     [("bɔɔlo","football / ball"),("mmirika","running / race"),
      ("akansie","competition / match"),("di nkonim","to win"),
      ("tu mmirika","to run"),("bɔ bɔɔlo","to play football"),
      ("ekuo","team / group"),("agodibea","playing field"),
      ("anigyeɛ","fun / enjoyment"),("agorɔ","play")]),
    ("unit_037", "Games", "Agorɔ", "agorɔ", "a-go-rɔ",
     "games — play, win, and enjoy with friends.",
     "Oware is the classic Akan board game — play it with a friend (onua).",
     [("agorɔ","game / play"),("oware","oware (board game)"),
      ("di agorɔ","to play"),("nkonimdie","winning / victory"),
      ("nkogudie","losing / defeat"),("ludo","ludo"),
      ("ahosɛpɛ","enjoyment"),("nnamfoɔ","friends"),
      ("akansie","contest"),("anigyeɛ","fun")]),
    ("unit_038", "Directions", "Akwankyerɛ", "ɔkwan", "ɔ-kwan",
     "directions — left, right, and finding the way.",
     "Lost? ‘Ɛwɔ he?’ = Where is it? Point with the whole hand, not one finger.",
     [("benkum","left"),("nifa","right"),("kɔ animu","go straight / forward"),
      ("dane","to turn"),("akyi","behind"),("animu","front"),("soro","up / top"),
      ("ase","down / under"),("ɔkwan","road / path"),("ɛwɔ he","where is it?")]),
    ("unit_039", "Transport (Trotro)", "Trɔtrɔ", "trɔtrɔ", "trɔ-trɔ",
     "getting around — the trotro, the road, and the fare.",
     "The trotro is Ghana’s shared minibus. Call your stop clearly: ‘Mesi ha!’",
     [("trɔtrɔ","trotro (minibus)"),("kaa","car"),("ɔkwan","road"),
      ("kɔ","to go"),("ba","to come"),("gyina","to stop"),
      ("si","to get down / alight"),("ntɛm","quickly / fast"),
      ("akwantuo","journey / travel"),("sika","fare / money")]),
    ("unit_040", "Weather", "Ewiem", "ewiem", "e-wi-em",
     "weather — sun, rain, and wind.",
     "Two seasons rule: the rains (osutɔberɛ) and the dry Harmattan wind.",
     [("ewiem","weather / sky"),("osuo","rain"),("awia","sunshine"),
      ("mframa","wind"),("awɔ","cold"),("ahuhuro","heat"),
      ("mununkum","cloud"),("anyinam","lightning"),("aprannaa","thunder"),
      ("osu tɔ","it is raining")]),
    ("unit_041", "Daily Routine & Time", "Da biara", "da", "da",
     "daily routine — from waking to sleeping.",
     "Greet by the clock: ‘Maakye’ (morning), ‘Maaha’ (afternoon), ‘Maadwo’ (evening).",
     [("anɔpa","morning"),("awia","afternoon / daytime"),
      ("anwummerɛ","evening"),("anadwo","night"),("sɔre","to get up"),
      ("da","to sleep"),("adidi","to eat (a meal)"),("adwuma","work"),
      ("berɛ","time"),("ɛnnɛ","today")]),
]

def challenge(gloss, i):
    twi, en = gloss[i]
    ask_twi = (i % 2 == 0)  # even: ask for Twi word; odd: ask meaning
    if ask_twi:
        prompt = f"How do you say ‘{en}’ in Twi?"
        correct = twi
        pool = [t for (t, _) in gloss if t != twi]
    else:
        prompt = f"What does ‘{twi}’ mean?"
        correct = en
        pool = [e for (_, e) in gloss if e != en]
    distractors = random.sample(pool, 3)
    options = distractors[:]
    idx = random.randint(0, 3)
    options.insert(idx, correct)
    return {"prompt": prompt, "type": "recall", "options": options,
            "correct_index": idx}

for (uid, title, sub, head, pron, gloss_txt, culture, gl) in UNITS:
    challenges = [challenge(gl, i) for i in range(len(gl))]
    doc = {
        "unit_id": uid,
        "unit_title": title,
        "review_required": True,
        "review_note": "AI-drafted vocabulary — verify Twi with a native speaker before release.",
        "vocabulary_spotlight": {
            "headword": head,
            "gloss": gloss_txt,
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
        "lineage_challenges": challenges,
        "glossary": [{"twi": t, "en": e} for (t, e) in gl],
    }
    with open(os.path.join(OUT, f"{uid}.json"), "w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, indent=2)
    print("wrote", uid, "-", title, f"({len(challenges)} challenges)")
print("done:", len(UNITS), "units")
