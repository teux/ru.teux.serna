<?xml version='1.0'?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:se="http://www.syntext.com/XSL/Format-1.0"
	xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
	xmlns:exsl="http://exslt.org/common" xmlns:xse="http://www.syntext.com/Extensions/XSLT-1.0"
	xmlns:yfn="http://www.teux.ru/2010/XSL/functions" extension-element-prefixes="dtm yfn">


	<xsl:param name="page.margin.inner">1cm</xsl:param>
	<xsl:param name="page.margin.outer">0.8cm</xsl:param>
	<xsl:param name="body.margin.bottom">0.8cm</xsl:param>
	<xsl:param name="body.margin.top">0.8cm</xsl:param>
	<xsl:param name="basic-start-indent">1cm</xsl:param>
	<xsl:param name="basic-end-indent">0</xsl:param>

	<!--путь к каталогу с картинками. Вызывется функция из плагина на питоне-->
	<xsl:variable name="iconDir">
		<xsl:if test="function-available('yfn:iconDir')">
			<xsl:value-of select="yfn:iconDir()"/>
			<xsl:value-of select="'/'"/>
		</xsl:if>
	</xsl:variable>


	<!--section and example-->
	<xsl:template
		match="*[contains(@class,' topic/section ')] | *[contains(@class,' topic/example ')]">
		<fo:block margin-top="15pt" line-height="12pt" id="{generate-id()}">
			<xsl:if test="@spectitle and not(title)">
				<fo:block font-weight="bold" margin-botton="12pt" font-size="14pt"
					line-height="16pt" color="blue">
					<xsl:value-of select="@spectitle"/>
				</fo:block>
			</xsl:if>
			<xsl:if test="count(@display-style) > 0 and @display-style!='normal'">
				<fo:block xsl:use-attribute-sets="section__title">
					<fo:external-graphic src="{concat('url(',$iconDir, @display-style, '.png)')}"/>
				</fo:block>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>


	<!-- section/example title -->
	<xsl:template
		match="*[contains(@class,' topic/section ')]/*[contains(@class,' topic/title ')] |
										*[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]"
		priority="10">
		<fo:block xsl:use-attribute-sets="otbivka__title">
			<fo:block xsl:use-attribute-sets="section__title" id="{generate-id()}">
				<xsl:call-template name="get-title"/>
			</fo:block>
		</fo:block>
	</xsl:template>


	<!-- note -->
	<xsl:template match="*[contains(@class,' topic/note ')]">
		<xsl:variable name="type-map">
			<type val="">Примечание</type>
			<type val="note">Примечание</type>
			<type val="tip">Совет</type>
			<type val="fastpath">Fastpath</type>
			<type val="restriction">Ограничение</type>
			<type val="important">Important</type>
			<type val="remember">Remember</type>
			<type val="attention">Внимание!</type>
			<type val="caution">Caution</type>
			<type val="danger">Danger</type>
			<type val="other">
				<xsl:choose>
					<xsl:when test="@othertype">
						<xsl:value-of select="@othertype"/>
					</xsl:when>
					<xsl:otherwise> [<xsl:value-of select="@type"/>] </xsl:otherwise>
				</xsl:choose>
			</type>
		</xsl:variable>
		<xsl:variable name="note-type" select="@type"/>
		<xsl:variable name="note-inscription" select="$type-map/type[@val=$note-type]"/>

		<fo:block xsl:use-attribute-sets="otbivka__block">
			<xsl:apply-templates select="@type"/>
			<fo:block xsl:use-attribute-sets="note">
				<fo:block>
					<xsl:call-template name="ditavalAttrs"/>
					<xsl:apply-templates/>
				</fo:block>
			</fo:block>
		</fo:block>
	</xsl:template>


	<xsl:template match="note/@type">
		<xsl:if test="$DRAFT-PRINT='no'">
			<fo:inline xsl:use-attribute-sets="combo-box">
				<se:combo-box value="{string(.)}" width="75px">
					<se:value>note</se:value>
					<se:value>attention</se:value>
					<se:value>restriction</se:value>
					<se:value>tip</se:value>
				</se:combo-box>
			</fo:inline>
		</xsl:if>
	</xsl:template>


	<!-- prolog -->
	<xsl:template
		match="*[contains(@class,' bookmap/bookmeta ')] |
                     *[contains(@class,' topic/prolog ')]"
		dtm:id="prolog.data.background">
		<xsl:if test="$DRAFT-PRINT='no'">
			<fo:block background-color="#f0f0d0" padding="6pt" border-style="bold"
				border-color="black" border-width="thin" start-indent="{$basic-start-indent}">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template>


	<!-- h2 (redefine w/o upper line)-->
	<dtm:doc dtm:elements="topic/topic/title" dtm:status="finished" dtm:idref="title.h2"/>
	<xsl:template
		match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]"
		priority="3" dtm:id="title.h2">
		<fo:block xsl:use-attribute-sets="topictitle2" id="{generate-id()}">
			<fo:block>
				<xsl:call-template name="get-title"/>
			</fo:block>
		</fo:block>
	</xsl:template>


	<!-- shortdesc -->
	<xsl:template match="*[contains(@class,' topic/shortdesc ')]" dtm:id="topic.shortdesc">
		<fo:block xsl:use-attribute-sets="shortdescr__block">
			<xsl:call-template name="extra-info"/>
		</fo:block>
	</xsl:template>


	<!--tex-->
	<xsl:template match="*[contains(@class, ' tex-d/tex ')]">
		<fo:inline xsl:use-attribute-sets="tex">
			<fo:inline xsl:use-attribute-sets="interim__title">
				<xsl:text>tex: </xsl:text>
			</fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>


	<!--minitoc-->
	<xsl:template match="*[contains(@class, ' minitoc-d/minitoc ')]">
		<!--Дочерние секции и топики-->
		<xsl:variable name="sections"
			select="following::*[contains(@class, ' topic/section ') or contains(@class, ' topic/example ')]
																					[*[1][contains(@class, ' topic/title ')]][@id and @id != '']
																					[ancestor::*[contains(@class, ' topic/topic ')][1] = current()/ancestor::*[contains(@class, ' topic/topic ')][1]]"/>
		<xsl:variable name="topics"
			select="ancestor::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/topic ')]"/>

		<fo:block xsl:use-attribute-sets="otbivka__block">
			<xsl:if test="$DRAFT-PRINT='no'">
				<fo:inline xsl:use-attribute-sets="interim__title">
					<xsl:text>Содержание на основе: </xsl:text>
				</fo:inline>
				<xsl:apply-templates select="@toc-scope"/>
			</xsl:if>
			<fo:block xsl:use-attribute-sets="minitoc">
				<xsl:if
					test="parent::*[contains(@class, ' topic/body ') or contains(@class, ' topic/section ') or contains(@class, ' topic/example ')]">
					<fo:block font-weight="bold">Краткое содержание</fo:block>
				</xsl:if>
				<xsl:choose>
					<!--авто-выбор области содержания-->
					<xsl:when test="@toc-scope = 'auto'">
						<xsl:call-template name="miniToc">
							<xsl:with-param name="sections" select="$sections"/>
							<xsl:with-param name="topics" select="$topics"/>
						</xsl:call-template>
					</xsl:when>
					<!--содержание по секциям текущего раздела-->
					<xsl:when test="@toc-scope = 'topic'">
						<xsl:call-template name="miniToc">
							<xsl:with-param name="sections" select="$sections"/>
						</xsl:call-template>
					</xsl:when>
					<!--содержание по топикам текущего файла-->
					<xsl:when test="@toc-scope = 'file'">
						<xsl:call-template name="miniToc">
							<xsl:with-param name="topics" select="$topics"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</fo:block>
		</fo:block>
	</xsl:template>


	<!--miniToc-->
	<xsl:template name="miniToc">
		<xsl:param name="sections"/>
		<xsl:param name="topics"/>

		<xsl:choose>
			<xsl:when test="count($sections) != 0">
				<xsl:for-each select="$sections">
					<fo:block>
						<fo:inline color="blue">
							<xsl:value-of select="*[contains(@class, ' topic/title ')]"/>
						</fo:inline>
					</fo:block>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="count($topics) != 0">
				<xsl:for-each select="$topics">
					<fo:block>
						<fo:inline color="blue">
							<xsl:value-of select="*[contains(@class, ' topic/title ')]"/>
						</fo:inline>
					</fo:block>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>

	</xsl:template>


	<xsl:template match="@toc-scope">
		<fo:inline xsl:use-attribute-sets="combo-box">
			<se:combo-box value="{string(.)}" width="70px">
				<se:value>auto</se:value>
				<se:value>topic</se:value>
				<se:value>file</se:value>
			</se:combo-box>
		</fo:inline>
	</xsl:template>


	<!--
		Переопределить шаблоны для отображения атрибутов условной обработки: locale
	-->
	<!--extrainfo — переопределенный шаблон dita-titles.xsl-->
	<xsl:template name="extra-info" dtm:id="extrainfo">
		<xsl:choose>
			<xsl:when test="processing-instruction('serna-extra-info') and text()=''">
				<fo:block>
					<fo:inline background-color="#e0e0e0" font-style="italic">
						<xsl:apply-templates/>
						<xsl:text> </xsl:text>
					</fo:inline>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<!--Обработка условных атрибутов: locale-->
				<xsl:call-template name="ditavalAttrs"/>
				<xsl:apply-templates
					select="*[not(self::processing-instruction('serna-extra-info'))]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!--ul/li-->
	<xsl:template match="*[contains(@class,' topic/ul ')]|
		*[contains(@class,' topic/sl ')]"
		dtm:id="topic.ul|sl">
		<xsl:call-template name="ditavalAttrs"/>
		<fo:list-block xsl:use-attribute-sets="ul">
			<xsl:apply-templates/>
		</fo:list-block>
	</xsl:template>

	<xsl:template
		match="*[contains(@class,' topic/ul ')]/
                     *[contains(@class,' topic/li ')]"
		dtm:id="topic.ul.li">
		<fo:list-item padding-bottom="0.4em">
			<fo:list-item-label end-indent="label-end()" text-align="end">
				<fo:block>
					<fo:inline>&#x2022;</fo:inline>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block>
					<!--Обработка условных атрибутов: locale-->
					<xsl:call-template name="ditavalAttrs"/>
					<xsl:apply-templates/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>


	<!--ol/li-->
	<xsl:template match="*[contains(@class,' topic/ol ')]" dtm:id="topic.ol">
		<xsl:call-template name="ditavalAttrs"/>
		<fo:list-block xsl:use-attribute-sets="ul">
			<xsl:apply-templates>
				<xsl:with-param name="level">
					<xsl:call-template name="get-list-level"/>
				</xsl:with-param>
			</xsl:apply-templates>
		</fo:list-block>
	</xsl:template>

	<xsl:template
		match="*[contains(@class,' topic/ol ')]/
                     *[contains(@class,' topic/li ')]"
		dtm:id="topic.ol.li">
		<xsl:param name="level"/>
		<xsl:param name="conref-context"/>
		<xsl:variable name="list-level">
			<xsl:choose>
				<xsl:when test="$conref-context">
					<xsl:for-each select="$conref-context">
						<xsl:call-template name="get-list-level"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:list-item padding-bottom="0.4em">
			<fo:list-item-label end-indent="label-end()" text-align="end">
				<fo:block>
					<!-- linefeed-treatment="ignore"-->
					<xsl:call-template name="generate-listitem-label">
						<xsl:with-param name="list-level" select="$list-level"/>
						<xsl:with-param name="conref-context" select="$conref-context"/>
					</xsl:call-template>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block>
					<!--Обработка условных атрибутов: locale-->
					<xsl:call-template name="ditavalAttrs"/>
					<xsl:apply-templates/>
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>


	<!--xref-->
	<xsl:template match="*[contains(@class,' topic/xref ')]" dtm:id="topic.xref">
		<!--[teux]-->
		<xsl:call-template name="ditavalAttrs"/>

		<fo:inline color="blue" text-decoration="underline">
			<xsl:choose>
				<xsl:when test="'external'=@scope">
					<xsl:choose>
						<xsl:when test="normalize-space() or *">
							<xsl:apply-templates/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="@href"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="normalize-space() or *">
					<xsl:apply-templates/>
					<xsl:if
						test="string(@href) and (@format='dita' or @format='DITA'
	                      or @format='ditamap' or @format='DITAMAP' or not(@format)
	                      or string-length(@format)=0)">
						<xsl:call-template name="href">
							<xsl:with-param name="show-title" select="false()"/>
							<xsl:with-param name="href" select="@href"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when
					test="not(@format='dita' or @format='DITA' or not(@format)
	                          or @format='ditamap' or string-length(@format)=0 
	                          or @format='DITAMAP')">
					<xsl:value-of select="@href"/>
				</xsl:when>
				<xsl:when test="string(@href)">
					<xsl:call-template name="href">
						<xsl:with-param name="href" select="@href"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<xsl:if test="@scope ='external' and not(href) and not($DRAFT-PRINT='yes')">
				<fo:external-graphic src="{concat('url(',$iconDir, 'link-ext.png)')}"/>
			</xsl:if>
			<xsl:variable name="nohref">
				<xsl:choose>
					<xsl:when test="not(@href) and not(href)">
						<xsl:value-of select="'[no @href]'"/>
					</xsl:when>
					<xsl:when test="string-length(@href) = 0 and not(href)">
						<xsl:value-of select="'[empty @href]'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="''"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="'' != $nohref and not($DRAFT-PRINT='yes')">
				<fo:inline color="red" text-decoration="normal">
					<xsl:value-of select="$nohref"/>
				</fo:inline>
			</xsl:if>
		</fo:inline>
	</xsl:template>


	<!--href-->
	<xsl:template match="href" priority="10">
		<xsl:if test="not($DRAFT-PRINT='yes')">
			<xsl:variable name="icon">
				<xsl:choose>
					<xsl:when test="parent::*/@scope='external'">
						<xsl:value-of select="'link-ext.png'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'link-local.png'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not(following-sibling::text())">
				<fo:external-graphic src="{concat('url(',$iconDir, $icon,')')}"/>
			</xsl:if>
			<fo:inline text-decoration="none">
				<xsl:apply-templates/>
			</fo:inline>
			<xsl:if test="following-sibling::text()">
				<fo:external-graphic src="{concat('url(',$iconDir, $icon,')')}"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>


	<!-- [teux 20.04.12] patch to show ditamap title -->
	<xsl:template name="xref-title" dtm:id="xref.title">
		<xsl:param name="elem"/>

		<xsl:variable name="title.text">
			<xsl:for-each select="$elem">
				<xsl:apply-templates select="." mode="reference.title"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($title.text) > 0">
				<xsl:value-of select="$title.text"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$elem[contains(@class,' topic/topic ')]">
						<fo:inline color="red" text-decoration="normal">
							<xsl:text>[no title: </xsl:text>
							<xsl:value-of select="string($elem)"/>
							<xsl:text>]</xsl:text>
						</fo:inline>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="contains($elem/@class, ' map/map ')">
								<xsl:if test="string-length($elem/@product) > 0">
									<xsl:value-of select="$elem/@product"/>
									<xsl:if test="string-length($elem/@title) > 0">
										<xsl:text>. </xsl:text>
									</xsl:if>
								</xsl:if>
								<xsl:if test="string-length($elem/@title) > 0">
									<xsl:value-of select="$elem/@title"/>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="$elem/ancestor::*[contains(@class,
									' topic/topic ')]/title"/>
								<xsl:text>: </xsl:text>
								<fo:inline font-style="italic">
									<xsl:value-of select="substring($elem, 0, 50)"/>
									<xsl:text>... </xsl:text>
								</fo:inline>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!--link-->
	<xsl:template match="*[contains(@class,' topic/link ')][not(@href = '') or href]"
		dtm:id="href2link">
		<fo:block color="blue" text-decoration="underline"
			start-indent="{$basic-start-indent} + {
			count(ancestor-or-self::*[contains(@class,' topic/linklist ')]) +
			count(ancestor-or-self::*[contains(@class,' topic/linkpool ')])}em">
			<!--[teux]-->
			<!--<xsl:text>&bullet; </xsl:text>-->
			<xsl:call-template name="ditavalAttrs"/>

			<xsl:choose>
				<xsl:when
					test="string(@href) and (@format='dita' or @format='DITA' 
					or not(@format))">
					<xsl:variable name="sourcefile">
						<xsl:choose>
							<xsl:when test="contains(@href, '#')">
								<xsl:value-of select="substring-before(@href,'#')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@href"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="topicid" select="substring-after(@href,'#')"/>
					<xsl:variable name="topicdoc" select="document($sourcefile,/)"
						xse:document-mode="validate"/>
					<xsl:variable name="linktext" select="*[contains(@class,' topic/linktext ')]"/>

					<xsl:if test="not(linktext) or not(linktext//text())">
						<xsl:choose>
							<xsl:when test="$topicdoc">
								<xsl:choose>
									<xsl:when test="$topicid and not(''=$sourcefile)">
										<xsl:value-of
											select="id($topicid, $topicdoc)//*[contains(@class, 'topic/title')]"
										/>
									</xsl:when>
									<xsl:when test="$topicid and ''=$sourcefile">
										<xsl:value-of
											select="id($topicid)//*[contains(@class, 'topic/title')]"
										/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="$topicdoc//*[contains(@class, 'topic/title')]"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="not(text())">
								<xsl:value-of
									select="preceding-sibling::node()[1][self::processing-instruction('docato-extra-info-title')]"
								/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not(linktext) or not(linktext/text())">
						<xsl:value-of select="@href"/>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates/>
			<xsl:if test="@scope ='external' and not(href) and not($DRAFT-PRINT='yes')">
				<fo:external-graphic src="{concat('url(',$iconDir, 'link-ext.png)')}"/>
			</xsl:if>
		</fo:block>
	</xsl:template>


	<!--ph-->
	<xsl:template match="*[contains(@class,' topic/ph ')]" dtm:id="topic.ph">
		<xsl:call-template name="ditavalAttrs"/>
		<fo:inline border-left-width="0pt" border-right-width="0pt" color="purple">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>


	<!--keyword-->
	<xsl:template match="*[contains(@class,' topic/keyword ')]" dtm:id="topic.keyword">
		<xsl:call-template name="ditavalAttrs"/>
		<fo:inline border-left-width="0pt" border-right-width="0pt" font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>


	<!--preformated-->
	<xsl:template match="*[contains(@class,' topic/pre ')]" dtm:id="topic.pre">
		<xsl:call-template name="gen-att-label"/>
		<fo:block xsl:use-attribute-sets="pre">
			<!-- setclass -->
			<!-- set id -->
			<xsl:call-template name="setscale"/>
			<xsl:call-template name="setframe"/>
			<xsl:call-template name="ditavalAttrs"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>


	<!--table-->
	<xsl:template match="*[contains(@class,' topic/table ')]" dtm:id="topic.table">
		<fo:block padding-bottom="1em">
			<xsl:if test="@pgwide=1">
				<xsl:attribute name="start-indent">-<xsl:value-of select="$basic-start-indent"
					/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>


	<!--q-->
	<xsl:template match="*[contains(@class, ' topic/q ')]">
		<xsl:choose>
			<xsl:when test="/*[contains(@class, ' topic/topic ')]/@xml:lang = 'ru'">
				<xsl:value-of select="'«'"/>
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
				<xsl:value-of select="'»'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'ˮ'"/>
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
				<xsl:value-of select="'ˮ'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
