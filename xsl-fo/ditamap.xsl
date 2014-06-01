<?xml version='1.0'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:se="http://www.syntext.com/XSL/Format-1.0"
	xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
	extension-element-prefixes="dtm">

	<xsl:param name="page.margin.inner">1cm</xsl:param>
	<xsl:param name="page.margin.outer">0.8cm</xsl:param>
	<xsl:param name="body.margin.bottom">0.8cm</xsl:param>
	<xsl:param name="body.margin.top">0.8cm</xsl:param>
	<xsl:param name="basic-start-indent">0</xsl:param>
	<xsl:param name="basic-end-indent">0</xsl:param>
	
	
	<!-- map -->
	<xsl:template match="*[contains(@class,' map/map ')]" dtm:id="map.map">
		<fo:block>
			<!--fo:block color="red">DITA map doctype type</fo:block -->
			<fo:block id="{generate-id()}">
				<xsl:if test="not(*[1])">
					<fo:block font-size="14pt" color="red"> (Empty DITA Map. Please insert topic references
						below) </fo:block>
				</xsl:if>
				<xsl:if test="@title">
					<fo:block xsl:use-attribute-sets="topictitle3" color="gray">
						<xsl:apply-templates select="@product"/>
					</fo:block>
					<fo:block xsl:use-attribute-sets="topictitle4" color="gray">
						<xsl:text>версия:  </xsl:text>
						<xsl:apply-templates select="@rev"/>
					</fo:block>
					<fo:block xsl:use-attribute-sets="topictitle4" color="gray">
						<xsl:text> </xsl:text>
					</fo:block>
					<fo:block xsl:use-attribute-sets="topictitle1" color="gray">
						<xsl:apply-templates select="@title"/>
					</fo:block>
					<fo:block xsl:use-attribute-sets="topictitle4" color="gray">
						<xsl:text> </xsl:text>
					</fo:block>
				</xsl:if>
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template>


	<!--topicref-->
	<xsl:template name="topicref-table">
		<xsl:param name="navtitle"/>
		<xsl:param name="topicdoc"/>
		<fo:table>
			<fo:table-body border-width="0px">
				<fo:table-row>
					<fo:table-cell xsl:use-attribute-sets="topicref__title">
						<fo:block>
							<!-- mark outers -->
							<xsl:if test="starts-with(@href,'../')">
								<fo:inline color="gray" background-color="#fefee8" font-family="Courier" font-size="10pt">
									<xsl:text>..</xsl:text>
								</fo:inline>
							</xsl:if>
							<!-- mark href -->
							<xsl:if test="contains(@chunk,'yes')">
								<fo:inline color="gray" background-color="#fefee8" font-family="Courier" font-size="10pt">
									<xsl:text>%%</xsl:text>
								</fo:inline>
							</xsl:if>
							<!-- mark no-toc -->
							<xsl:if test="@toc='no'">
								<fo:inline color="gray" background-color="#fefee8" font-family="Courier" font-size="10pt">
									<xsl:text>——</xsl:text>
								</fo:inline>
							</xsl:if>
							<xsl:value-of select="$navtitle"/>
							<xsl:call-template name="ditavalAttrs"/>
						</fo:block>
						<xsl:if test="$SHOW-MAP-DESCRIPTIONS='yes' 
              and $topicdoc/shortdesc">
							<fo:block font-size="8pt" background-color="#CCFFCC" start-indent="13pt"
								font-weight="bold">
								<xsl:value-of select="$topicdoc/shortdesc"/>
							</fo:block>
						</xsl:if>
					</fo:table-cell>
					<fo:table-cell border-width="0px">
						<fo:block text-align="right">
							<fo:inline xsl:use-attribute-sets="topicref__href">
								<xsl:value-of select="@href"/>
							</fo:inline>
							<xsl:if test="@collection-type">
								<fo:inline color="green">
									<xsl:text>  (</xsl:text>
									<xsl:value-of select="@collection-type"/>
									<xsl:text>)</xsl:text>
								</fo:inline>
							</xsl:if>
							<xsl:if test="@linking">
								<fo:inline color="purple">
									<xsl:text>  (</xsl:text>
									<xsl:value-of select="@linking"/>
									<xsl:text>)</xsl:text>
								</fo:inline>
							</xsl:if>
							<xsl:apply-templates select="@type"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>


	<!-- topicgroup -->
	<xsl:template match="*[contains(@class,' mapgroup-d/topicgroup ') ]" priority="10">
		<fo:block xsl:use-attribute-sets="topicref__title">
			<xsl:call-template name="ditavalAttrs"/>
			<xsl:apply-templates select="*[not(self::processing-instruction('docato-extra-info-title'))]"
			/>
		</fo:block>
	</xsl:template>


	<!-- map/@title -->
	<xsl:template match="*[contains(@class,' map/map ')]/@title" dtm:id="map.title">
		<se:line-edit value="{string(.)}" is-enabled="true" width="700px"/>
	</xsl:template>


	<!-- map/@product -->
	<xsl:template match="*[contains(@class,' map/map ')]/@product" dtm:id="map.title">
		<se:line-edit value="{string(.)}" is-enabled="true" width="700px"/>
	</xsl:template>

	<!-- map/@rev -->
	<xsl:template match="*[contains(@class,' map/map ')]/@rev" dtm:id="map.title">
		<se:line-edit value="{string(.)}" is-enabled="true" width="100px"/>
	</xsl:template>
	
	
	<!--keys-->	
	<xsl:template match="*[contains(@class, ' mapgroup-d/keydef ')]">
		<xsl:variable name="lastKey" select="count(following-sibling::*[1][not(contains(@class, ' mapgroup-d/keydef '))])"/>
			
		<xsl:if test="preceding-sibling::*[1][not(contains(@class, ' mapgroup-d/keydef '))]">
			<xsl:call-template name="keysHeader"/>
		</xsl:if>
		<fo:table border-color="white">
			<xsl:if test="$lastKey = 1">
				<xsl:attribute name="border-bottom-width">20pt</xsl:attribute>
			</xsl:if>
			<fo:table-column column-number="1" column-width="4cm"/>
			<fo:table-column column-number="2" column-width="100%"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell xsl:use-attribute-sets="key__cell" font-family="Courier">
						<xsl:value-of select="@keys"/>
						<xsl:call-template name="ditavalAttrs"/>
						<xsl:if test="$lastKey">
							<xsl:attribute name="border-bottom-width">2pt</xsl:attribute>
							<xsl:attribute name="border-bottom-color">silver</xsl:attribute>
						</xsl:if>
					</fo:table-cell>
					<fo:table-cell xsl:use-attribute-sets="key__cell">
						<fo:block text-align="left">
							<xsl:apply-templates mode="keydef"/>
						</fo:block>
						<xsl:if test="$lastKey">
							<xsl:attribute name="border-bottom-width">2pt</xsl:attribute>
							<xsl:attribute name="border-bottom-color">silver</xsl:attribute>
						</xsl:if>
					</fo:table-cell>
				</fo:table-row>	
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	
	<xsl:template name="keysHeader">
		<fo:table border-top-width="20pt" border-color="white">
			<fo:table-column column-number="1" column-width="4cm"/>
			<fo:table-column column-number="2" column-width="100%"/>
			<fo:table-header background-color="#ffcc99">
				<fo:table-row>
					<fo:table-cell padding="2pt">Ключ</fo:table-cell>
					<fo:table-cell padding="2pt">Значение</fo:table-cell>
				</fo:table-row>
			</fo:table-header>
		</fo:table>
	</xsl:template>
	
	
	<xsl:template match="*" mode="keydef" priority="-1">
		<fo:block>
			<xsl:apply-templates mode="keydef"/>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, ' topic/keyword ')]" mode="keydef">
		<fo:block>
			<xsl:choose>
				<xsl:when test="not(text()[normalize-space(.)] | *)">
					<xsl:text>&#160;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>
	

</xsl:stylesheet>
