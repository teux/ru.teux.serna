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

	
	<!--
		атрибуты условной обработки: @locale,@audience,@platform,@product,@rev,@otherprops
	-->
	<xsl:template name="ditavalAttrs">
		<xsl:if test="concat(@locale, @audience, @platform, @product, @rev, @otherprops, @eid) != ''">
			<xsl:choose>
				<xsl:when test="contains(@class, ' topic/row ')">
					<xsl:call-template name="blockMark"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="inlineMark"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>


	<xsl:template name="inlineMark">
		<fo:inline color="gray" background-color="#fefee8" font-family="Courier" font-size="10pt">
			<xsl:text>[</xsl:text>
			<xsl:if test="string(@locale) != ''">
				<xsl:apply-templates select="@locale"/>
			</xsl:if>
			<xsl:if test="string(@audience) != ''">
				<xsl:if test="string(@locale) != ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="@audience"/>
			</xsl:if>
			<xsl:if test="string(@platform) != ''">
				<xsl:if test="concat(@locale,@audience) != ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="@platform"/>
			</xsl:if>
			<xsl:if test="string(@product) != ''">
				<xsl:if test="concat(@locale,@audience,@platform) != ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="@product"/>
			</xsl:if>
			<xsl:if test="string(@rev) != ''">
				<xsl:if test="concat(@locale,@audience,@platform,@product) != ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="@rev"/>
			</xsl:if>
			<xsl:if test="string(@otherprops) != ''">
				<xsl:if test="concat(@locale,@audience,@platform,@product,@rev) != ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="@otherprops"/>
			</xsl:if>
			<xsl:if test="string(@eid) != ''">
				<xsl:if test="concat(@locale,@audience,@platform,@product,@rev,@otherprops) != ''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>eid:</xsl:text>
				<xsl:apply-templates select="@eid"/>
			</xsl:if>
			<xsl:text>]</xsl:text>
		</fo:inline>
	</xsl:template>
	
	<xsl:template name="blockMark">
		<fo:table-row background-color="#fefee8" border-style="none">
			<xse:cals-table-row>
				<fo:table-cell>
					<xsl:call-template name="inlineMark"/>
				</fo:table-cell>
			</xse:cals-table-row>
		</fo:table-row>
	</xsl:template>
	
	
</xsl:stylesheet>
