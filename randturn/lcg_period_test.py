
class LCG:
	def __init__(self, a,c,m, seed=0):
		self.a = a
		self.c = c
		self.m = m
		self.x = seed
	
	def next(self):
		self.x = (self.a * self.x + self.c) % self.m
		return self.x

if __name__ == "__main__":
	
	m = 0x2000
	lcg = LCG(5,1,m)
	results = [lcg.next() for i in xrange(m)]

	numUnique = len(set(results))
	if numUnique == m:
		print "full cycling period"
	else:
		print "not a full period", numUnique

	print "%-4s %-4s" % ('step', 'value')
	print "-"*10
	for i,x in enumerate(results):
		print "%-4X %04X" % (i, x)
