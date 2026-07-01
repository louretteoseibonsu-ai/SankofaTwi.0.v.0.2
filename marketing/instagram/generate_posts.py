#!/usr/bin/env python3
"""Sankofa Twi — Instagram post generator (4 pillars, 3x3 launch grid)."""
from PIL import Image, ImageDraw, ImageFont, ImageChops
import os

CHAR=(43,43,45);   CREAM=(237,228,211); TERRA=(190,82,53)
GOLD=(227,169,44); RED=(155,45,42);     GREEN=(46,107,59)
TERRACOTTA=(226,114,91); SLATE=(120,126,133)
KENTE=[GOLD,RED,GREEN,CHAR,TERRACOTTA]
S=1080
FD="/usr/share/fonts/truetype"
POP_B=f"{FD}/google-fonts/Poppins-Bold.ttf"
LATO=f"{FD}/lato/Lato-Regular.ttf"; LATO_B=f"{FD}/lato/Lato-Bold.ttf"
LATO_L=f"{FD}/lato/Lato-Light.ttf"; LATO_BLK=f"{FD}/lato/Lato-Black.ttf"
LATO_IT=f"{FD}/lato/Lato-Italic.ttf"
GLYPH_DIR="/tmp/glyphs"; ICON="../../app/assets/icon/app_icon_foreground.png"
def F(p,s): return ImageFont.truetype(p,s)

def kente_bar(d,x,y,w,h,unit=44):
    i=0;cx=x
    while cx<x+w: d.rectangle([cx,y,min(cx+unit,x+w),y+h],fill=KENTE[i%5]);cx+=unit;i+=1
def tracked(d,pos,text,font,fill,tracking=6,anchor_center=None):
    x,y=pos
    if anchor_center is not None:
        tw=sum(d.textlength(c,font=font)+tracking for c in text)-tracking; x=anchor_center-tw/2
    for c in text: d.text((x,y),c,font=font,fill=fill); x+=d.textlength(c,font=font)+tracking
def center(d,cx,y,t,f,fill): d.text((cx-d.textlength(t,font=f)/2,y),t,font=f,fill=fill)
def wrap(d,text,font,maxw):
    words=text.split();lines=[];cur=""
    for w in words:
        t=(cur+" "+w).strip()
        if d.textlength(t,font=font)<=maxw:cur=t
        else:lines.append(cur);cur=w
    if cur:lines.append(cur)
    return lines
def center_block(d,cx,y,lines,font,fill,lh):
    for ln in lines: center(d,cx,y,ln,font,fill);y+=lh
    return y
def recolor(png,color):
    im=Image.open(png).convert("RGBA");a=im.getchannel("A")
    o=Image.new("RGBA",im.size,color+(0,));o.putalpha(a);return o
def brand_glyph(color):
    fg=Image.open(ICON).convert("RGBA");L=fg.convert("L");sa=fg.getchannel("A")
    op=sa.point(lambda p:255 if p>127 else 0);lo,hi=95,155
    a=L.point(lambda p:255 if p<=lo else (0 if p>=hi else int(255*(hi-p)/(hi-lo))))
    a=ImageChops.multiply(a,op);g=Image.new("RGBA",fg.size,color+(0,));g.putalpha(a)
    return g.crop(a.getbbox())
def paste_fit(base,glyph,cx,cy,box):
    gw,gh=glyph.size;sc=min(box/gw,box/gh);nw,nh=int(gw*sc),int(gh*sc)
    base.alpha_composite(glyph.resize((nw,nh),Image.LANCZOS),(int(cx-nw/2),int(cy-nh/2)))
def frame(bg):
    img=Image.new("RGBA",(S,S),bg+(255,));d=ImageDraw.Draw(img);kente_bar(d,0,0,S,16)
    fg=CREAM if bg==CHAR else CHAR;mut=(200,196,188) if bg==CHAR else SLATE
    paste_fit(img,brand_glyph(GOLD if bg==CHAR else TERRA),70,S-70,58)
    d.text((110,S-92),"SANKOFA TWI",font=F(POP_B,30),fill=fg)
    tracked(d,(112,S-58),"LEARN TWI · AKAN",F(LATO,20),mut,tracking=3)
    rt="sankofaapp.io";f=F(LATO_B,26);d.text((S-70-d.textlength(rt,font=f),S-74),rt,font=f,fill=mut)
    return img,d,fg,mut

def word_of_day(word,pron,meaning,tip,bg=CHAR,fname="wotd"):
    img,d,fg,mut=frame(bg);cx=S/2
    tracked(d,(0,150),"TWI · WORD OF THE DAY",F(LATO_B,30),TERRA if bg==CREAM else GOLD,8,cx)
    d.line([cx-40,205,cx+40,205],fill=TERRA,width=4)
    fs=180
    while fs>90 and d.textlength(word,font=F(LATO_BLK,fs))>S-160: fs-=6
    center(d,cx,300,word,F(LATO_BLK,fs),fg)
    center(d,cx,300+fs+20,f"/ {pron} /",F(LATO_IT,44),GOLD if bg==CHAR else TERRA)
    center(d,cx,300+fs+95,meaning,F(LATO,52),fg)
    bx0,bx1,by0=120,S-120,758
    tip_f=F(LATO,30); tip_lines=wrap(d,tip,tip_f,bx1-bx0-68)[:3]
    by1=by0+74+len(tip_lines)*42+18          # auto-height to fit all lines
    d.rounded_rectangle([bx0,by0,bx1,by1],radius=28,outline=TERRA,width=3)
    tracked(d,(bx0+34,by0+26),"CHALE TIP",F(LATO_B,24),TERRA,4)
    yy=by0+74
    for ln in tip_lines: d.text((bx0+34,yy),ln,font=tip_f,fill=fg);yy+=42
    img.convert("RGB").save(f"posts/{fname}.png");return f"posts/{fname}.png"

