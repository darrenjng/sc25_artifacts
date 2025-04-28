filename="hdd_output.txt"
num_files=79

compression_times=[]
decompression_times=[]
write_times=[]
read_times=[]
compressed_sizes=[]

with open(filename) as f1:
    ctr=0
    toggle=1
    for line in f1:
        if "compression time" in line and ctr < num_files-2:
            # print(line)
            compression_times.append(float(line.split(" ")[3]))
            ctr+=1
        if "decompression time" in line:
            # print(line)
            decompression_times.append(float(line.split(" ")[3]))
        if "WRITE:" in line:
            # print(line)
                split1=line.split(" ")[4]
                split2=split1.split("(")[1]
                split3=split2.split(")")[0]
                if "kB" in split3:
                    split4=split3.split("k")[0]
                    convert = float(split4)/1000
                    write_times.append(convert)
                if "MB" in split3:
                    split4=split3.split("M")[0]
                    write_times.append(float(split4))
        if "READ:" in line:
            # print(line)
                split1=line.split(" ")[5]
                split2=split1.split("(")[1]
                split3=split2.split(")")[0]
                if "kB" in split3:
                    split4=split3.split("k")[0]
                    convert = float(split4)/1000
                    read_times.append(convert)
                if "MB" in split3:
                    split4=split3.split("M")[0]
                    read_times.append(float(split4))
        if "COMPRESSED_SIZE:" in line:
            # print(line)
            if toggle == 1:
                split1=line.split(" ")[1]
                compressed_sizes.append(float(split1))
            toggle = toggle * -1 # filter out extra dups
            
write_runtimes = []
ctr = 0
for i in write_times:
    compressed_sizes[ctr] = compressed_sizes[ctr] / 1000000 # Byte to MB
    write_runtimes.append(compressed_sizes[ctr]/write_times[ctr])
    write_runtimes[ctr] = write_runtimes[ctr] * 1000000
    ctr += 1
print(compressed_sizes)
print(write_runtimes)

read_runtimes = []
ctr = 0
for i in read_times:
    read_runtimes.append(compressed_sizes[ctr]/read_times[ctr])
    read_runtimes[ctr] = read_runtimes[ctr] * 1000000
    ctr += 1
print(read_runtimes)
            
full_pipeline_time=0
compress_all_time=0
decompress_all_time=0
write_all_time=0
read_all_time=0

for i in compression_times:
    compress_all_time+=i 
for i in decompression_times:
    decompress_all_time+=i 
for i in write_runtimes:
    write_all_time+=i 
for i in read_runtimes:
    read_all_time+=i
    
print(compress_all_time)
print(decompress_all_time)
print(write_all_time)
print(read_all_time)

            



            