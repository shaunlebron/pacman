"""
This script builds a statistical model of the frightened ghost turns in Pac-Man.

It depends on two files in the current directory:
- pacman.6e
- pacman.6f

Those two files constitute to the first 8K of the Pac-Man ROM, and it is used
as the random turn table.
"""


template = """
       DDD
        ^
        |
CCC <--   --> AAA
        |
        v
       BBB
"""

def printTurnProb(turnProb):

	blank = " "*3
	def getPercentStr(val):
		if val == 0:
			return " "*3
		else:
			return ("%02d" % int(val*100+0.5)) + "%"
	
	def insertPercentIntoStr(tempStr, i, val):
		s = getPercentStr(val)
		keys = ('A','B','C','D')
		for char in s:
			tempStr = tempStr.replace(keys[i], char, 1)
		keys = ('>','v','<','^')
		if s == blank:
			tempStr = tempStr.replace(keys[i], 'X')
		return tempStr
		
	result = template
	for i,val in enumerate(turnProb):
		result = insertPercentIntoStr(result, i, val)
	
	print result

if __name__ == "__main__":
	
	turnNames = ['right','down','left','up']

	def getTryTurnProb(bytes_8k):
		freq = [0,0,0,0]
		for b in bytes_8k:
			b = ord(b) & 3
			freq[b] += 1
		total = sum(freq)
		return [float(i)/total for i in freq]
	
	pacman_6e = open('pacman.6e', 'rb').read()
	pacman_6f = open('pacman.6f', 'rb').read()

	# The probability that ghost will try a direction.
	turnTryProb = getTryTurnProb(pacman_6e + pacman_6f)

	# This is a list of possible openings. We are only interested in 2 and 3 openings.
	cases = [
		# 2 openings (4 choose 2 = 6 cases)
		[0,0,1,1],
		[0,1,0,1],
		[1,0,0,1],
		[0,1,1,0],
		[1,0,1,0],
		[1,1,0,0],

		# 3 openings (4 choose 3 = 4 cases)
		[0,1,1,1],
		[1,0,1,1],
		[1,1,0,1],
		[1,1,1,0],
	]

	def getTurnProbFromOpenings(openings):
		def getNextOpening(i):
			while not openings[i]:
				i = (i+1)%4;
			return i

		turnProb = [0,0,0,0]
		for i in range(4):
			turnProb[getNextOpening(i)] += turnTryProb[i]

		return turnProb

	def printTurnProbFromOpenings(openings):
		turnProb = getTurnProbFromOpenings(openings)
		printTurnProb(turnProb)


	print "Stats on Frightened Ghost Turns"
	print "(based on Midway Pac-Man ROM)"
	print
	print "Probability that ghost will TRY a direction:"
	print

	printTurnProb(turnTryProb)

	print
	print "Actual probability when some turns are constrained:"
	print

	for case in cases:
		printTurnProbFromOpenings(case)
