import os

# --- מילון צבעים (VGA 8-bit) ---
# נותן לנו שליטה מושלמת על הצללות ותאורה
PALETTE = {
    '.': "FF", # שקוף (Transparent)
    '@': "00", # קו מתאר (Black)
    'R': "E0", # אדום בוהק לתפוח (Red)
    'r': "C0", # אדום כהה להצללה (Dark Red)
    'W': "FF", # השתקפות אור (White)
    'G': "1C", # ירוק דשא בוהק
    'g': "14", # ירוק כהה לדשא
    'Y': "FC", # צהוב-ירוק (גוף הנחש מואר)
    'B': "64", # חום בהיר (עץ)
    'b': "40", # חום כהה (קליפת עץ)
    'C': "1F", # תכלת זוהר (פורטל)
    'c': "03", # כחול עמוק (עומק הפורטל)
    '#': "B6", # אבן אפורה (חומה)
}

# --- ציורי הפיקסל-ארט (16x16 שיורחב אוטומטית ל-32x32) ---
SPRITES = {
    "apple.mif": [
        "................",
        ".......bb.......",
        "......bG........",
        "....@@RR@@......",
        "...@RRRRRR@.....",
        "..@RWWWRRRR@....",
        ".@RWWWWRRRRR@...",
        ".@RRWWRRRRRR@...",
        ".@RRRRRRRRRR@...",
        ".@RRRRRRRRRR@...",
        ".@rRRRRRRRRr@...",
        "..@rRRRRRRr@....",
        "...@@rrrr@@.....",
        ".....@@@@.......",
        "................",
        "................"
    ],
    "head.mif": [
        "................",
        "...@@@@@@@@@....",
        "..@YGGGGGGGY@...",
        ".@YGGGGWWGGGY@..",
        ".@YGGGGWW@GGY@..",
        "@YGGGGGWW@GGGY@.",
        "@YGGGGGGGGGGGY@.",
        "@YGGGGGGGGGGGY@.",
        "@YGGGGGWW@GGGY@.",
        ".@YGGGGWW@GGY@..",
        ".@YGGGGWWGGGY@..",
        "..@YGGGGGGGY@...",
        "...@@@@@@@@@....",
        "................",
        "................",
        "................"
    ],
    "head_bite.mif": [
        "................",
        "...@@@@@@@@@....",
        "..@YGGGGGGGY@...",
        ".@YGGGGWWGGGY@..",
        ".@YGGGGWW@GGY@..",
        "@YGGGGGWW@GGGY@.",
        "@YGGGGGGGG@@@@@.",
        "@YGGGGGG@@RRRRR@",
        "@YGGGGGG@@RRRRR@",
        ".@YGGGGWW@GGY@..",
        ".@YGGGGWWGGGY@..",
        "..@YGGGGGGGY@...",
        "...@@@@@@@@@....",
        "................",
        "................",
        "................"
    ],
    "body.mif": [
        "................",
        "....@@@@@@@@....",
        "..@@YGGGGGGY@@..",
        ".@YYGGGGGGGGYY@.",
        ".@YGGGGGGGGGGY@.",
        "@YGGWWGGGGGGGGY@",
        "@YGGWWGGGGGGGGY@",
        "@YGGGGGGGGGGGGY@",
        "@YGGGGGGGGGGGGY@",
        "@YGGGGGGGGGGGGY@",
        ".@YGGGGGGGGGGY@.",
        ".@YYGGGGGGGGYY@.",
        "..@@YYGGGGYY@@..",
        "....@@@@@@@@....",
        "................",
        "................"
    ],
    "portal.mif": [
        "................",
        "....@@@@@@@@....",
        "..@@CCCCCCCC@@..",
        ".@CCCCCCCCCCCC@.",
        ".@CCccccccccCC@.",
        "@CCcc@@@@@@ccCC@",
        "@CCcc@....@ccCC@",
        "@CCcc@....@ccCC@",
        "@CCcc@....@ccCC@",
        "@CCcc@....@ccCC@",
        "@CCcc@@@@@@ccCC@",
        ".@CCccccccccCC@.",
        ".@CCCCCCCCCCCC@.",
        "..@@CCCCCCCC@@..",
        "....@@@@@@@@....",
        "................"
    ],
    "stump.mif": [
        "................",
        "....@@@@@@@@....",
        "..@@bbbbbbbb@@..",
        ".@bbBBBBBBBBbb@.",
        ".@bBBbbbbbbBBb@.",
        "@bBBbBBBBBBbBBb@",
        "@bBBbBbbbbBbBBb@",
        "@bBBbBb@@bBbBBb@",
        "@bBBbBb@@bBbBBb@",
        "@bBBbBbbbbBbBBb@",
        "@bBBbBBBBBBbBBb@",
        ".@bBBbbbbbbBBb@.",
        ".@bbBBBBBBBBbb@.",
        "..@@bbbbbbbb@@..",
        "....@@@@@@@@....",
        "................"
    ],
    "grass.mif": [
        "GgGGgGGGgGGgGGgG",
        "gGGgGgGGgGgGGgGG",
        "GGgGGgGGgGGgGgGG",
        "gGgGGgGgGGgGGgGg",
        "GGgGGgGGgGGgGGgG",
        "gGGgGgGGgGgGGgGG",
        "GGgGGgGGgGGgGgGG",
        "gGgGGgGgGGgGGgGg",
        "GgGGgGGGgGGgGGgG",
        "gGGgGgGGgGgGGgGG",
        "GGgGGgGGgGGgGgGG",
        "gGgGGgGgGGgGGgGg",
        "GGgGGgGGgGGgGGgG",
        "gGGgGgGGgGgGGgGG",
        "GGgGGgGGgGGgGgGG",
        "gGgGGgGgGGgGGgGg"
    ],
    "wall.mif": [
        "@@@@@@@@@@@@@@@@",
        "@######@@######@",
        "@######@@######@",
        "@######@@######@",
        "@@@@@@@@@@@@@@@@",
        "####@@######@@##",
        "####@@######@@##",
        "####@@######@@##",
        "@@@@@@@@@@@@@@@@",
        "@######@@######@",
        "@######@@######@",
        "@######@@######@",
        "@@@@@@@@@@@@@@@@",
        "####@@######@@##",
        "####@@######@@##",
        "####@@######@@##"
    ]
}

def generate_mif():
    for filename, pixels in SPRITES.items():
        with open(filename, 'w') as f:
            f.write("WIDTH=8;\nDEPTH=1024;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n")
            addr = 0
            # הכפלת הפיקסלים פי 2 כדי להפוך 16x16 ל-32x32 חד וברור
            for row in pixels:
                for _ in range(2): 
                    for char in row:
                        color = PALETTE.get(char, "00")
                        for _ in range(2):
                            f.write(f"\t{addr} : {color};\n")
                            addr += 1
            f.write("END;\n")
        print(f"Generated {filename} successfully!")

if __name__ == "__main__":
    generate_mif()