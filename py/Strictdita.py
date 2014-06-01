# coding=UTF-8

# Teux plugin for Serna, 2012

from subprocess import *
from shutil import *
from os import access, listdir, F_OK
from os.path import dirname, basename, normpath
from string import strip

from SernaApi import *

import meta
from lib import *


class StrictDITA(DocumentPlugin):

	def __init__(self, a1, a2):
		DocumentPlugin.__init__(self, a1, a2)
		self.buildPluginExecutors(True)
		self.se = self.sernaDoc().structEditor()
		self.iconsDir = normpath('%s/../icons/'%dirname(__file__)).replace('\\','/')

	
	def beforeTransform(self):
		''' Registers iconDir function in XSL-FO '''
		self.__icondirFunc = XsltExternalFunction('iconDir', 'http://www.teux.ru/2010/XSL/functions')
		self.__icondirFunc.eval = self.iconDir
		self.se.xsltEngine().registerExternalFunction(self.__icondirFunc)


	def iconDir(self,params):
		return XpathValue(self.iconsDir)
		
		
	def executeUiEvent(self, evName, cmd):
		if evName == "insertTableGroupHeaderMsgEvent":
		  self.insertTableGroup()


	def insertTableGroup(self):
		''' Inserts tgroup with thead and tbody like in first tgroup '''
		pos = self.se.getCheckedPos()
		meta.contextNode = pos.node()
		table = nset(\
			"ancestor-or-self::*[contains(@class,'- topic/table ')]").firstNode()
		tgroup = nset(\
			"ancestor-or-self::*[contains(@class,'- topic/tgroup ')]").firstNode()
		if table.isNull():
			self.sernaDoc().showMessageBox(self.sernaDoc().MB_INFO, 'Info', \
				u'Для добавления <tgroup> выберите любой элемент в таблице','OK')
			return
		if tgroup.isNull():
			if pos.before().nodeName() == 'tgroup':	# inside table but outside tgroup
				intoPos = pos
			else:
				firstTgroup = nset(\
					"*[contains(@class,'- topic/tgroup ')][1]", table).firstNode()
				if firstTgroup.isNull():
					intoPos = GrovePos(table)
				else:
					intoPos = GrovePos(table, firstTgroup)
			self.tgroupIntoGroove(intoPos)
		else:
			# inside tgroup - append or insert before next tgroup, if present   
			nextTgroup = nset(\
				"following-sibling::*[contains(@class,'- topic/tgroup ')]", \
				tgroup).firstNode()
			if nextTgroup.isNull():
				intoPos = GrovePos(table)
			else:
				intoPos = GrovePos(table, nextTgroup)
			self.tgroupIntoGroove(intoPos)
		meta.contextNode = None
		

	def tgroupIntoGroove(self, pos):
		''' Inserts tgroup same as a first tgroup into pos '''
		meta.contextNode = nset(\
			"ancestor::*[contains(@class,'- topic/tgroup ')]").firstNode()
		if meta.contextNode.isNull():
			meta.contextNode = nset(\
				"*[contains(@class,'- topic/tgroup ')][1]", pos.node()).firstNode()
			
		colspecs = nset("*[contains(@class,'- topic/colspec ')]")
		colnum = 2		# default columns number 
		colWidth = []
		if not(meta.contextNode.isNull()):
			# compute columns number based on colspec or entries
			if colspecs.size():
				colnum = colspecs.size()
				#widths
				for c in colspecs:
					colWidth.append(c.asGroveElement().attrs().\
					getAttribute('colwidth').value())
			else:
				colnum1 = nset('*[%s][1]/*[%s][1]/*[%s]'%(\
					'contains(@class,"- topic/tbody ")',\
					'contains(@class,"- topic/row ")',\
					'contains(@class,"- topic/entry ")'\
				)).size()
				if colnum1 != 0:
					colnum = colnum1
		
		# tgroup
		tgroup = GroveElement("tgroup")
		tgroup.attrs().appendChild(GroveAttr('cols', str(colnum)))
		
		# colspec
		for c in colspecs:
			colspec = GroveElement('colspec')
			self.addAttr(c, 'colname', colspec)
			self.addAttr(c, 'colnum', colspec)
			self.addAttr(c, 'colwidth', colspec)
			self.addAttr(c, 'popup', colspec)
			self.addAttr(c, 'popuphead', colspec)
			tgroup.appendChild(colspec)
			
		# thead
		row = GroveElement("row")
		for e in nset('*[%s]/*[1]/*'%'contains(@class,"- topic/thead ")'):	# walk entrys
			entry = GroveElement("entry")
			a = e.asGroveElement().attrs().firstChild()
			while a.asGroveAttr():
				if a.asGroveAttr().specified():
					entry.attrs().appendChild(GroveAttr(
						unicode(a.nodeName()), unicode(a.asGroveAttr().value())))
				a = a.nextSibling()
			row.appendChild(entry)
		thead = GroveElement("thead")
		thead.appendChild(row)
		tgroup.appendChild(thead)
		
		#add tbody with one row
		row = GroveElement("row")
		c=1
		while c <= colnum:
			entry = GroveElement("entry")
			row.appendChild(entry)
			c = c+1
		tbody = GroveElement("tbody")
		tbody.appendChild(row)
		tgroup.appendChild(tbody)
		
		fragment = GroveDocumentFragment()
		fragment.appendChild(tgroup)
		self.se.executeAndUpdate(self.se.groveEditor().paste(fragment, pos))
			

	def addAttr(self, src, attrName, dst):
		'''
			Adds attribute with attrName to dst element with the value as the same name attribute in src element
		'''
		attr = src.asGroveElement().attrs().getAttribute(attrName)
		if not(attr.isNull()):
			if attr.specified():
				attr.build()
				dst.attrs().appendChild(GroveAttr(attrName, str(attr.value())))
