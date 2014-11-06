def TwinPrimeHelper(tnum, totaltwins, minusone, minustwo)
	if (tnum == 3)
		return totaltwins
	end
	curprime = minusone
	curminusone = minustwo
	curminustwo = isPrime(tnum - 2)

	if (curprime && curminustwo)
		TwinPrimeHelper(tnum-1, totaltwins + 1, curminusone, curminustwo)
	else
		TwinPrimeHelper(tnum - 1, totaltwins, curminusone, curminustwo)
	end
end

def TwinPrime(tnum)
	TwinPrimeHelper(tnum+1, 0, isPrime(tnum-1), isPrime(tnum-2))
end

def isPrime(pnum)
	if (pnum <= 3)
		return pnum > 1
	elsif (pnum % 2 == 0 || pnum % 3 == 0)
		return false
	else
		i = 5
		while ((i * i) <= pnum)
			if (pnum % i == 0 || pnum % (i + 2) == 0)
				return false
			else
				i += 6
			end
		end
		return true
	end
end

puts isPrime(25);

puts TwinPrime(7000)