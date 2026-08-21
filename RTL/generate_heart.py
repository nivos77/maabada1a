PALETTE = {
    '.': "FF", # שקוף (Transparent)
    '@': "00", # קו מתאר (Black)
    'R': "E0", # אדום בוהק (Red)
    'r': "C0", # אדום כהה להצללה (Dark Red)
    'W': "FF", # השתקפות אור (White)
}

HEART_SPRITE = [
    "................",
    "................",
    "..@@@@....@@@@..",
    ".@RRRR@..@RRRR@.",
    "@RRRRRR@@RRRRRR@",
    "@RRWWWRRRRRRRRR@",
    "@RRWWRRRRRRRRRR@",
    ".@RRRRRRRRRRRR@.",
    "..@RRRRRRRRRR@..",
    "...@RRRRRRRR@...",
    "....@rRRRRr@....",
    ".....@rRRr@.....",
    "......@rr@......",
    ".......@@.......",
    "................",
    "................"
]

def generate_heart_mif():
    with open("heart.mif", 'w') as f:
        f.write("WIDTH=8;\nDEPTH=1024;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=HEX;\n\nCONTENT BEGIN\n")
        addr = 0
        for row in HEART_SPRITE:
            for _ in range(2): 
                for char in row:
                    color = PALETTE.get(char, "00")
                    for _ in range(2):
                        f.write(f"\t{addr} : {color};\n")
                        addr += 1
        f.write("END;\n")
    print("Generated heart.mif successfully!")

if __name__ == "__main__":
    generate_heart_mif()