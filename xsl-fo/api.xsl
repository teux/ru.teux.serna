<?xml version='1.0'?>

<xsl:stylesheet version='1.0'
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:se="http://www.syntext.com/XSL/Format-1.0"
    xmlns:dtm="http://syntext.com/Extensions/DocumentTypeMetadata-1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xse="http://www.syntext.com/Extensions/XSLT-1.0"
    xmlns:yfn="http://www.teux.ru/2010/XSL/functions"
    extension-element-prefixes="dtm yfn">


<xsl:variable name="amp_divider">
	<fo:inline xsl:use-attribute-sets="url__connector"> &amp; </fo:inline>
</xsl:variable>
<xsl:variable name="or_divider">
	<fo:inline xsl:use-attribute-sets="url__connector"> | </fo:inline>
</xsl:variable>
<xsl:variable name="qu_divider">
	<fo:inline xsl:use-attribute-sets="url__connector"> ? </fo:inline>
</xsl:variable>

	
<!-- getsummary -->
<xsl:template match="*[contains(@class,' api-d/getsummary ')]">
	<xsl:choose>
		<!-- режим черновой печати - формировать таблицу методов -->
		<xsl:when test ="$DRAFT-PRINT='yes'">
			<xsl:if test="ancestor::*[contains(@class,' api/api ')] and not(ancestor::*[contains(@class,' get/get ')])">
				<fo:block xsl:use-attribute-sets="otbivka__syntax">
					<xsl:call-template name="methodTable"/>
				</fo:block>
			</xsl:if>
		</xsl:when>
		<!-- режим разработки документа -->
		<xsl:otherwise>
			<fo:block xsl:use-attribute-sets="otbivka__syntax">
				<fo:block xsl:use-attribute-sets="getsummary">
					<fo:block xsl:use-attribute-sets="interim__title">Общие данные запроса</fo:block>
					<xsl:call-template name="insert_syntax">
						<xsl:with-param name="is_summary" select="true()"/>
					</xsl:call-template>
				</fo:block>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- methodTable - таблица методов для черновой печати -->
<xsl:template name="methodTable">
	<!-- Имена аргументов -->
	<xsl:variable name="constAll">
		<xsl:copy-of select="constant"/>
		<xsl:copy-of select="ancestor::api[1]/get/getbody//syntax/constant"/>
	</xsl:variable>
	<xsl:variable name="constUnique">
		<xsl:for-each select="$constAll/constant[not(name=preceding-sibling::*/name)]">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="countConst" select="count($constUnique/*)"/>
	<fo:table table-layout="auto">
		<!-- заголовок -->
		<fo:table-header xsl:use-attribute-sets="list__method__header" keep-with-next.within-page="always">
			<fo:table-row keep-with-next.within-page="always">
				<fo:table-cell xsl:use-attribute-sets="list__method__header__cell" number-rows-spanned="2">Метод</fo:table-cell>
				<fo:table-cell xsl:use-attribute-sets="list__method__header__cell" number-rows-spanned="2">Описание</fo:table-cell>
				<xsl:if test="$countConst &gt; 0">
					<fo:table-cell xsl:use-attribute-sets="list__method__header__cell" number-columns-spanned="{count($constUnique/*)}" text-align="center">Постоянные аргументы</fo:table-cell>
				</xsl:if>
			</fo:table-row>
			<xsl:if test="$countConst &gt; 0">
				<fo:table-row keep-with-previous.within-page="always">
					<xsl:for-each select="$constUnique/*">
						<fo:table-cell xsl:use-attribute-sets="list__method__header__cell" text-align="center">
							<fo:inline xsl:use-attribute-sets="const__name">
								<xsl:value-of select="name"/>
							</fo:inline>
						</fo:table-cell>
					</xsl:for-each>
				</fo:table-row>
			</xsl:if>
		</fo:table-header>
		<!-- тело -->
		<fo:table-body xsl:use-attribute-sets="list__method__body">
			<xsl:for-each select="ancestor::api[1]/get">
				<xsl:variable name="curMethod" select="."/>
				<fo:table-row>
					<fo:table-cell xsl:use-attribute-sets="list__method__body__cell"><xsl:value-of select="@id"/></fo:table-cell>
					<fo:table-cell xsl:use-attribute-sets="list__method__body__cell"><xsl:value-of select="shortdesc"/></fo:table-cell>
					<!-- аргументы -->
					<xsl:for-each select="$constUnique/*">
						<xsl:variable name="name" select="name"/>
						<fo:table-cell text-align="center" xsl:use-attribute-sets="list__method__body__cell">
							<xsl:choose>
								<xsl:when test="$curMethod/getbody//syntax[1]/constant[name=$name]">
									<xsl:value-of select="$curMethod/getbody//syntax[1]/constant[name=$name]/value"/>
								</xsl:when>
								<!-- встаить общие, только если не задан локальный url  -->
								<xsl:when test="not($curMethod/getbody//syntax[1]/url)">
									<xsl:value-of select="value"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>—</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</fo:table-cell>
					</xsl:for-each>
				</fo:table-row>
			</xsl:for-each>
		</fo:table-body>
	</fo:table>
