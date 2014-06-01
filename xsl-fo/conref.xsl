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

	<xsl:attribute-set name="conref__makeup">
		<xsl:attribute name="color">blue</xsl:attribute>
	</xsl:attribute-set>


	<xsl:template match="*[@conref]" priority="100" dtm:id="attribute.conref">
		<xsl:param name="conrefs-queue"/>
		<xsl:variable name="id">
			<xsl:value-of select="generate-id(.)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length(@conref) = 0">
				<xsl:call-template name="show-conref-error">
					<xsl:with-param name="message" select="'[Conref attribute is empty]'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($conrefs-queue, $id)">
				<xsl:call-template name="show-conref-error">
					<xsl:with-param name="message" select="'[Cyclic conref]'"/>
				</xsl:call-template>      
			</xsl:when>
			<xsl:when test="$SHOW-CONREF-RESOLVED='yes'">
				<xsl:call-template name="href">
					<xsl:with-param name="href" select="@conref"/>
					<xsl:with-param name="type" select="'conref'"/>
					<xsl:with-param name="conrefs-queue"
						select="concat($conrefs-queue, '/', $id)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="hide-resolved-conref"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="apply.conref" priority="9">
		<xsl:param name="content"/>
		<xsl:param name="conrefs-queue"/>
		<xsl:variable name="error-message">
			<xsl:text>[Invalid conref: </xsl:text>
			<xsl:value-of select="@conref"/>
			<xsl:text>]</xsl:text>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not($content)">
				<xsl:call-template name="show-conref-error">
					<xsl:with-param name="message" select="$error-message"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- <fo:block xsl:use-attribute-sets="conref__makeup"> -->
				<xsl:choose>
					<xsl:when
						test="self::*[contains(@class, ' topic/topic ')] or
													self::*[contains(@class, ' map/map ')]">
						<fo:block xsl:use-attribute-sets="conref__makeup">
							<xsl:apply-templates select="$content">
								<xsl:with-param name="conref-context" select="."/>
								<xsl:with-param name="conrefs-queue" select="$conrefs-queue"/>
							</xsl:apply-templates>
						</fo:block>
					</xsl:when>
					<xsl:when
						test="self::*[not(contains(@class,' topic/row '))
				  												and not(contains(@class,' topic/entry '))
				  												and not(contains(@class,' topic/strow '))
				  												and not(contains(@class,' topic/stentry '))] ">
						<fo:block xsl:use-attribute-sets="conref__makeup">
							<xsl:apply-templates select="$content">
								<xsl:with-param name="conref-context" select="."/>
								<xsl:with-param name="conrefs-queue" select="$conrefs-queue"/>
							</xsl:apply-templates>
						</fo:block>
					</xsl:when>
					<!--conref on row, entry-->
					<xsl:when
						test="self::*[contains(@class,' topic/row ')
				  												or contains(@class,' topic/entry ')
				  												or contains(@class,' topic/strow ')
				  												or contains(@class,' topic/stentry ')]">
						<xsl:apply-templates select="$content">
							<xsl:with-param name="conrefMakeup" select="'yes'"/>
							<xsl:with-param name="conref-context" select="."/>
							<xsl:with-param name="conrefs-queue" select="$conrefs-queue"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$content">
							<xsl:with-param name="conref-context" select="."/>
							<xsl:with-param name="conrefs-queue" select="$conrefs-queue"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
				<!-- </fo:block> -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- row -->
	<xsl:template match="*[contains(@class, ' topic/row ')]" dtm:id="topic.row">
		<xsl:param name="conrefMakeup" select="'no'"/>
		<!-- Build current row with the incoming mnemonic row in "span" -->
		<xsl:call-template name="ditavalAttrs"/>
		<fo:table-row>
			<xse:cals-table-row>
				<xsl:apply-templates>
					<xsl:with-param name="conrefMakeup" select="$conrefMakeup"/>
				</xsl:apply-templates>
			</xse:cals-table-row>
		</fo:table-row>
	</xsl:template>


	<!--strow -->
	<xsl:template match="*[contains(@class, ' topic/strow ')]" dtm:id="topic.strow">
		<xsl:param name="conrefMakeup" select="'no'"/>
		<!-- Build current row with the incoming mnemonic row in "span" -->
		<fo:table-row>
			<xsl:apply-templates>
				<xsl:with-param name="conrefMakeup" select="$conrefMakeup"/>
			</xsl:apply-templates>
		</fo:table-row>
	</xsl:template>


	<!-- entry -->
	<xsl:template match="*[contains(@class, ' topic/entry ')]" dtm:id="topic.entry">
		<xsl:param name="conrefMakeup" select="'no'"/>
		<xse:cals-table-cell>
			<xsl:variable name="rowsep" select="xse:cals-attribute('rowsep', '1')"/>
			<xsl:variable name="colsep" select="xse:cals-attribute('colsep', '1')"/>
			<xsl:variable name="cols" select="xse:cals-attribute('cols',   '1')"/>
			<xsl:variable name="valign" select="xse:cals-attribute('valign', '')"/>
			<xsl:variable name="align" select="xse:cals-attribute('align', '')"/>
			<xsl:variable name="char" select="xse:cals-attribute('char', '')"/>
			<xsl:variable name="colspan" select="xse:cals-attribute('cals:colspan')"/>

			<fo:table-cell xsl:use-attribute-sets="table.cell.attributes">
				<xsl:if
					test="parent::*/parent::*[contains(@class, ' topic/thead ')
          or contains(@class, ' topic/tfoot ')]">
					<xsl:attribute name="background-color">
						<xsl:value-of select="$table.thead.cell.color"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="$rowsep &gt; 0">
					<xsl:call-template name="dita.calstable.border">
						<xsl:with-param name="side" select="'bottom'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$colsep &gt; 0 and
          xse:cals-attribute('cals:colnum') &lt; $cols">
					<xsl:call-template name="dita.calstable.border">
						<xsl:with-param name="side" select="'right'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$colspan &gt; 1">
					<xsl:attribute name="number-columns-spanned">
						<xsl:value-of select="$colspan"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="@morerows">
					<xsl:attribute name="number-rows-spanned">
						<xsl:value-of select="@morerows+1"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="$valign != ''">
					<xsl:attribute name="display-align">
						<xsl:choose>
							<xsl:when test="$valign='top'">before</xsl:when>
							<xsl:when test="$valign='middle'">center</xsl:when>
							<xsl:when test="$valign='bottom'">after</xsl:when>
							<xsl:otherwise>
								<xsl:text>center</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="$align != ''">
					<xsl:attribute name="text-align">
						<xsl:value-of select="$align"/>
					</xsl:attribute>
				</xsl:if>

				<xsl:if test="$char != ''">
					<xsl:attribute name="text-align">
						<xsl:value-of select="$char"/>
					</xsl:attribute>
				</xsl:if>

				<fo:block>
					<xsl:if test="$conrefMakeup = 'yes'">
						<xsl:attribute name="color">blue</xsl:attribute>
					</xsl:if>
					<!-- highlight this entry? -->
					<xsl:if test="parent::*/parent::*[contains(@class, ' topic/thead' )]">
						<xsl:attribute name="font-weight">bold</xsl:attribute>
					</xsl:if>

					<xsl:choose>
						<!-- Generate whitespace if no children -->
						<xsl:when test="not(node())">
							<xsl:text>&#160;</xsl:text>
						</xsl:when>
						<!-- Otherwise build the content -->
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:table-cell>
		</xse:cals-table-cell>
	</xsl:template>


	<!-- stentry -->
	<xsl:template match="*[contains(@class, ' topic/stentry ')]" dtm:id="topic.stentry">
		<xsl:param name="conrefMakeup" select="'no'"/>
		<fo:table-cell xsl:use-attribute-sets="frameall">

			<fo:block>
				<xsl:if test="$conrefMakeup = 'yes'">
					<xsl:attribute name="color">blue</xsl:attribute>
				</xsl:if>

				<xsl:choose>
					<!-- Generate whitespace if no children -->
					<xsl:when test="not(node())">
						<xsl:text>&#160;</xsl:text>
					</xsl:when>
					<!-- Otherwise build the content -->
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
		</fo:table-cell>
	</xsl:template>

</xsl:stylesheet>
