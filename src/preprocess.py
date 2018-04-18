import csv, glob, os

if not os.path.exists('./convert'):
	os.makedirs('./convert')
filepath = '*.log'
lg = glob.glob(filepath)
for textfile in lg:
	s = open(textfile).read()
	s = s.replace('(', ',')
	s = s.replace(')', ',')
	s = s.replace(':', ',')
	s = s.replace('[', '')
	s = s.replace(']', '')
	f = open('{}tmp.csv'.format(textfile.split('.')[0]), 'w')
	f.write(s)
	f.close()

	with open('{}tmp.csv'.format(textfile.split('.')[0]),"r") as source:
	    rdr = csv.reader( source )
	    with open('./convert/{}.csv'.format(textfile.split('.')[0]),"w") as result:
	        wtr = csv.writer( result )
	        for r in rdr:
	            wtr.writerow( (r[1], r[4], r[5], r[6], r[7], r[14], r[15], r[16], r[17]) )
	os.remove('{}tmp.csv'.format(textfile.split('.')[0]))