</xsl:template>


<!-- syntax -->
<xsl:template match="*[contains(@class,' get/syntax ')]">
	<fo:block xsl:use-attribute-sets="otbivka__syntax">
		<fo:block xsl:use-attribute-sets="syntax">
			<!-- <fo:block xsl:use-attribute-sets="interim__title">Синтаксис запроса</fo:block> -->
			<xsl:call-template name="insert_syntax"/>
		</fo:block>
	</fo:block>
</xsl:template>


<!-- instance -->
<xsl:template match="*[contains(@class,' get/instance ')]">
	<fo:block xsl:use-attribute-sets="otbivka__syntax">
		<fo:block xsl:use-attribute-sets="instance">
			<xsl:call-template name="insert_syntax"/>
		</fo:block>
	</fo:block>
</xsl:template>


<!-- insert_syntax -->
<xsl:template name="insert_syntax">
	<xsl:param name="is_summary" select="false()"/>
	<!-- getsummary из get, а если там нет - из вышестоящего api  -->
	<xsl:variable name="getsummary">
		<xsl:choose>
			<xsl:when test="count(ancestor::*[contains(@class, ' get/getbody ')]/*[contains(@class, ' api-d/getsummary ')]) != 0">
				<xsl:copy-of select="ancestor::*[contains(@class, ' get/getbody ')]/*[contains(@class, ' api-d/getsummary ')][1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="ancestor::api[1]/apibody/getsummary[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<fo:block xsl:use-attribute-sets="interim__block__first">
		<!-- url -->
		<xsl:choose>
			<!-- задан -->
			<xsl:when test="count(url) > 0">
				<xsl:apply-templates select="url">
					<xsl:with-param name="is_summary" select="$is_summary"/>
					<xsl:with-param name="getsummary" select="$getsummary"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- не задан -->
			<xsl:otherwise>
				<xsl:apply-templates select="exsl:node-set($getsummary)//url[1]">
					<xsl:with-param name="self_const" select="self::*[self::syntax | self::instance]/*[self::constant][@method='get']"/>
				  <xsl:with-param name="self_var" select="self::*[self::syntax | self::instance]/*[self::variable][@method='get']"/>
					<xsl:with-param name="editable" select="false()"/>
					<xsl:with-param name="getsummary" select="$getsummary"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
	<xsl:if test="not(self::instance and $DRAFT-PRINT='yes')">
		<!-- постоянные аргументы -->
		<xsl:if test="count(constant) > 0">
			<fo:block xsl:use-attribute-sets="interim__block">
				<fo:block xsl:use-attribute-sets="interim__title">Постоянные аргументы</fo:block>
				<xsl:apply-templates select="constant"/> 
			</fo:block>
		</xsl:if>
		<!-- переменные аргументы -->
		<xsl:if test="count(variable) > 0">
			<fo:block xsl:use-attribute-sets="interim__block">
				<fo:block xsl:use-attribute-sets="interim__title">Переменные аргументы</fo:block>
				<xsl:apply-templates select="variable"/> 
			</fo:block>
		</xsl:if>
	</xsl:if>
</xsl:template>


<!-- deflist -->
<xsl:template match="*[contains(@class,' api-d/deflist ')]">
	<fo:block xsl:use-attribute-sets="otbivka__syntax">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>


<!-- deflist/name -->
<xsl:template match="*[contains(@class,' api-d/deflist ')]//*[contains(@class,' api-d/name ')]">
	<fo:block xsl:use-attribute-sets="otbivka__p">
		<!-- <fo:inline xsl:use-attribute-sets="bullet">
			<xsl:text>· </xsl:text>
		</fo:inline> -->
		<fo:inline xsl:use-attribute-sets="defl__name">
			<xsl:if test="parent::*[contains(@class, ' api-d/attribute ')]"><xsl:text>@</xsl:text></xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
		<xsl:if test="$DRAFT-PRINT='no'">
			<xsl:if test="parent::*/@required = 'required'">
				<xsl:text>*</xsl:text>
			</xsl:if>
			<fo:inline xsl:use-attribute-sets="interim__label">
				<xsl:if test="parent::element"><xsl:text>, элемент</xsl:text></xsl:if>
				<xsl:if test="parent::attribute"><xsl:text>, атрибут</xsl:text></xsl:if>
			</fo:inline>
			<xsl:apply-templates select="parent::*/@optional"/>
		</xsl:if>
	</fo:block>
</xsl:template>


<!-- url - формирование урла из параметров -->
<xsl:template match="*[contains(@class,' api-d/url ')]">
	<xsl:param name="self_const" select="parent::*[self::syntax | self::instance]/constant[@method='get']"/>
  <xsl:param name="self_var" select="parent::*[self::syntax | self::instance]/variable[@method='get']"/>
	<xsl:param name="editable" select="true()"/>
	<xsl:param name="is_summary" select="false()"/>
	<xsl:param name="getsummary"/>
  
  <xsl:variable name="summary_const" select="$getsummary//constant[@method='get']"/>
  
	<fo:block xsl:use-attribute-sets="url__pagination">
		<!-- протокол и домен -->
		<fo:inline xsl:use-attribute-sets="field">
			<xsl:if test="$editable"><xsl:apply-templates select="protocol"/></xsl:if>
			<xsl:if test="not($editable)"><xsl:value-of select="protocol"/></xsl:if>
		</fo:inline>
		<fo:inline xsl:use-attribute-sets="interim__label">://</fo:inline>
		<fo:inline xsl:use-attribute-sets="field">
			<xsl:if test="$editable"><xsl:apply-templates select="domain"/></xsl:if>
			<xsl:if test="not($editable)"><xsl:value-of select="domain"/></xsl:if>
		</fo:inline>
		<xsl:choose>
			<!-- аргументы не заданы -->
			<xsl:when test="count($self_const) + count($self_var) = 0 and
			               (count($summary_const) = 0 or ($editable and not($is_summary)))">
				<!--<fo:inline xsl:use-attribute-sets="interim__label">?...</fo:inline>-->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$qu_divider"/>
				<!-- общие из getsummary - только если url не переопределен локально в syntax -->
				<xsl:if test="not($editable) or $is_summary">
				  <xsl:apply-templates select="$summary_const" mode="const_list"/>
				</xsl:if>
				<!-- разделитель, только если имеются константы из getsummary и локальные, а также url не переопределен локально  -->
			  <xsl:if test="count($self_const) &gt; 0 and count($summary_const) &gt; 0  and parent::getsummary">
					<xsl:copy-of select="$amp_divider"/>
				</xsl:if>
				<!-- из локального определения метода -->
				<xsl:apply-templates select="$self_const" mode="const_list"/>
				<!-- первый var - может не иметь предварительного амперсанда  -->
				<xsl:apply-templates select="$self_var[1]" mode="var_list">
					<xsl:with-param name="count" select="count($self_var)"/>
					<xsl:with-param name="amp">
					  <xsl:if test="count($summary_const) &gt; 0 or count($self_const/*) &gt; 0">
							<xsl:copy-of select="$amp_divider"/>
						</xsl:if>
					</xsl:with-param>
				</xsl:apply-templates>
				<!-- следующие var  -->
				<xsl:apply-templates select="$self_var[not(position()=1)]" mode="var_list">
					<xsl:with-param name="count" select="count($self_var)"/>
					<xsl:with-param name="amp" select="$amp_divider"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</fo:block>
</xsl:template>


<!-- constant in url -->
<xsl:template match="*" mode="const_list">
	<xsl:if test="@required='optional'"><fo:inline xsl:use-attribute-sets="url__connector">[</fo:inline></xsl:if>
	<fo:inline xsl:use-attribute-sets="var__name">
		<xsl:value-of select="./name"/>
	</fo:inline>
	<fo:inline>
		<xsl:text> = </xsl:text>
		<xsl:value-of select="./value"/>
	</fo:inline>
	<!-- угловая скобка для опциональных -->
	<xsl:if test="@required='optional'"><fo:inline xsl:use-attribute-sets="url__connector">]</fo:inline></xsl:if>
	<!-- разделитель -->
	<xsl:if test="position() &lt; last()"><xsl:copy-of select="$amp_divider/*"/></xsl:if>
</xsl:template>


<!-- variable in url -->
<xsl:template match="*" mode="var_list">
	<xsl:param name="count"/>
	<xsl:param name="amp"/>
	<xsl:choose>
		<xsl:when test="ancestor::*[contains(@class, ' get/instance ')] or $count &lt; 4">
			<xsl:call-template name="insert_var">
				<xsl:with-param name="amp" select="$amp"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<fo:block xsl:use-attribute-sets="var__syntax">
				<xsl:call-template name="insert_var">
					<xsl:with-param name="amp" select="$amp"/>
				</xsl:call-template>
			</fo:block>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- insert_var - вставить переменный аргумент -->
<xsl:template name="insert_var">
	<xsl:param name="amp"/>
	<!-- разделитель - амперсанд или черта  -->
	<xsl:choose>
		<xsl:when test="@choice='previous'">
			<xsl:copy-of select="$or_divider/*"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$amp/*"/>
		</xsl:otherwise>
	</xsl:choose>
	<!-- угловая скобка для опциональных, которые не являются альтернативой предыдущему аргументу  -->
	<xsl:if test="@required='optional' and not(@choice='previous')"><fo:inline xsl:use-attribute-sets="url__connector">[</fo:inline></xsl:if>
	<!-- круглая скобка, если первый аргумент из списка аналогов -->
	<xsl:if test="@choice='no' and following-sibling::*[1][@choice='previous']"><fo:inline xsl:use-attribute-sets="url__connector">(</fo:inline></xsl:if>
	<fo:inline xsl:use-attribute-sets="var__name">
		<xsl:value-of select="./name"/>
	</fo:inline>
	<fo:inline>
		<xsl:text> = </xsl:text>
		<xsl:if test="not(ancestor::instance)"><xsl:text>&lt;</xsl:text></xsl:if>
		<xsl:value-of select="./value"/>
		<xsl:if test="not(ancestor::instance)"><xsl:text>&gt;</xsl:text></xsl:if>
	</fo:inline>
	<xsl:choose>
		<!-- последний аргумент из списка аналогов -->
		<xsl:when test="@choice='previous' and not(following-sibling::*[1][@choice='previous'])">
			<fo:inline xsl:use-attribute-sets="url__connector">)</fo:inline>
			<xsl:if test="preceding-sibling::*[@choice='no'][1]/@required='optional'">
				<fo:inline xsl:use-attribute-sets="url__connector">]</fo:inline>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<!-- угловая скобка для опциональных -->
			<xsl:if test="@required='optional' and not(following-sibling::*[1][@choice='previous'])">
				<fo:inline xsl:use-attribute-sets="url__connector">]</fo:inline>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- protocol -->
<xsl:template match="*[contains(@class,' api-d/protocol ')]">
	<fo:inline><xsl:apply-templates/></fo:inline>
</xsl:template>


<!-- constant -->
<xsl:template match="*[contains(@class,' api-d/constant ')]">
	<fo:block xsl:use-attribute-sets="general__pagination">
		<fo:inline xsl:use-attribute-sets="field">
			<xsl:apply-templates select="name"/>
		</fo:inline>
		<fo:inline xsl:use-attribute-sets="interim__label"> = </fo:inline>
	  <fo:inline xsl:use-attribute-sets="var__value">
			<xsl:apply-templates select="value"/>
	  </fo:inline>
		<xsl:apply-templates select="@method"/>
		<xsl:apply-templates select="@required"/>
	  <xsl:apply-templates select="@encode"/>
	</fo:block>
</xsl:template>


<!-- variable -->
<xsl:template match="*[contains(@class,' api-d/variable ')]">
	<!-- name -->
	<fo:block xsl:use-attribute-sets="interim__block">
		<fo:block xsl:use-attribute-sets="var__definition">
			<xsl:if test="@choice='previous'">
				<fo:inline xsl:use-attribute-sets="interim__label">| </fo:inline>
			</xsl:if>
			<xsl:if test="@required='optional'">
				<fo:inline xsl:use-attribute-sets="interim__label">[</fo:inline>
			</xsl:if>
			<fo:inline xsl:use-attribute-sets="field">
				<xsl:apply-templates select="name"/>
			</fo:inline>
			<xsl:if test="@required='optional'">
				<fo:inline xsl:use-attribute-sets="interim__label">]</fo:inline>
			</xsl:if>
			<!-- value -->
			<fo:inline xsl:use-attribute-sets="interim__label"> = </fo:inline>
			<xsl:if test="not(ancestor::instance)">
				<fo:inline xsl:use-attribute-sets="interim__label">&lt;</fo:inline>
			</xsl:if>
			<fo:inline xsl:use-attribute-sets="var__value">
				<xsl:apply-templates select="value"/>
			</fo:inline>
			<xsl:if test="not(ancestor::instance)">
				<fo:inline xsl:use-attribute-sets="interim__label">&gt;</fo:inline>
			</xsl:if>
			<xsl:apply-templates select="@method"/>
			<xsl:apply-templates select="@required"/>
		  <xsl:apply-templates select="@encode"/>
			<xsl:apply-templates select="@choice"/>
		</fo:block>
	</fo:block>
	<!-- description -->
	<xsl:if test="count(description) > 0">
		<fo:block xsl:use-attribute-sets="otbivka__p arg__description">
			<xsl:apply-templates select="description"/>
		</fo:block>
	</xsl:if>
</xsl:template>


<!-- @required - обязательный/необязательный аргумент -->
<xsl:template match="*[contains(@class,' api-d/constant ')]/@required
											| *[contains(@class,' api-d/variable ')]/@required
											| *[contains(@class,' api-d/element ')]/@optional
											| *[contains(@class,' api-d/attribute ')]/@optional">
  <xsl:if test="not(ancestor::*[contains(@class, ' get/instance ')] or $DRAFT-PRINT='yes')">
		<fo:inline>
			<xsl:text> </xsl:text>
		</fo:inline>
		<fo:inline xsl:use-attribute-sets="combo-box">
			<se:combo-box value="{string(.)}" width="65px">
				<se:value>required</se:value>
				<se:value>optional</se:value>
			</se:combo-box>
		</fo:inline>
	</xsl:if>
</xsl:template>


<!-- @choice - альтернатива предыдущему -->
<xsl:template match="*[contains(@class,' api-d/variable ')]/@choice">
  <xsl:if test="not(ancestor::*[contains(@class, ' get/instance ')] or $DRAFT-PRINT='yes')
                    and parent::*[preceding-sibling::*[contains(@class,' api-d/variable ')]]">
		<fo:inline xsl:use-attribute-sets="interim__label">  альтернатива: </fo:inline>
		<fo:inline xsl:use-attribute-sets="combo-box">
			<se:combo-box value="{string(.)}" width="60px">
				<se:value>no</se:value>
				<se:value>previous</se:value>
			</se:combo-box>
		</fo:inline>
	</xsl:if>	
</xsl:template>


<!-- @method - метод HTTP-запроса: get или post-->
  <xsl:template match="*[contains(@class,' api-d/constant ')]/@method | *[contains(@class,' api-d/variable ')]/@method">
  <xsl:if test="not($DRAFT-PRINT='yes')">
    <fo:inline xsl:use-attribute-sets="combo-box">
      <fo:inline>
        <xsl:text> </xsl:text>
      </fo:inline>
      <se:combo-box value="{string(.)}" width="50px">
        <se:value>get</se:value>
        <se:value>post</se:value>
      </se:combo-box>
    </fo:inline>
  </xsl:if>	
</xsl:template>


  <!-- @encode - способ кодирования-->
  <xsl:template match="*[contains(@class,' api-d/constant ')]/@encode | *[contains(@class,' api-d/variable ')]/@encode">
  	<xsl:if test="not($DRAFT-PRINT='yes') and ancestor::*[contains(@class, ' get/instance ') or contains(@class, ' api-d/getsummary ')]">
      <fo:inline xsl:use-attribute-sets="combo-box">
        <fo:inline>
          <xsl:text> </xsl:text>
        </fo:inline>
        <se:combo-box value="{string(.)}" width="70px">
          <se:value>no-encode</se:value>
          <se:value>base64</se:value>
          <se:value>urlencode</se:value>
        	<se:value>gzip</se:value>
        </se:combo-box>
      </fo:inline>
    </xsl:if>	
  </xsl:template>


<!-- name -->
<xsl:template match="*[contains(@class,' api-d/name ')]">
	<xsl:choose>
		<xsl:when test="parent::constant">
			<fo:inline xsl:use-attribute-sets="const__name"><xsl:apply-templates/></fo:inline>
		</xsl:when>
		<xsl:when test="parent::variable">
			<fo:inline xsl:use-attribute-sets="var__name"><xsl:apply-templates/></fo:inline>
		</xsl:when>
	</xsl:choose>
</xsl:template>


<!-- method -->
<xsl:template match="*[contains(@class,' api-d/method ')]">
	<fo:inline xsl:use-attribute-sets="method__keyword"><xsl:apply-templates/></fo:inline>
</xsl:template>


<!-- argname -->
<xsl:template match="*[contains(@class,' api-d/argname ')]">
	<fo:inline xsl:use-attribute-sets="var__name"><xsl:apply-templates/></fo:inline>
</xsl:template>

	
</xsl:stylesheet>
