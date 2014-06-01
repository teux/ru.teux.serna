<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
		xmlns:se="http://www.syntext.com/XSL/Format-1.0"
		xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
		xmlns:exsl="http://exslt.org/common"
		xmlns:xse="http://www.syntext.com/Extensions/XSLT-1.0"
		xmlns:yfn="http://www.teux.ru/2010/XSL/functions"
		extension-element-prefixes="dtm yfn">


	<xsl:attribute-set name="syntax">
		<xsl:attribute name="border-right-style">solid</xsl:attribute>
		<xsl:attribute name="border-right-width">1px</xsl:attribute>
		<xsl:attribute name="border-right-color">
			<xsl:choose>
				<xsl:when test="$DRAFT-PRINT='yes'">
					<xsl:value-of select="'white'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'silver'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="border-bottom-style">solid</xsl:attribute>
		<xsl:attribute name="border-bottom-width">1px</xsl:attribute>
		<xsl:attribute name="border-bottom-color">
			<xsl:choose>
				<xsl:when test="$DRAFT-PRINT='yes'">
					<xsl:value-of select="'white'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'silver'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="padding-top">6pt</xsl:attribute>
		<xsl:attribute name="padding">2pt</xsl:attribute>
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="getsummary">
		<xsl:attribute name="background-color">#fffaf4</xsl:attribute>
		<!-- <xsl:attribute name="border-style">solid</xsl:attribute>
	<xsl:attribute name="border-color">gray</xsl:attribute>
	<xsl:attribute name="border-width">.5pt</xsl:attribute> -->
		<xsl:attribute name="padding">6pt</xsl:attribute>
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="instance">
		<xsl:attribute name="background-color">#f7ffff</xsl:attribute>
		<xsl:attribute name="border-right-style">solid</xsl:attribute>
		<xsl:attribute name="border-right-width">1px</xsl:attribute>
		<xsl:attribute name="border-right-color">
			<xsl:choose>
				<xsl:when test="$DRAFT-PRINT='yes'">
					<xsl:value-of select="'white'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'silver'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="border-bottom-style">solid</xsl:attribute>
		<xsl:attribute name="border-bottom-width">1px</xsl:attribute>
		<xsl:attribute name="border-bottom-color">
			<xsl:choose>
				<xsl:when test="$DRAFT-PRINT='yes'">
					<xsl:value-of select="'white'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'silver'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="padding">6pt</xsl:attribute>
		<xsl:attribute name="start-indent"><xsl:value-of select="$basic-start-indent"/></xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="field">
		<!-- <xsl:attribute name="background-color">#f9f9d9</xsl:attribute> -->
		<xsl:attribute name="padding">1pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="defl__name">
		<xsl:attribute name="background-color">#f3f3f3</xsl:attribute>
		<xsl:attribute name="font-family">Courier</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="bullet">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="font-family">Symbol</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="interim__block">
		<xsl:attribute name="padding-top">
			<xsl:choose>
				<xsl:when test="ancestor::*[contains(@class, ' get/instance ')]"/>
				<xsl:otherwise>
					<xsl:value-of select="'8pt'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="interim__block__first">
		<xsl:attribute name="padding-top">2pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="general__pagination">
		<xsl:attribute name="padding-top">2pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">2pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="url__pagination">
		<xsl:attribute name="padding-top">4pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">2pt</xsl:attribute>
		<!-- <xsl:attribute name="background-color">#f9f9d9</xsl:attribute> -->
		<xsl:attribute name="background-color">#f2f2f4</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="arg__description">
		<!-- <xsl:attribute name="background-color">#fffcf1</xsl:attribute> -->
		<xsl:attribute name="border-bottom-style">solid</xsl:attribute>
		<xsl:attribute name="border-bottom-color">silver</xsl:attribute>
		<xsl:attribute name="border-bottom-width">0pt</xsl:attribute>
		<xsl:attribute name="padding">4pt</xsl:attribute>
		<xsl:attribute name="start-indent">8mm</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="const__name">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="color">maroon</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="var__syntax">
		<xsl:attribute name="start-indent">16mm</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="var__name">
		<xsl:attribute name="color">maroon</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="var__definition">
		<xsl:attribute name="background-color">
			<xsl:choose>
				<xsl:when test="ancestor::*[contains(@class, ' get/instance ')]"/>
				<xsl:when test="$DRAFT-PRINT = 'yes'"/>
				<xsl:otherwise>
					<!-- <xsl:value-of select="'#f3f3f3'"/> -->
					<xsl:value-of select="'#fffcf1'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="var__value">
		<xsl:attribute name="font-family">Courier</xsl:attribute>
		<xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
		<xsl:attribute name="white-space-collapse">false</xsl:attribute>
		<xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="url__connector">
		<xsl:attribute name="color">gray</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="method__title">
		<xsl:attribute name="font-size">14pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="color">navy</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="method__keyword">
		<xsl:attribute name="color">blue</xsl:attribute>
		<xsl:attribute name="font-family">Courier</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="otbivka__syntax">
		
		<xsl:attribute name="padding-top">8pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">8pt</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="otbivka__p">
		<xsl:attribute name="padding-top">4pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">2pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="list__method__header">
		<xsl:attribute name="background-color">#f9f9d9</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="list__method__header__cell">
		<xsl:attribute name="font-size">8pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="padding-top">2pt</xsl:attribute>
		<xsl:attribute name="padding-left">2pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">4pt</xsl:attribute>
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-color">white</xsl:attribute>
		<xsl:attribute name="border-width">.5pt</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="list__method__body">
		<xsl:attribute name="background-color">#fffff1</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="list__method__body__cell">
		<xsl:attribute name="padding-top">2pt</xsl:attribute>
		<xsl:attribute name="padding-left">2pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">4pt</xsl:attribute>
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-color">white</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
	</xsl:attribute-set>
</xsl:stylesheet>
