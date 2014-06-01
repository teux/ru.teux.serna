<?xml version='1.0'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:se="http://www.syntext.com/XSL/Format-1.0" xmlns:exsl="http://exslt.org/common"
	xmlns:xse="http://www.syntext.com/Extensions/XSLT-1.0">

	<xsl:attribute-set name="cell">
		<xsl:attribute name="background-color">#f2f2f2</xsl:attribute>
		<xsl:attribute name="border-color">white</xsl:attribute>
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">3pt</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="padding">6pt</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template match="*[contains(@class, ' photoFile/photoSection ')][fig]">
		<fo:block>
			<xsl:apply-templates select="*[not(contains(@class, ' topic/fig '))]"/>
			<fo:table table-layout="auto">
				<fo:table-body>
					<xsl:call-template name="arrayFig"/>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>


	<xsl:template name="arrayFig">
		<xsl:variable name="figs" select="*[contains(@class, ' topic/fig ')]"/>
		<xsl:for-each select="*[contains(@class, ' topic/fig ')][(position() + 1) mod 2 = 0]">
			<fo:table-row>
				<fo:table-cell xsl:use-attribute-sets="cell">
					<xsl:apply-templates select="." mode="fig"/>
				</fo:table-cell>
				<fo:table-cell xsl:use-attribute-sets="cell">
					<xsl:choose>
						<xsl:when test="count(./following-sibling::*[1]) != 0">
							<xsl:apply-templates select="./following-sibling::*[1]" mode="fig"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>&nbsp;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</fo:table-cell>
			</fo:table-row>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="*[contains(@class, ' photoFile/floatFig ')][true()]">
		<fo:table table-layout="auto">
			<fo:table-body>
				<fo:table-row>
					<xsl:choose>
						<xsl:when test="@float = 'right'">
							<fo:table-cell><xsl:text>&nbsp;</xsl:text></fo:table-cell>
							<fo:table-cell xsl:use-attribute-sets="cell">
								<xsl:apply-templates select="." mode="fig"/>
							</fo:table-cell>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-cell xsl:use-attribute-sets="cell">
								<xsl:apply-templates select="." mode="fig"/>
							</fo:table-cell>
							<fo:table-cell><xsl:text>&nbsp;</xsl:text></fo:table-cell>
						</xsl:otherwise>
					</xsl:choose>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
			
	
	<xsl:template match="*" mode="fig">
		<xsl:apply-templates select="*[name()!='title']"/>
		<xsl:for-each select="*[contains(@class, ' topic/title ')]">
			<fo:block>
				<xsl:apply-templates select="node()"/>
			</fo:block>
		</xsl:for-each>
	</xsl:template>
	
	
	<!--everyTrail-->
	<xsl:template match="*[contains(@class, ' photoFile/everyTrail ')]">
		<fo:block padding-bottom="8pt">
			<fo:external-graphic src="{concat('url(',$iconDir,'everytrail.png)')}"/>
			<fo:inline xsl:use-attribute-sets="interim__title">Trip ID: </fo:inline>
			<xsl:apply-templates select="@tripId" mode="att-inline"/>
		</fo:block>
	</xsl:template>
	
	<!--umap-->
	<xsl:template match="*[contains(@class, ' photoFile/umap ')]">
		<fo:block padding-bottom="8pt">
			<fo:external-graphic src="{concat('url(',$iconDir,'umap.png)')}"/>
			<fo:inline xsl:use-attribute-sets="interim__title">uMap name: </fo:inline>
			<xsl:apply-templates select="@mapId" mode="att-inline"/>
		</fo:block>
	</xsl:template>
	
	<!--youTube-->
	<xsl:template match="*[contains(@class, ' photoFile/youTube ')]">
		<fo:block padding-bottom="8pt">
			<fo:external-graphic src="{concat('url(',$iconDir,'youtube.png)')}"/>
			<fo:inline xsl:use-attribute-sets="interim__title">Movie Link: </fo:inline>
			<xsl:apply-templates select="@href" mode="att-inline"/>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="@*" mode="att-inline">
		<se:line-edit value="{string(.)}" is-enabled="true" width="200px"/>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, ' topic/keywords ')]">
		<xsl:if test="*[contains(@class, ' topic/keyword ')]">
			<xsl:for-each select="*[contains(@class, ' topic/keyword ')]">
				<xsl:apply-templates select="."/>
				<xsl:if test="position() &lt; last()">
					<xsl:value-of select="', '"/>	
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
