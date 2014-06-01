# coding=UTF-8

# Teux plugin for Serna, 2012

from SernaApi import *
from os.path import dirname, normpath, join
from weakref import ref

import meta
from lib import *
from refs.keyref import keys


class LinkDblClickWatcher(SimpleWatcher):

	def __init__(self, plugin): 
		SimpleWatcher.__init__(self)
		self.__plugin = ref(plugin)


	def notifyChanged(self):
		pos = self.__plugin().se.getCheckedPos()
		if pos.isNull():
			return True
			
		meta.contextNode = nset('ancestor-or-self::*[1]', pos.node()).firstNode()
		ditaClass = vof('@class').split()
		
		# get href
		if vof('@conref') != '':
			href = vof('@conref')
		elif 'topic/linktext' in ditaClass or \
				'href-d/href' in ditaClass:
			href = vof('parent::*/@href')
			hrefNode = nset('parent::*/href').firstNode()
		elif 'topic/xref' in ditaClass or \
				'map/topicref' in ditaClass or \
				'topic/link' in ditaClass:
			href = vof('@href')
			hrefNode = nset('href').firstNode()
		else:
			return True

		# try href in element
		if href == '' and not hrefNode.isNull():
			href = textWithKeys(hrefNode, self.__plugin().docSrc)
		
		# follow link	
		if href == '':
			return True
		elif href.startswith(('http:', 'https:', 'ftp')):
			self.openInBrouser(href)
		elif href.startswith('#'):
			self.setCursorById(href)
		else:
			self.openFile(href)
		return False 
	
	
	def openInBrouser(self, href):
		''' Opens href in browser '''
		browse_info = PropertyNode("external-viewer")
		url_arg = PropertyNode("url", href)
		browse_info.appendChild(url_arg)
		self.__plugin().executeCommandEvent("LaunchBrowser", browse_info)
		

	def setCursorById(self, href, doc=None):
		''' Sets cursor position to element with id. Takes any node and looks in node's document.
				An optional doc is document in which to set position (current by default) '''
		if doc:
			meta.contextNode = doc.structEditor().sourceGrove().document()
		ids = href.replace('#','').partition('/') \
			if href.startswith('#') else (href,'','')
		if ids[2] != '':
			target = nset('//*[contains(@class, " topic/topic ")][@id="' + \
				ids[0] + '"]' + '//*[@id="' + ids[2] + '"]').firstNode()
		else:
			target = nset('//*[contains(@class, " topic/topic ")][@id="' + \
				ids[0] + '"]').firstNode()
		if target:
			se = doc.structEditor() if doc else self.__plugin().se
			child = nset('node()[1]', target).firstNode()
			pos = GrovePos(target) if child.isNull() else GrovePos(target, child)
			se.setCursorBySrcPos(pos, GroveNode(), True)
  

	def openFile(self, href):
		''' Opens referenced file and sets position on target '''
		baseDir = dirname(unicode(self.__plugin().sernaDoc().getDsi().\
			getProperty('doc-src').getString()))
		docSrc = normpath(join(baseDir, href)).replace('\\','/')
		
		# first look in opened docs
		lookPath = docSrc.partition('#')
		doc = self.__plugin().sernaDoc().parent().firstChild()
		while doc.asSernaDoc():
			docPath = doc.asSernaDoc().getDsi().getProperty("doc-src")
			if docPath:
				docPath = unicode(docPath.getString()).replace('\\','/')
				if docPath == lookPath[0]:
					if lookPath[2] != '':
						self.setCursorById(u'#'+lookPath[2], doc.asSernaDoc())
					doc.asSernaDoc().setActive()
					return
			doc = doc.nextSibling()
		
		# open doc
		dsi = PropertyNode('doc-src-info')
		dsi.appendChild(PropertyNode('doc-src', docSrc))
		self.__plugin().executeCommandEvent('OpenDocumentWithDsi', dsi)
		
		