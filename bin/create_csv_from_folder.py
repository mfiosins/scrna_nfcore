import csv
import os
import argparse
import time

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('--input', help='input folder', required=True)
parser.add_argument('--output', help='output folder', required=True)

args = parser.parse_args()
print (args.input)
file_list = os.listdir(args.input)

print (file_list)
sample = []
fastq1 = []
fastq2 = []
for file in file_list:
    if file[-12:] == '001.fastq.gz':
        name = file[:file.rfind('_S')]
        if file.find('_R1_') > 0 or file.find('_L1_')>0:
            sample.append(name) 
            fastq1.append(file)
        if file.find('_R2_') > 0 or file.find('_L2_')>0:
            fastq2.append(file)
        else:
            fastq2.append(None)
with open(os.path.join(args.output,"test_sample.csv"), 'wb+') as myfile:
    wr = csv.writer(myfile,delimiter=',')
    writer = csv.DictWriter(myfile, fieldnames=["sample", "fastq1", "fastq2"])
    for i in range(len(sample)):
                     wr.writerow(({'sample':sample[i],
                     "fastq1" :fastq1[i],
                      "fastq2" :fastq2[i]}))


