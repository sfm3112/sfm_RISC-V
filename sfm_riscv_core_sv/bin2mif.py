import sys

def bin_to_mif(bin_filename, mif_filename, depth=4096, width=32):
    with open(bin_filename, 'rb') as f:
        data = f.read()

    # Calculate how many 32-bit words were written from the binary
    used_words = (len(data) + 3) // 4

    with open(mif_filename, 'w') as f:
        f.write(f"WIDTH = {width};\n")
        f.write(f"DEPTH = {depth};\n\n")
        f.write("ADDRESS_RADIX = HEX;\n")
        f.write("DATA_RADIX = HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        # Write actual instruction words
        for addr in range(min(used_words, depth)):
            byte_idx = addr * 4
            chunk = data[byte_idx:byte_idx+4]
            # Pad incomplete word if binary length isn't a multiple of 4
            word = int.from_bytes(chunk, byteorder='little')
            f.write(f"    {addr:04X}  :  {word:08X};\n")

        # Range-fill remaining unused addresses with zeros
        if used_words < depth:
            start_addr = used_words
            end_addr = depth - 1
            if start_addr == end_addr:
                f.write(f"    {start_addr:04X}  :  00000000;\n")
            else:
                f.write(f"    [{start_addr:04X}..{end_addr:04X}]  :  00000000;\n")

        f.write("END;\n")

if __name__ == "__main__":
    bin_to_mif(sys.argv[1], sys.argv[2])
    
#===================================================================================================================#
#   Run Following command in MSYS2 with Bronzebeard installed (must cd to location of .s file):                     #
#                                                                                                                   #
# bronzebeard [REPLACE WITH ASM FILENAME HERE] -o temp.bin && python bin2mif.py temp.bin memory.mif && rm temp.bin  #
#===================================================================================================================#

