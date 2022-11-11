#!/usr/bin/env python

import csv
import os
import argparse
import time

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('--input_folder', help='input folder', required=True)
#parser.add_argument('--output', help='output folder', required=True)

args = parser.parse_args()
print (args.input_folder)
file_list = os.listdir(args.input_folder)
#file_list.sort()
print (file_list)
#output_f = open(os.path.join(args.output,"test_sample.csv"), "w")
time.sleep(4)
sample = []
fastq1 = []
fastq2 = []
for file in file_list:
    if file[-12:] == '001.fastq.gz':
        name = file[:file.rfind('_S')]
        if file.find('_R1_') > 0 or file.find('_I1_')>0:
            sample.append(name)
            fastq1.append(file)
        elif file.find('_R2_') > 0 or file.find('_I2_')>0:
            fastq2.append(file)

#with open(os.path.join(args.output,"test_sample.csv"), 'wb+') as myfile:
with open("test_sample.csv", 'w') as myfile:
    #wr = csv.writer(myfile,delimiter=',')
    writer = csv.DictWriter(myfile, fieldnames=["sample", "fastq_1", "fastq_2"])
    writer.writeheader()
    for i in range(len(sample)):
        #print ({'sample':sample[i],"fastq1" :fastq1[i],"fastq2" :fastq2[i]})
        writer.writerow({'sample':sample[i], "fastq_1" : fastq1[i], "fastq_2": fastq2[i]})



