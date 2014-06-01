<?xml version='1.0'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:se="http://www.syntext.com/XSL/Format-1.0"
	xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
	xmlns:exsl="http://exslt.org/common" xmlns:xse="http://www.syntext.com/Extensions/XSLT-1.0"
	xmlns:yfn="http://www.teux.ru/2010/XSL/functions" extension-element-prefixes="dtm yfn">


	<xsl:attribute-set name="minitoc">
		<xsl:attribute name="background-color">#fffaf4</xsl:attribute>
		<xsl:attribute name="padding">6pt</xsl:attribute>
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="note">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">.5pt</xsl:attribute>
		<xsl:attribute name="border-color">
			<xsl:choose>
				<xsl:when test="@type='attention' or @type='important' or @type='caution' or @type='denger'">
					<xsl:value-of select="'#ff6666'"/>
				</xsl:when>
				<xsl:when test="@type='restriction'">
					<xsl:value-of select="'#ffcc00'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'#ccccff'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="border-right-color">
			<xsl:choose>
				<xsl:when test="@type='attention' or @type='important' or @type='caution' or @type='denger'">
					<xsl:value-of select="'#ff6666'"/>
				</xsl:when>
				<xsl:when test="@type='restriction'">
					<xsl:value-of select="'#ffcc00'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'#ccccff'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="padding">4pt</xsl:attribute>
		<xsl:attribute name="padding-right">0</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="interim__label">
		<xsl:attribute name="color">gray</xsl:attribute>
		<xsl:attribute name="font-family">Courier</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="interim__title">
		<xsl:attribute name="color">gray</xsl:attribute>
		<xsl:attribute name="padding-bottom">2pt</xsl:attribute>
		<xsl:attribute name="font-size">9pt</xsl:attribute>
		<xsl:attribute name="font-family">Courier</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="shortdescr__block">
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
		<xsl:attribute name="padding-top">4pt</xsl:attribute>
		<xsl:attribute name="padding-left">4pt</xsl:attribute>
		<xsl:attribute name="padding-right">4pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">8pt</xsl:attribute>
		<xsl:attribute name="background-color">#f9f9d9</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="otbivka__block">
		<xsl:attribute name="padding-top">8pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">8pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="combo-box">
		<xsl:attribute name="font-size">7pt</xsl:attribute>
		<xsl:attribute name="color">navy</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="tex">
		<xsl:attribute name="background-color">#f3f3f3</xsl:attribute>
		<xsl:attribute name="padding">2pt</xsl:attribute>
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
		<xsl:attribute name="font-family">Courier</xsl:attribute>
		<xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
		<xsl:attribute name="white-space-collapse">false</xsl:attribute>
		<xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="fig">
		<xsl:attribute name="space-before">0.8em</xsl:attribute>
		<xsl:attribute name="space-after">0.8em</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="topictitle2" >
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
		<xsl:attribute name="padding-top">18pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">8pt</xsl:attribute>
		<xsl:attribute name="font-size">14pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="section__title">
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<!--<xsl:attribute name="font-style">italic</xsl:attribute>-->
		<xsl:attribute name="color">navy</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="otbivka__title">
		<xsl:attribute name="padding-top">
			<xsl:choose>
				<xsl:when test="parent::*/@display-style != 'normal'">0</xsl:when>
				<xsl:otherwise>8pt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="padding-bottom">4pt</xsl:attribute>
	</xsl:attribute-set>
	
</xsl:stylesheet>
