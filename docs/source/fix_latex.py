# -*- coding: utf-8 -*-
"""
Created on Mon Apr 11 09:44:29 2016

@author: lindemann
"""

import pathlib as pl
import os

rst_dir = "."

def find_rst_files(icml_dir):

    p = pl.Path(icml_dir)

    icml_files = []

    for x in p.iterdir():
        if x.is_file():
            if x.suffix == ".rst":
                icml_files.append(x)

    return icml_files

def fix_rst_file(filename):

    with open(filename, "r") as rst_file:
        lines = rst_file.readlines()

    with open(filename, "w") as rst_file:

        for line in lines:
            i0 = line.find('\\')
            while i0>=0:
                i1 = line.find('{', i0)
                i2 = line.find('}', i0)

                if i1>=0 and i2>=0:
                    cmd = line[i0+1:i1]
                    word = line[i1+1:i2]

                    if cmd == "fname" or cmd == "fkeyw" or cmd == "fvar" or cmd == "textbf" or cmd == "foper" or cmd == "fexpr" or cmd == "textit":
                        line_arr = list(line)
                        marker = "X" * (i1-i0)
                        line_arr[i0:i1+1] = list(marker)
                        line_arr[i2-1] = "**"
                        line = "".join(line_arr)
                        line = line.replace(marker, "**")

                    i0 = line.find('\\',i2)
                else:
                    i0 = -1

            line = line.replace("\\_", "_")
            rst_file.write(line)



    # with open(filename, "w") as icml_file:
 
    #     row = 0

    #     while row<len(lines):
    #         if lines[row].find("<Content>")!=-1:
    #             if lines[row].find(": :")!=-1:
    #                 lines[row] = lines[row].replace(": :", ":")

    #         icml_file.write(lines[row])

    #         row += 1


if __name__ == "__main__":

    rst_files = find_rst_files(rst_dir)

    for rst_filename in rst_files:
        print(rst_filename)
        fix_rst_file(rst_filename)
