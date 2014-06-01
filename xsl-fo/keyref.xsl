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

	
	<!--process keyref for ph, codeph and uicontrol-->
	<xsl:template match="*[@keyref != '']" priority="10">
		<fo:inline color="#006600">
			<xsl:if test="self::uicontrol">
				<xsl:attribute name="font-weight">
					<xsl:value-of select="'bold'"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="self::parmname">
				<xsl:attribute name="font-family">
					<xsl:value-of select="'Courier'"/>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:variable name="keyText">
				<xsl:choose>
					<xsl:when test="function-available('yfn:getKey')">
						<xsl:value-of select="yfn:getKey(@keyref)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="''"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$keyText != ''">
					<xsl:value-of select="$keyText"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[</xsl:text>
					<xsl:value-of select="@keyref"/>
					<xsl:text>]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template>

</xsl:stylesheet>