def adinkra(name,tagline,desc,glyph_png=None,brand=False,bg=CREAM,fname="adinkra"):
    img,d,fg,mut=frame(bg);cx=S/2
    tracked(d,(0,150),"ADINKRA WISDOM",F(LATO_B,30),TERRA if bg==CREAM else GOLD,8,cx)
    d.line([cx-40,205,cx+40,205],fill=TERRA,width=4)
    gcol=GOLD if bg==CHAR else CHAR
    g=brand_glyph(gcol) if brand else recolor(glyph_png,gcol)
    paste_fit(img,g,cx,410,300)
    center(d,cx,600,name,F(POP_B,84),fg)
    center(d,cx,710,f"“{tagline}”",F(LATO_IT,44),TERRA if bg==CREAM else GOLD)
    center_block(d,cx,795,wrap(d,desc,F(LATO,32),S-220)[:3],F(LATO,32),mut,44)
    img.convert("RGB").save(f"posts/{fname}.png");return f"posts/{fname}.png"

def culture(title,rows,footnote,bg=CHAR,fname="culture"):
    img,d,fg,mut=frame(bg);cx=S/2
    tracked(d,(0,150),"CULTURE NOTE",F(LATO_B,30),TERRA if bg==CREAM else GOLD,8,cx)
    d.line([cx-40,205,cx+40,205],fill=TERRA,width=4)
    y=270
    for ln in wrap(d,title,F(POP_B,66),S-180): center(d,cx,y,ln,F(POP_B,66),fg);y+=82
    y+=30
    for left,right in rows:
        d.text((160,y),left,font=F(LATO_B,40),fill=GOLD if bg==CHAR else TERRA)
        rf=F(LATO,40);d.text((S-160-d.textlength(right,font=rf),y),right,font=rf,fill=fg)
        d.line([160,y+58,S-160,y+58],fill=(70,70,72) if bg==CHAR else (215,208,193),width=2);y+=78
    center(d,cx,y+30,footnote,F(LATO_IT,34),TERRA if bg==CREAM else GOLD)
    img.convert("RGB").save(f"posts/{fname}.png");return f"posts/{fname}.png"

def intro(fname="00_intro"):
    img,d,fg,mut=frame(CHAR);cx=S/2
    paste_fit(img,brand_glyph(GOLD),cx,360,300)
    center(d,cx,560,"Akwaaba.",F(POP_B,120),CREAM)
    center(d,cx,710,"Learn Twi. Reclaim your roots.",F(LATO_L,46),CREAM)
    label="JOIN THE BETA  ·  sankofaapp.io";f=F(LATO_B,32);tw=d.textlength(label,font=f)
    d.rounded_rectangle([cx-tw/2-40,812,cx+tw/2+40,884],radius=36,fill=TERRA)
    d.text((cx-tw/2,830),label,font=f,fill=(255,255,255))
    img.convert("RGB").save(f"posts/{fname}.png");return f"posts/{fname}.png"

os.makedirs("posts",exist_ok=True);paths=[]
paths.append(intro("00_intro"))
paths.append(adinkra("Sankofa","Go back and fetch it.",
    "Learn from the past to build the future. From the proverb: it is not taboo to return for what you left behind.",
    brand=True,bg=CREAM,fname="01_adinkra_sankofa"))
paths.append(word_of_day("Akwaaba","ah-KWAA-ba","Welcome",
    "The first word you'll hear at the airport. Say it back with a smile.",bg=CHAR,fname="02_wotd_akwaaba"))
paths.append(culture("What's your Akan day name?",
    [("Monday","Kwadwo / Adwoa"),("Wednesday","Kwaku / Akua"),("Friday","Kofi / Afua"),("Saturday","Kwame / Ama")],
    "Find your kra din in the app.",bg=CREAM,fname="03_culture_daynames"))
paths.append(adinkra("Gye Nyame","Except God.",
    "The most beloved Adinkra symbol — the omnipotence of God. It even features on Ghana's 200 cedi note.",
    glyph_png=f"{GLYPH_DIR}/gyenyame.png",bg=CHAR,fname="04_adinkra_gyenyame"))
paths.append(word_of_day("Medaase","meh-DAA-si","Thank you",
    "Add 'paa' for extra warmth: Medaase paa = thank you very much.",bg=CREAM,fname="05_wotd_medaase"))
paths.append(word_of_day("Ɛte sɛn?","eh-TEH-sen","How are you?",
    "Reply 'Ɛyɛ' (eh-YEH) — 'I'm good.' Your first full exchange.",bg=CHAR,fname="06_wotd_etesen"))
paths.append(adinkra("Dwennimmen","Strength in humility.",
    "The ram's horns: even the strong stay humble. It anchors the University of Ghana's crest.",
    glyph_png=f"{GLYPH_DIR}/dwennimmen.png",bg=CREAM,fname="07_adinkra_dwennimmen"))
paths.append(culture("Greet like a local",
    [("Maakye","good morning"),("Maaha","good afternoon"),("Maadwo","good evening")],
    "One greeting a day. You've got this.",bg=CHAR,fname="08_culture_greetings"))

cell=360;sheet=Image.new("RGB",(cell*3+40,cell*3+40),(255,255,255))
for i,p in enumerate(paths):
    im=Image.open(p).resize((cell-8,cell-8));r,c=divmod(i,3);sheet.paste(im,(10+c*cell+4,10+r*cell+4))
sheet.save("contact_sheet.png");print("posts:",len(paths))
