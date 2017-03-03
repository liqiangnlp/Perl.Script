TITLE call.NiuTrans-length.ratio.filter.bat

perl NiuTrans-length.ratio.filter.pl -src c.token -tgt e.token -outSrc c.token.filter -outTgt e.token.filter -lowerBoundCoef 0.4 -upperBoundCoef 1.8 -lengthRestrict 150

pause