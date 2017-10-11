text_file = open("stimulus.txt", "w")

for i in range(0x0001, 0x000B):
    string = "{0:{fill}16b}".format(i, fill='0');
    string = string[0:4] + "_" + string[4:8] + "_" + string[8:12] + "_" + string[12:16] + "_"
    text_file.write(string)
    #text_file.write("\n")

text_file.close()
