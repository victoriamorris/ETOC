<?xml version="1.0" encoding="UTF-8"?>
<!-- Created with Liquid Studio 2020 (https://www.liquid-technologies.com) -->
<xsl:stylesheet version="2.0" 
				xmlns:fn="fn" 
				xmlns:xlink="http://www.w3.org/1999/xlink" 
				xmlns:xs="http://www.w3.org/2001/XMLSchema" 
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
				exclude-result-prefixes="xs xsl fn">
	<xsl:output method="text" omit-xml-declaration="no" indent="yes" encoding="UTF-8" normalization-form="NFC"/>
	<xsl:strip-space elements="*"/>

	<!--
		================================================================================
				An XSLT transformation to convert NLM article DTD (JATS) files to MARCXML
				
				Victoria Morris
				Date created: 2024-10-29
				Last updated: 2024-10-29 Victoria Morris
				Version: 0.1
		________________________________________________________________________________
		Change log:
			v0.1 - 2024-10-29
				Initial version
		================================================================================
		THIS TRANSFORMATION MAY ONLY BE EDITED BY MEMBERS OF THE COLLECTION METADATA TEAM
		================================================================================
	-->

	<!--
		====================
			Variables
		====================
	-->

	<!-- &#x9; = tab -->
	<xsl:variable name="tab">
		<xsl:text>&#x9;</xsl:text>
	</xsl:variable>

	<!-- &#10; = line feed -->
	<xsl:variable name="newline">
		<xsl:text>&#10;</xsl:text>
	</xsl:variable>

	<!-- single quote -->
	<xsl:variable name="sQ">
		<xsl:text>'</xsl:text>
	</xsl:variable>

	<!-- double quote -->
	<xsl:variable name="dQ">
		<xsl:text>"</xsl:text>
	</xsl:variable>

	<!--
		====================
			Functions
		====================
	-->

	<!-- Function to trim punctuation from the start of a string
		Removes .:,;/ ]
		Should also remove hyphens that do not precede dates
	-->
	<xsl:function name="fn:trimPunctuationStart" as="xs:string*">
		<xsl:param name="string" as="xs:string*"/>
		<xsl:variable name="length" select="string-length($string)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="not($string)"/>
			<xsl:when test="contains('.:,;/ ])', substring($string,1,1))">
				<xsl:value-of select="fn:trimPunctuationStart(substring($string,2,$length - 1))"/>
			</xsl:when>
			<xsl:when test="starts-with($string,'-') and $length>=5 and replace(substring($string,2,4),'[^0-9]','')!=substring($string,2,4)">
				<xsl:value-of select="fn:trimPunctuationStart(substring($string,2,$length - 1))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($string)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Function to trim punctuation from the end of a string
		Removes .:,;/ [+
		Should also remove full stops but not ellipses
		Should also remove hyphens that do not follow dates
	-->
	<xsl:function name="fn:trimPunctuationEnd" as="xs:string*">
		<xsl:param name="string" as="xs:string*"/>
		<xsl:variable name="length" select="string-length($string)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="not($string)"/>
			<xsl:when test="contains(':,;/ [+', substring($string,$length,1))">
				<xsl:value-of select="fn:trimPunctuationEnd(substring($string,1,$length - 1))"/>
			</xsl:when>
			<xsl:when test="ends-with($string,'.') and not(ends-with($string,'...'))">
				<xsl:value-of select="fn:trimPunctuationEnd(substring($string,1,$length - 1))"/>
			</xsl:when>
			<xsl:when test="ends-with($string,'-') and $length>=5 and replace(substring($string,$length - 4,4),'[^0-9]','')!=substring($string,$length - 4,4)">
				<xsl:value-of select="fn:trimPunctuationEnd(substring($string,1,$length - 1))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($string)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Function to trim punctuation from both ends of a string
		This function calls both fn:trimPunctuationStart and fn:trimPunctuationEnd
	-->
	<xsl:function name="fn:trimPunctuation" as="xs:string*">
		<xsl:param name="string" as="xs:string*"/>
		<xsl:value-of select="normalize-space(fn:trimPunctuationEnd(fn:trimPunctuationStart($string)))"/>
	</xsl:function>

	<!-- Function used to clean text strings
		Removes HTML markup, then trims punctuation from both ends of the string
	-->
	<xsl:function name="fn:clean" as="xs:string?">
		<xsl:param name="string"/>
		<xsl:value-of select="normalize-space(fn:trimPunctuation(replace(replace(replace($string,'&lt;/?([a-zA-Z][a-zA-Z0-9]*)[^\.\-&amp;,&gt;]*/?&gt;',''),'&amp;nbsp;',''),'[“”‘’]',$sQ)))"/>
	</xsl:function>

	<!-- Function used to look up a shelfmark from an ISSN
	-->
	<xsl:function name="fn:issn2sm" as="xs:string?">
		<xsl:param name="issn"/>
		<xsl:value-of select="if ($issn = '2414-6994') then '0537.501455'
					else if ($issn = '2056-5127') then '0570.468700'
					else if ($issn = '0951-3574') then '0573.590900'
					else if ($issn = '1030-9616') then '0573.630000'
					else if ($issn = '2056-3868') then '0699.847000'
					else if ($issn = '1757-0972') then '0704.325000'
					else if ($issn = '1479-3598') then '0705.471500'
					else if ($issn = '2056-5925') then '0709.007220'
					else if ($issn = '2044-1282') then '0709.378250'
					else if ($issn = '2042-8332') then '0709.378500'
					else if ($issn = '2040-0705') then '0732.519200'
					else if ($issn = '0002-1466') then '0746.650000'
					else if ($issn = '2059-9366') then '0780.000000'
					else if ($issn = '1748-8842') then '0780.070000'
					else if ($issn = '1935-519X') then '0822.270000'
					else if ($issn = '2056-3515') then '1044.235500'
					else if ($issn = '0003-5599') then '1547.450000'
					else if ($issn = '2632-7627') then '1571.964000'
					else if ($issn = '1985-9899') then '1583.226750'
					else if ($issn = '2631-6862') then '1661.471000'
					else if ($issn = '2056-4945') then '1735.915000'
					else if ($issn = '2044-2084') then '1736.801600'
					else if ($issn = '2071-1395') then '1742.260694'
					else if ($issn = '1355-5855') then '1742.260720'
					else if ($issn = '2046-3162') then '1742.416750'
					else if ($issn = '2459-9700') then '1742.471400'
					else if ($issn = '2615-9821') then '1742.485300'
					else if ($issn = '1321-7348') then '1742.745030'
					else if ($issn = '2050-3806') then '1744.050000'
					else if ($issn = '0001-253X') then '1745.000000'
					else if ($issn = '0144-5154') then '1746.606200'
					else if ($issn = '1746-5265') then '1861.316625'
					else if ($issn = '1463-5771') then '1891.290270'
					else if ($issn = '0888-045X') then '2264.020100'
					else if ($issn = '0007-070X') then '2300.800000'
					else if ($issn = '2044-124X') then '2366.039695'
					else if ($issn = '1463-7154') then '2934.636500'
					else if ($issn = '1751-5637') then '2934.803552'
					else if ($issn = '1362-0436') then '3051.705000'
					else if ($issn = '1544-9106') then '3058.135200'
					else if ($issn = '1756-137X') then '3180.080240'
					else if ($issn = '2044-1398') then '3180.146850'
					else if ($issn = '2516-1652') then '3180.220530'
					else if ($issn = '1750-614X') then '3180.802500'
					else if ($issn = '0305-6120') then '3198.839000'
					else if ($issn = '1477-7274') then '3286.288520'
					else if ($issn = '2514-9326') then '3310.466251'
					else if ($issn = '0160-4953') then '3310.477400'
					else if ($issn = '0332-1649') then '3363.924000'
					else if ($issn = '1059-5422') then '3363.993690'
					else if ($issn = '1471-4175') then '3421.309390'
					else if ($issn = '2752-6666') then '3424.230500'
					else if ($issn = '2516-7502') then '3425.688705'
					else if ($issn = '1356-3289') then '3472.060695'
					else if ($issn = '1472-0701') then '3472.066060'
					else if ($issn = '1742-2043') then '3487.457160'
					else if ($issn = '2059-5794') then '3488.805400'
					else if ($issn = '1352-7606') then '3488.807000'
					else if ($issn = '1065-0741') then '3506.283000'
					else if ($issn = '2514-9288') then '3535.745000'
					else if ($issn = '1463-5801') then '3560.122000'
					else if ($issn = '1477-7282') then '3578.787000'
					else if ($issn = '2059-5816') then '3588.396750'
					else if ($issn = '2398-5038') then '3588.397325'
					else if ($issn = '0965-3562') then '3595.462000'
					else if ($issn = '2731-4375') then '3627.399500'
					else if ($issn = '2752-6739') then '3629.845000'
					else if ($issn = '0040-0912') then '3661.198000'
					else if ($issn = '1753-7983') then '3661.218500'
					else if ($issn = '0264-0473') then '3702.580500'
					else if ($issn = '0142-5455') then '3737.040000'
					else if ($issn = '1460-9541') then '3737.053050'
					else if ($issn = '0264-4401') then '3758.580800'
					else if ($issn = '0969-9988') then '3758.609000'
					else if ($issn = '2059-5727') then '3775.149550'
					else if ($issn = '2040-7149') then '3794.506150'
					else if ($issn = '1450-2194') then '3829.275200'
					else if ($issn = '0955-534X') then '3829.557200'
					else if ($issn = '1460-1060') then '3829.730430'
					else if ($issn = '0309-0566') then '3829.731000'
					else if ($issn = '2046-9012') then '3829.747105'
					else if ($issn = '2049-3983') then '3831.036685'
					else if ($issn = '0263-2772') then '3863.430000'
					else if ($issn = '1463-6689') then '3987.779200'
					else if ($issn = '2631-3030') then '4005.233500'
					else if ($issn = '2634-2499') then '4042.011740'
					else if ($issn = '2635-0173') then '4055.355000'
					else if ($issn = '1754-2413') then '4096.401642'
					else if ($issn = '2514-9342') then '4195.447800'
					else if ($issn = '2043-9377') then '4216.420970'
					else if ($issn = '1077-5730') then '4250.368500'
					else if ($issn = '0965-4283') then '4274.968700'
					else if ($issn = '2042-3896') then '4307.390300'
					else if ($issn = '0819-8691') then '4318.130000'
					else if ($issn = '1460-8790') then '4335.097100'
					else if ($issn = '0143-7712') then '4335.268700'
					else if ($issn = '0967-0734') then '4336.434045'
					else if ($issn = '2059-1403') then '4370.729700'
					else if ($issn = '1753-8254') then '4409.358000'
					else if ($issn = '0019-7858') then '4444.970000'
					else if ($issn = '0036-8792') then '4457.610000'
					else if ($issn = '0263-5577') then '4457.715000'
					else if ($issn = '0143-991X') then '4462.200000'
					else if ($issn = '1463-6697') then '4478.864000'
					else if ($issn = '2056-4961') then '4481.780000'
					else if ($issn = '2398-5348') then '4481.827500'
					else if ($issn = '0959-3845') then '4496.368733'
					else if ($issn = '2515-8961') then '4515.480310'
					else if ($issn = '1758-583X') then '4531.816060'
					else if ($issn = '1741-5659') then '4531.872358'
					else if ($issn = '0264-1615') then '4534.463000'
					else if ($issn = '2516-8142') then '4540.743500'
					else if ($issn = '1834-7649') then '4541.527300'
					else if ($issn = '0265-2323') then '4542.127000'
					else if ($issn = '2398-4708') then '4542.155550'
					else if ($issn = '1756-8692') then '4542.167600'
					else if ($issn = '0955-6222') then '4542.172170'
					else if ($issn = '1056-9219') then '4542.172450'
					else if ($issn = '2396-7404') then '4542.172840'
					else if ($issn = '1044-4068') then '4542.175700'
					else if ($issn = '0959-6119') then '4542.175950'
					else if ($issn = '2398-7294') then '4542.179600'
					else if ($issn = '1750-6182') then '4542.181300'
					else if ($issn = '1446-8956') then '4542.185025'
					else if ($issn = '1759-5908') then '4542.185475'
					else if ($issn = '2516-4392') then '4542.186100'
					else if ($issn = '0951-354X') then '4542.199700'
					else if ($issn = '2047-0894') then '4542.232720'
					else if ($issn = '1746-8809') then '4542.232800'
					else if ($issn = '1750-6220') then '4542.236500'
					else if ($issn = '1355-2554') then '4542.240400'
					else if ($issn = '2514-9369') then '4542.244520'
					else if ($issn = '1758-2954') then '4542.244640'
					else if ($issn = '1756-6266') then '4542.264600'
					else if ($issn = '0952-6862') then '4542.275000'
					else if ($issn = '2059-4631') then '4542.276850'
					else if ($issn = '1753-8270') then '4542.284000'
					else if ($issn = '2056-4902') then '4542.288565'
					else if ($issn = '2056-4880') then '4542.304790'
					else if ($issn = '1756-378X') then '4542.310440'
					else if ($issn = '2049-6427') then '4542.310870'
					else if ($issn = '1753-8394') then '4542.311705'
					else if ($issn = '1754-243X') then '4542.312450'
					else if ($issn = '1756-1450') then '4542.312600'
					else if ($issn = '2040-4166') then '4542.314530'
					else if ($issn = '2046-8253') then '4542.319250'
					else if ($issn = '0957-4093') then '4542.321800'
					else if ($issn = '1753-8378') then '4542.327500'
					else if ($issn = '0143-7720') then '4542.329000'
					else if ($issn = '2046-6854') then '4542.352210'
					else if ($issn = '0961-5539') then '4542.406100'
					else if ($issn = '0144-3577') then '4542.425000'
					else if ($issn = '1934-8835') then '4542.435250'
					else if ($issn = '1742-7371') then '4542.452750'
					else if ($issn = '1750-6123') then '4542.452915'
					else if ($issn = '0960-0035') then '4542.461500'
					else if ($issn = '1741-0401') then '4542.486200'
					else if ($issn = '2056-4929') then '4542.509070'
					else if ($issn = '0951-3558') then '4542.509200'
					else if ($issn = '0265-671X') then '4542.510000'
					else if ($issn = '1756-669X') then '4542.510300'
					else if ($issn = '2048-8696') then '4542.535550'
					else if ($issn = '0959-0552') then '4542.537800'
					else if ($issn = '0306-8293') then '4542.555000'
					else if ($issn = '0144-333X') then '4542.571000'
					else if ($issn = '1464-6668') then '4542.681250'
					else if ($issn = '1757-9864') then '4542.681488'
					else if ($issn = '1467-6370') then '4542.685400'
					else if ($issn = '2056-5607') then '4542.695760'
					else if ($issn = '1744-0084') then '4542.701180'
					else if ($issn = '1751-1062') then '4542.701275'
					else if ($issn = '1753-8351') then '4542.701855'
					else if ($issn = '0265-1335') then '4543.976250'
					else if ($issn = '2586-3932') then '4551.304100'
					else if ($issn = '1066-2243') then '4557.199827'
					else if ($issn = '1319-1616') then '4583.021500'
					else if ($issn = '0128-1976') then '4583.595500'
					else if ($issn = '1832-5912') then '4918.867800'
					else if ($issn = '2042-1168') then '4918.875200'
					else if ($issn = '1466-8203') then '4918.945400'
					else if ($issn = '0972-7981') then '4918.947986'
					else if ($issn = '1759-6599') then '4919.997802'
					else if ($issn = '2044-0839') then '4919.999355'
					else if ($issn = '0967-5426') then '4939.870000'
					else if ($issn = '2050-7003') then '4947.045500'
					else if ($issn = '1558-7894') then '4947.218250'
					else if ($issn = '2515-964X') then '4947.234050'
					else if ($issn = '2052-1944') then '4951.277700'
					else if ($issn = '0885-8624') then '4954.661060'
					else if ($issn = '2635-1692') then '4954.662600'
					else if ($issn = '0275-6668') then '4954.717000'
					else if ($issn = '2514-4774') then '4954.853850'
					else if ($issn = '1754-4408') then '4958.039500'
					else if ($issn = '1756-1396') then '4958.039550'
					else if ($issn = '2040-8005') then '4958.042000'
					else if ($issn = '1363-254X') then '4961.634900'
					else if ($issn = '0736-3761') then '4965.211600'
					else if ($issn = '2516-7480') then '4965.237000'
					else if ($issn = '1463-001X') then '4965.337800'
					else if ($issn = '2009-3829') then '4965.600050'
					else if ($issn = '2056-3841') then '4965.617500'
					else if ($issn = '2044-1266') then '4965.844350'
					else if ($issn = '2399-6439') then '4968.150000'
					else if ($issn = '1229-988X') then '4968.759800'
					else if ($issn = '0022-0418') then '4970.000000'
					else if ($issn = '1026-4116') then '4972.540000'
					else if ($issn = '0144-3585') then '4973.055000'
					else if ($issn = '1859-0020') then '4973.095060'
					else if ($issn = '0957-8234') then '4973.153000'
					else if ($issn = '2398-6263') then '4977.725500'
					else if ($issn = '1726-0531') then '4978.840000'
					else if ($issn = '1741-0398') then '4979.291700'
					else if ($issn = '1750-6204') then '4979.292300'
					else if ($issn = '2045-2101') then '4979.354900'
					else if ($issn = '2053-4612') then '4979.354950'
					else if ($issn = '0309-0590') then '4979.605000'
					else if ($issn = '1753-9269') then '4979.608700'
					else if ($issn = '1472-5967') then '4983.624000'
					else if ($issn = '2043-6238') then '4983.646000'
					else if ($issn = '1361-2026') then '4983.860000'
					else if ($issn = '1359-0790') then '4984.237000'
					else if ($issn = '1757-6385') then '4984.239000'
					else if ($issn = '1366-4387') then '4984.260200'
					else if ($issn = '1358-1988') then '4984.264000'
					else if ($issn = '1985-2517') then '4984.264501'
					else if ($issn = '2050-8794') then '4984.595000'
					else if ($issn = '2398-6247') then '4993.550000'
					else if ($issn = '2049-8799') then '4996.301000'
					else if ($issn = '2398-5364') then '4996.301550'
					else if ($issn = '2041-2568') then '4996.321000'
					else if ($issn = '1477-7266') then '4996.795000'
					else if ($issn = '0857-4421') then '4996.870110'
					else if ($issn = '1755-750X') then '5000.480005'
					else if ($issn = '2514-9792') then '5003.402860'
					else if ($issn = '1757-9880') then '5003.402954'
					else if ($issn = '2042-6747') then '5003.471030'
					else if ($issn = '2636-4182') then '5003.471800'
					else if ($issn = '1755-4195') then '5005.302300'
					else if ($issn = '2631-357X') then '5006.684500'
					else if ($issn = '1477-996X') then '5006.745500'
					else if ($issn = '1469-1930') then '5007.538435'
					else if ($issn = '2399-9802') then '5007.538465'
					else if ($issn = '2633-6596') then '5007.538540'
					else if ($issn = '2046-469X') then '5007.655500'
					else if ($issn = '1738-2122') then '5007.673180'
					else if ($issn = '1477-0024') then '5007.686920'
					else if ($issn = '1528-5812') then '5008.052000'
					else if ($issn = '1759-0817') then '5008.455800'
					else if ($issn = '1759-0833') then '5008.538060'
					else if ($issn = '1756-1418') then '5009.856000'
					else if ($issn = '1367-3270') then '5009.858000'
					else if ($issn = '1229-828X') then '5009.869000'
					else if ($issn = '2050-8824') then '5010.230070'
					else if ($issn = '0262-1711') then '5011.300000'
					else if ($issn = '1751-1348') then '5011.331050'
					else if ($issn = '0268-3946') then '5011.530000'
					else if ($issn = '1741-038X') then '5011.670000'
					else if ($issn = '1755-6228') then '5017.688530'
					else if ($issn = '1746-5664') then '5020.575500'
					else if ($issn = '1368-5201') then '5020.890000'
					else if ($issn = '2053-535X') then '5021.058070'
					else if ($issn = '0953-4814') then '5027.069000'
					else if ($issn = '2051-6614') then '5027.094000'
					else if ($issn = '2046-6749') then '5027.094500'
					else if ($issn = '1757-2215') then '5027.738500'
					else if ($issn = '2514-7641') then '5029.290000'
					else if ($issn = '1753-8335') then '5040.329255'
					else if ($issn = '1061-0421') then '5042.648000'
					else if ($issn = '2056-9548') then '5042.671500'
					else if ($issn = '1463-578X') then '5042.779000'
					else if ($issn = '2514-9407') then '5042.780500'
					else if ($issn = '1355-2511') then '5043.687000'
					else if ($issn = '1947-1017') then '5052.009050'
					else if ($issn = '2040-7122') then '5052.009150'
					else if ($issn = '1471-5201') then '5052.012000'
					else if ($issn = '1526-5943') then '5052.101200'
					else if ($issn = '1758-552X') then '5054.931000'
					else if ($issn = '2053-4620') then '5054.933000'
					else if ($issn = '2055-6225') then '5064.010900'
					else if ($issn = '0887-6045') then '5064.011000'
					else if ($issn = '1462-6004') then '5064.706000'
					else if ($issn = '2042-6763') then '5064.764001'
					else if ($issn = '1755-425X') then '5066.873100'
					else if ($issn = '1328-7265') then '5068.064500'
					else if ($issn = '1746-8779') then '5068.565400'
					else if ($issn = '2055-5911') then '5069.705000'
					else if ($issn = '2205-2062') then '5072.636100'
					else if ($issn = '1366-5626') then '5072.638000'
					else if ($issn = '0368-492X') then '5134.840000'
					else if ($issn = '0143-7739') then '5162.866000'
					else if ($issn = '1751-1879') then '5162.866468'
					else if ($issn = '2077-5504') then '5179.326017'
					else if ($issn = '0969-6474') then '5179.328300'
					else if ($issn = '0737-8831') then '5198.870000'
					else if ($issn = '0143-5124') then '5200.415000'
					else if ($issn = '0024-2535') then '5204.450000'
					else if ($issn = '2054-5533') then '5208.921750'
					else if ($issn = '0025-1747') then '5359.019000'
					else if ($issn = '1477-7835') then '5359.024650'
					else if ($issn = '1536-5433') then '5359.058300'
					else if ($issn = '2040-8269') then '5359.058825'
					else if ($issn = '0268-6902') then '5359.233000'
					else if ($issn = '0307-4358') then '5359.240000'
					else if ($issn = '0309-0558') then '5359.245000'
					else if ($issn = '0960-4529') then '5359.305000'
					else if ($issn = '2516-158X') then '5373.920000'
					else if ($issn = '2397-3757') then '5381.352150'
					else if ($issn = '0263-4503') then '5381.646700'
					else if ($issn = '1368-3047') then '5413.580925'
					else if ($issn = '2049-372X') then '5534.696000'
					else if ($issn = '2042-8308') then '5678.580390'
					else if ($issn = '1356-5362') then '5758.971000'
					else if ($issn = '2631-3871') then '5897.614900'
					else if ($issn = '1750-497X') then '5983.084010'
					else if ($issn = '1573-6105') then '5983.091350'
					else if ($issn = '1550-333X') then '6083.985000'
					else if ($issn = '0307-4803') then '6084.455000'
					else if ($issn = '0034-6659') then '6188.070000'
					else if ($issn = '1074-8121') then '6256.705500'
					else if ($issn = '1468-4527') then '6260.762534'
					else if ($issn = '0168-2601') then '6265.960400'
					else if ($issn = '0114-0582') then '6328.400000'
					else if ($issn = '1463-4449') then '6407.236500'
					else if ($issn = '1467-8047') then '6423.831312'
					else if ($issn = '0048-3486') then '6428.098000'
					else if ($issn = '1460-955X') then '6428.098300'
					else if ($issn = '0369-9420') then '6500.145000'
					else if ($issn = '1363-951X') then '6543.283900'
					else if ($issn = '0033-0337') then '6864.320000'
					else if ($issn = '0263-7472') then '6927.309700'
					else if ($issn = '2399-1747') then '6945.980650'
					else if ($issn = '1727-2645') then '6962.561400'
					else if ($issn = '2053-7697') then '6968.313000'
					else if ($issn = '1176-6093') then '7163.820000'
					else if ($issn = '1352-2752') then '7168.124320'
					else if ($issn = '1755-4179') then '7168.124381'
					else if ($issn = '1443-9883') then '7168.124385'
					else if ($issn = '1746-5648') then '7168.124405'
					else if ($issn = '2044-1827') then '7168.134150'
					else if ($issn = '0968-4883') then '7168.139354'
					else if ($issn = '2633-0091') then '7253.245000'
					else if ($issn = '1355-2546') then '7254.445570'
					else if ($issn = '2531-0488') then '7296.480000'
					else if ($issn = '0956-5698') then '7325.792500'
					else if ($issn = '0950-4125') then '7331.919030'
					else if ($issn = '0090-7324') then '7331.920000'
					else if ($issn = '1809-2276') then '7336.477000'
					else if ($issn = '1560-6074') then '7741.646500'
					else if ($issn = '1479-3547') then '7770.595000'
					else if ($issn = '0733-558X') then '7770.733000'
					else if ($issn = '1475-7702') then '7786.740100'
					else if ($issn = '1940-5979') then '7788.370000'
					else if ($issn = '2356-9980') then '7790.228000'
					else if ($issn = '2059-6014') then '7790.820000'
					else if ($issn = '2254-0644') then '7840.865000'
					else if ($issn = '0309-4006') then '8210.627000'
					else if ($issn = '0260-2288') then '8241.782000'
					else if ($issn = '2632-0487') then '8310.193075'
					else if ($issn = '2046-6099') then '8310.193080'
					else if ($issn = '2042-0919') then '8318.057300'
					else if ($issn = '1750-8614') then '8318.087430'
					else if ($issn = '1747-1117') then '8318.152050'
					else if ($issn = '1933-5415') then '8318.213400'
					else if ($issn = '1871-2673') then '8318.219000'
					else if ($issn = '1746-5680') then '8319.187505'
					else if ($issn = '0954-0911') then '8327.242650'
					else if ($issn = '2398-628X') then '8348.628130'
					else if ($issn = '2045-4457') then '8348.628200'
					else if ($issn = '2444-9695') then '8361.737587'
					else if ($issn = '2042-678X') then '8419.506600'
					else if ($issn = '0258-0543') then '8474.031432'
					else if ($issn = '1475-4398') then '8474.031450'
					else if ($issn = '1087-8572') then '8474.037950'
					else if ($issn = '0263-080X') then '8478.610000'
					else if ($issn = '1086-7376') then '8490.441000'
					else if ($issn = '2398-4686') then '8490.625700'
					else if ($issn = '1359-8546') then '8547.630600'
					else if ($issn = '2040-8021') then '8553.352900'
					else if ($issn = '1352-7592') then '8614.560200'
					else if ($issn = '0964-1866') then '8814.642750'
					else if ($issn = '1660-5373') then '8870.922363'
					else if ($issn = '1754-2731') then '8873.782400'
					else if ($issn = '1750-6166') then '9020.679500'
					else if ($issn = '0305-5728') then '9236.855000'
					else if ($issn = '2059-5891') then '9236.856000'
					else if ($issn = '1366-3666') then '9348.648500'
					else if ($issn = '1708-5284') then '9356.073280'
					else if ($issn = '2042-5961') then '9356.073290'
					else if ($issn = '2042-5945') then '9356.074120'
					else if ($issn = '1755-4217') then '9364.188230'
					else if ($issn = '1747-3616') then '9421.410370'
					else if ($issn = '1757-4323') then '9830.700000'
					else if ($issn = '2040-8749') then '9830.900000'
					else '0000.000000'"/>
	</xsl:function>

	<!--
		====================
			 Main template
		====================
	-->

	<!-- This template matches the root element -->
	<xsl:template match="/">

		<!--
			==================================================
			Process each <book> element
			==================================================
		-->

		<xsl:for-each select="//*:article">
			<xsl:text>&lt;HEAD&gt;&lt;ID&gt;</xsl:text>
			<xsl:value-of select="concat('ER',format-number(position(),'000000000'))"/>
			<xsl:text>&lt;/ID&gt;&lt;ITEM UIN&gt;Z000000000&lt;/ITEM UIN&gt;&lt;SHM&gt;</xsl:text>
			<xsl:value-of select="if (./*:front/*:journal-meta/*:issn[@publication-format='print'][text()!='']) 
						  then fn:issn2sm(./*:front/*:journal-meta/*:issn[@publication-format='print'][text()!=''])[1] else '0000.000000'"/>
			<xsl:text>&lt;/SHM&gt;&lt;ISSUE&gt;</xsl:text>
			<xsl:value-of select="(./*:front/*:article-meta/*:pub-date[@publication-format='print']/*:year)[1]"/>
			<xsl:if test="./*:front/*:article-meta/*:volume[text()!='']">
				<xsl:value-of select="concat('; VOL ', fn:clean((./*:front/*:article-meta/*:volume[text()!=''])[1]))"/>
			</xsl:if>
			<xsl:if test="./*:front/*:article-meta/*:issue[text()!='']">
				<xsl:value-of select="concat('; NUMBER ', fn:clean((./*:front/*:article-meta/*:issue[text()!=''])[1]))"/>
			</xsl:if>
			<xsl:text>&lt;/ISSUE&gt;&lt;AUTHOR&gt;</xsl:text>
			<xsl:value-of select="string-join(for $x in (./*:front/*:article-meta/*:contrib-group/*:contrib//*:name)
						  return concat($x/*:surname,', ',$x/*:given-names) , '; ')"/>
			<xsl:text>&lt;/AUTHOR&gt;&lt;TITLE&gt;</xsl:text>
			<xsl:value-of select="(./*:front/*:article-meta/*:title-group/*:article-title)[1]"/>
			<xsl:text>&lt;/TITLE&gt;&lt;PAGE&gt;</xsl:text>
			<xsl:if test="./*:front/*:article-meta/*:fpage[text()!='']">
				<xsl:value-of select="fn:clean((./*:front/*:article-meta/*:fpage[text()!=''])[1])"/>
			</xsl:if>
			<xsl:if test="./*:front/*:article-meta/*:lpage[text()!='']">
				<xsl:value-of select="concat('-', fn:clean((./*:front/*:article-meta/*:lpage[text()!=''])[1]))"/>
			</xsl:if>
			<xsl:text>&lt;/PAGE&gt;&lt;LANG&gt;E&lt;/LANG&gt;&lt;/HEAD&gt;</xsl:text>
			<xsl:value-of select="$newline"/>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
