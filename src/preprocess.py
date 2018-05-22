import csv, glob, os

folders = ["downstairs", "sitting", "standing", "walking", "upstairs"]
if not os.path.exists('./total'):
	os.makedirs('./total')

if not os.path.exists('./total/gaits'):
	os.makedirs('./total/gaits')

for folder in folders:
	filepath = folder + '/*.log'

	lg = glob.glob(filepath)
	i = 0
	for textfile in lg:
		s = open(textfile).read()
		s = s.replace('(', ',')
		s = s.replace(')', ',')
		s = s.replace(':', ',')
		s = s.replace('[', '')
		s = s.replace(']', '')
		f = open('{}{}tmp.csv'.format(textfile.split('/')[0], textfile.split('/')[1].split('.')[0]), 'w')
		f.write(s)
		f.close()

		with open('{}{}tmp.csv'.format(textfile.split('/')[0], textfile.split('/')[1].split('.')[0]),"r") as source:
		    rdr = csv.reader( source )
		    with open('./total/gaits/{}{}.csv'.format(textfile.split('/')[0], str(int(i))),"w") as result:
		        wtr = csv.writer( result )
		        wtr.writerow(("T", "L_Toe", "L_Inner", "L_Outer", "L_Heel", "R_Toe", "R_Inner", "R_Outer", "R_Heel"))
		        for r in rdr:
		            wtr.writerow( (r[1], r[4], r[5], r[6], r[7], r[14], r[15], r[16], r[17]) )
		i = i + 1
		os.remove('{}{}tmp.csv'.format(textfile.split('/')[0], textfile.split('/')[1].split('.')[0]))