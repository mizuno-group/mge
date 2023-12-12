#!/usr/bin/env python

import argparse
import pandas as pd
import glob

def main():
    """ main function for integration """
    parser = argparse.ArgumentParser(description="integrate separate files")
    parser.add_argument(
        "-i","--filein",type=str,default="/workspace/res_gene",
        help="indicate the path for the target directory containing files"
        )
    parser.add_argument("-o","--fileout",type=str,default="expression",help="indicate the name of the output")
    parser.add_argument("-s","--sep",type=str,default=",",help="indicate the separator")
    parser.add_argument("-e","--ext",type=str,default="csv",help="indicate the extension")
    args = parser.parse_args()
    
    try:
        paths = glob.glob(args.filein + "/*." + args.ext)
    except:
        pass

    res = []
    for p in paths:
        res.append(pd.read_csv(p,index_col=0,sep=args.sep))
    res = pd.concat(res,join='outer',axis=1)
    
    res.to_csv('{0}/{1}.txt'.format(args.filein,args.fileout),sep='\t')
    print(res.shape)

if __name__ == "__main__":
    main()


# history
# 220905 move to one package
# 220723 Major: change paths to relative ones
# 211228 start writing