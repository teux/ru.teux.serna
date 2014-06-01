<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:se="http://www.syntext.com/XSL/Format-1.0"
	xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
	extension-element-prefixes="dtm">


	<xsl:attribute-set name="topicref__title">
		<!--color-->
		<xsl:attribute name="color">
			<xsl:choose>
				<xsl:when test="@processing-role = 'resource-only'">silver</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count(*[contains(@class, ' map/topicref ')]) > 0">
							<xsl:value-of select="'#3333cc'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'black'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<!--bold-->
		<xsl:attribute name="font-weight">
			<xsl:choose>
				<xsl:when test="count(*[contains(@class, ' map/topicref ')]) > 0">bold</xsl:when>
				<xsl:otherwise>normal</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<!--size-->
		<xsl:attribute name="font-size">
			<xsl:variable name="level"
				select="count(ancestor-or-self::*[contains(@class, ' map/topicref ')])"/>
			<xsl:choose>
				<xsl:when test="$level > 5 or count(*[contains(@class, ' map/topicref ')]) = 0">
					<xsl:text>10pt</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('10+',(4-$level)*2)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<!--left indent-->
		<xsl:attribute name="start-indent">
			<xsl:value-of select="concat($basic-start-indent, '+', count(ancestor::*)-1, 'em')"/>
		</xsl:attribute>
		<!--top indent-->
		<xsl:attribute name="border-top-width">
			<xsl:variable name="level"
				select="count(ancestor-or-self::*[contains(@class, ' map/topicref ')])"/>
			<xsl:choose>
				<xsl:when test="$level > 5 or count(*[contains(@class, ' map/topicref ')]) = 0">
					<xsl:text>2pt</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('2+',(4-$level)*3)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:attribute-set>


	<xsl:attribute-set name="topicref__href">
		<xsl:attribute name="color">blue</xsl:attribute>
		<xsl:attribute name="text-decoration">underline</xsl:attribute>
		<xsl:attribute name="font-size">8pt</xsl:attribute>
		<xsl:attribute name="font-weight">normal</xsl:attribute>
	</xsl:attribute-set>


	<xsl:attribute-set name="key__cell">
		<xsl:attribute name="padding">2pt</xsl:attribute>
		<xsl:attribute name="border-top-width">4pt</xsl:attribute>
		<xsl:attribute name="border-bottom-width">0pt</xsl:attribute>
	</xsl:attribute-set>
</xsl:stylesheet>
