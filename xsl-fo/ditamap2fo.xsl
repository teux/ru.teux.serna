<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0"
            xmlns:fo="http://www.w3.org/1999/XSL/Format"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
            xmlns:xse="http://syntext.com/Extensions/XSLT-1.0"
            xse:optimization="dita"
            extension-element-prefixes="dtm xse">

	<xsl:import href="../../dita/dita-xsl-serna/map2fo_shell.xsl"/>
	<xsl:include href="ditamap-att.xsl"/>
	<xsl:include href="ditaval.xsl"/>
	<xsl:include href="ditamap.xsl"/>

</xsl:stylesheet>
