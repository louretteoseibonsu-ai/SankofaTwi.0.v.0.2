from PIL import Image, ImageDraw, ImageFont
S=3
def R(v): return int(round(v*S))
CREAM=(243,236,221,255); CHAR=(43,43,45,255); TERRADEEP=(190,82,53,255); TERRA=(226,114,91,255)
GOLD=(227,169,44,255); RED=(155,45,42,255); GREEN=(46,107,59,255); SILVER=(201,204,209,255)
GLASS=(191,224,234,255); WHITE=(255,255,255,255); SLATE=(90,94,99,255); DARKW=(58,47,43,255)
FD="/usr/share/fonts/truetype/lato"
def F(sz,b=True): return ImageFont.truetype(f"{FD}/Lato-{'Bold' if b else 'Regular'}.ttf", R(sz))
W,H=380,250

def rr(d,x0,y0,x1,y1,rad,fill=None,outline=None,w=0):
    d.rounded_rectangle([R(x0),R(y0),R(x1),R(y1)],radius=R(rad),fill=fill,outline=outline,width=R(w) if w else 0)
def ln(d,x1,y1,x2,y2,fill,w):
    d.line([R(x1),R(y1),R(x2),R(y2)],fill=fill,width=R(w))
def circ(d,cx,cy,r,fill=None,outline=None,w=0):
    d.ellipse([R(cx-r),R(cy-r),R(cx+r),R(cy+r)],fill=fill,outline=outline,width=R(w) if w else 0)
def ell(d,cx,cy,rx,ry,fill):
    d.ellipse([R(cx-rx),R(cy-ry),R(cx+rx),R(cy+ry)],fill=fill)
def sq(d,x,y,s,fill): d.rectangle([R(x),R(y),R(x+s),R(y+s)],fill=fill)
def ctext(d,cx,y,t,sz,fill):
    f=F(sz); w=d.textlength(t,font=f); d.text((R(cx)-w/2,R(y)),t,font=f,fill=fill)

def kente_row(d,xs,y,cols):
    for i,x in enumerate(xs): sq(d,x,y,10,cols[i%len(cols)])

def body(d,dx=0):
    # shadow
    ell(d,200+dx,222,150,13,(43,43,45,26))
    # roof cap (terracotta) + kente
    rr(d,46+dx,63,350+dx,80,9,fill=TERRADEEP)
    kente_row(d,[58+dx,82+dx,106+dx,252+dx,276+dx,300+dx,324+dx],67,[GOLD,GREEN,CREAM,GREEN,GOLD,RED,GREEN])
    # body
    rr(d,46+dx,70,350+dx,188,26,fill=CREAM,outline=CHAR,w=5)

def wheel_static(d,cx):
    circ(d,cx,202,30,fill=CHAR); circ(d,cx,202,12,fill=SILVER)
def wheel_spin(d,cx):
    circ(d,cx,202,30,fill=CHAR)
    ln(d,cx,186,cx,218,SILVER,4); ln(d,cx-16,202,cx+16,202,SILVER,4)
    ln(d,cx-11,191,cx+11,213,SILVER,4); ln(d,cx-11,213,cx+11,191,SILVER,4)

def windows_two(d,dx=0):
    rr(d,60+dx,106,180+dx,148,8,fill=GLASS,outline=CHAR,w=4); ln(d,120+dx,106,120+dx,148,CHAR,3)
    rr(d,196+dx,106,316+dx,148,8,fill=GLASS,outline=CHAR,w=4); ln(d,256+dx,106,256+dx,148,CHAR,3)

def bumper(d,dx=0):
    rr(d,50+dx,176,346+dx,189,6,fill=CHAR)
    kente_row(d,[58+dx,68+dx,78+dx,88+dx,298+dx,308+dx,318+dx],177,[GOLD,RED,GREEN,GOLD,GREEN,GOLD,RED])

def headlight(d,cx): circ(d,cx,140,9,fill=GOLD,outline=CHAR,w=3)

# ---- IDLE ----
img=Image.new("RGBA",(R(W),R(H)),(0,0,0,0)); d=ImageDraw.Draw(img)
wheel_static(d,112); wheel_static(d,300)
body(d); windows_two(d)
ctext(d,198,161,"Nyame bɛkyerɛ",16,CHAR)
bumper(d); headlight(d,342)
img.save("/sessions/awesome-keen-johnson/mnt/SankofaTwi.0.v.0.2/app/assets/mascot/trotro_idle.png")

# ---- DRIVE ----
img2=Image.new("RGBA",(R(W),R(H)),(0,0,0,0)); d=ImageDraw.Draw(img2)
for yy in (108,138,168):
    ln(d,8,yy,40,yy,SILVER,5)
wheel_spin(d,118); wheel_spin(d,306)
body(d,dx=6); windows_two(d,dx=6)
ctext(d,204,161,"Yɛbɛba bio",16,CHAR)
bumper(d,dx=6); headlight(d,348)
img2.save("/sessions/awesome-keen-johnson/mnt/SankofaTwi.0.v.0.2/app/assets/mascot/trotro_drive.png")

# ---- ARRIVE ----
img3=Image.new("RGBA",(R(W),R(H)),(0,0,0,0)); d=ImageDraw.Draw(img3)
for (cx,cy,r,c) in [(60,34,4,GOLD),(330,28,4,GOLD),(120,20,3.5,TERRA),(270,18,3.5,GREEN),(200,12,3.5,GOLD)]:
    circ(d,cx,cy,r,fill=c)
sq(d,150,24,6,RED); sq(d,240,28,6,GREEN)
wheel_static(d,112); wheel_static(d,300)
body(d)
# single window + open door
rr(d,60,106,178,172,8,fill=GLASS,outline=CHAR,w=4); ln(d,119,106,119,172,CHAR,3)
rr(d,230,102,316,188,8,fill=CHAR); rr(d,236,108,310,182,6,fill=GLASS)
bumper(d); headlight(d,342)
# mission scroll
rr(d,128,124,172,158,4,fill=WHITE,outline=CHAR,w=2.5)
ln(d,136,134,164,134,TERRADEEP,2.5); ln(d,136,142,164,142,SLATE,2)
circ(d,150,151,4.5,fill=GOLD)
img3.save("/sessions/awesome-keen-johnson/mnt/SankofaTwi.0.v.0.2/app/assets/mascot/trotro_arrive.png")

# ---- sprite sheet (horizontal) ----
frames=[img,img2,img3]
sheet=Image.new("RGBA",(R(W)*3,R(H)),(0,0,0,0))
for i,fr in enumerate(frames): sheet.paste(fr,(R(W)*i,0),fr)
sheet.save("/sessions/awesome-keen-johnson/mnt/SankofaTwi.0.v.0.2/app/assets/mascot/trotro_sheet.png")

# preview contact sheet on cream so transparency is visible
prev=Image.new("RGBA",(R(W),R(H)*3+40),(251,248,242,255))
for i,fr in enumerate(frames): prev.alpha_composite(fr,(0,i*(R(H)+20)+10))
prev.convert("RGB").save("/sessions/awesome-keen-johnson/mnt/outputs/trotro_preview.png")
print("done", img.size)
