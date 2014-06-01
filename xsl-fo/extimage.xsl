<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:se="http://www.syntext.com/XSL/Format-1.0"
                xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xse="http://www.syntext.com/Extensions/XSLT-1.0"
                xmlns:yfn="http://www.teux.ru/2010/XSL/functions"
                extension-element-prefixes="dtm yfn"                
                version='1.0'>


	<xsl:template match="*[contains(@class, ' topic/image ')]" priority="10">
		<xsl:variable name="imgLocal">
			<xsl:choose>
				<xsl:when test="function-available('yfn:extImgToLocal')">
					<xsl:value-of select="concat('url(',yfn:extImgToLocal(@href),')')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:external-graphic src="{$imgLocal}">
			<xsl:if test="count(@scale) = 1 and @scale &lt; 100">
				<xsl:attribute name="content-width">
					<xsl:value-of select="concat(@scale, '%')"/>
				</xsl:attribute>
				<xsl:attribute name="content-height">
					<xsl:value-of select="concat(@scale, '%')"/>
				</xsl:attribute>
			</xsl:if>
		</fo:external-graphic>
	</xsl:template>
</xsl:stylesheet>
