<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Whitespace stripping policy -->
	<xsl:strip-space elements="*"/>
	<xsl:preserve-space elements="pre p codeblock defblock"/>

	<xsl:import href="../../dita/dita-xsl-serna/topic2fo.xsl"/>
	<xsl:param name="DRAFT-PRINT" select="'no'"/>

	<xsl:include href="topic-att.xsl"/>
	<xsl:include href="api-att.xsl"/>
	<xsl:include href="ditaval.xsl"/>
	<xsl:include href="topic.xsl"/>
	<xsl:include href="api.xsl"/>
	<xsl:include href="codeblock.xsl"/>
	<xsl:include href="conref.xsl"/>
	<xsl:include href="domains.xsl"/>
	<xsl:include href="keyref.xsl"/>
	<xsl:include href="extimage.xsl"/>
	<xsl:include href="teux.photo.xsl"/>

</xsl:stylesheet>
