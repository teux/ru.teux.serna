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


	<xsl:attribute-set name="codeblock">
		<xsl:attribute name="background-color">#f3f3f3</xsl:attribute>
		<xsl:attribute name="padding">6pt</xsl:attribute>
		<xsl:attribute name="font-family">Courier</xsl:attribute>
		<xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
		<xsl:attribute name="white-space-collapse">false</xsl:attribute>
		<xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
	</xsl:attribute-set>
	
	
	<!-- codeblock -->
	<xsl:template
		match="*[contains(@class,' api-d/codeblock ')] | *[contains(@class,' pr-d/codeblock ')] | *[contains(@class,' def-d/defblock ')]"
		priority="10">
		<fo:block xsl:use-attribute-sets="otbivka__block">
			<xsl:if test="@expanse='page'">
				<xsl:attribute name="start-indent">0</xsl:attribute>
			</xsl:if>
			<xsl:if test="$DRAFT-PRINT='no'">
				<xsl:if test="@highlight">
					<fo:inline xsl:use-attribute-sets="interim__title">
						<xsl:text>Подсветка: </xsl:text>
					</fo:inline>
					<xsl:apply-templates select="@highlight"/>
				</xsl:if>
				<xsl:if test="@code-lang">
					<fo:inline xsl:use-attribute-sets="interim__title">
						<xsl:text>Подсветка: </xsl:text>
					</fo:inline>
					<xsl:apply-templates select="@code-lang"/>
				</xsl:if>
				<xsl:if test="@deflink">
					<fo:inline xsl:use-attribute-sets="interim__title">
						<xsl:text> , связать с описанием: </xsl:text>
					</fo:inline>
					<xsl:apply-templates select="@deflink"/>
				</xsl:if>
			</xsl:if>
			<fo:block xsl:use-attribute-sets="codeblock">
				<xsl:call-template name="ditavalAttrs"/>
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template>


	<xsl:template match="@code-lang">
		<fo:inline xsl:use-attribute-sets="combo-box">
			<se:combo-box value="{string(.)}" width="70px">
				<se:value>no-highlight</se:value>
				<se:value>httpget</se:value>
				<se:value>javascript</se:value>
				<se:value>perl</se:value>
				<se:value>php</se:value>
				<se:value>python</se:value>
				<se:value>cpp</se:value>
				<se:value>vbscript</se:value>
				<se:value>xml</se:value>
			</se:combo-box>
		</fo:inline>
	</xsl:template>


	<xsl:template match="@deflink">
		<fo:inline xsl:use-attribute-sets="combo-box">
			<se:combo-box value="{string(.)}" width="60px">
				<se:value>all</se:value>
				<se:value>current</se:value>
				<se:value>no</se:value>
			</se:combo-box>
		</fo:inline>
	</xsl:template>

</xsl:stylesheet>
