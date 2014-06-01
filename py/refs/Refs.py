# coding=UTF-8

# Teux plugin for Serna, 2012

from sys import exc_info
from os import access, F_OK
from os.path import dirname, basename

from SernaApi import *

sys.path.append(dirname(dirname(__file__)))
import meta
from lib import *

from followRef import LinkDblClickWatcher
from keyref import keys
from xref import targets
from dialog.KeyInsertDialog import keyDialog
from dialog.IdAppendDialog import IdAppendDialog
from dialog.RefInsertDialog import RefInsertDialog

		
class Refs(DocumentPlugin):

	def __init__(self, a1, a2):
		DocumentPlugin.__init__(self, a1, a2)
		self.buildPluginExecutors(True)
		self.se = self.sernaDoc().structEditor()
		self.docSrc = unicode(self.sernaDoc().getDsi().\
			getProperty('doc-src').getString()).replace('\\','/')
		self.__watcher = LinkDblClickWatcher(self)
		self.se.setDoubleClickWatcher(self.__watcher)
		self.currentFile = None	# file to which reference was made last time
		

	def beforeTransform(self):
		self._getKey2Fo = XsltExternalFunction(\
			'getKey', 'http://www.teux.ru/2010/XSL/functions')
		self._getKey2Fo.eval = self.getKey2Fo
		self.sernaDoc().structEditor().\
			xsltEngine().registerExternalFunction(self._getKey2Fo)
		
	
	def postInit(self):
		root = self.se.sourceGrove().document().documentElement()
		klass = vof('@class', root)
		if klass.find(' map/map ') > 0:
			# ditamap registers itself in keys collection
			keys.openDitamap(self.docSrc)
		elif not access(self.docSrc, F_OK):
			# new document - set id
			file = basename(self.docSrc)
			id = file[0:file.rfind('.')] if '.' in file else file
			root.attrs().setAttribute(GroveAttr('id', id))
		elif not nset('@id', root).firstNode().isNull():
			# check id
			fname = basename(self.docSrc).rpartition('.')[0]
			id = vof('@id', root)
			if fname != id:
				self.sernaDoc().messageView().emitMessage(\
					u'Идентификатор "%s" не соответствует имени файла'%id, root)
		# delete empty ids
		for e in nset('descendant::*[count(@id)>0 and normalize-space(@id)=""]', root):
			id = e.asGroveElement().attrs().getAttribute('id')
			self.se.executeAndUpdate(self.se.groveEditor().removeAttribute(id))
			self.sernaDoc().messageView().emitMessage(\
				u'Удален пустой атрибут id у элемента <%s>'%e.nodeName(), e)
	

	def preClose(self):
		''' Unregisters ditamap in keys collection '''
		klass = vof('@class', self.se.sourceGrove().document().documentElement())
		if klass.find(' map/map ') > 0:
			keys.closeDitamap(self.docSrc)
		return True
		
	
	def executeUiEvent(self, evName, cmd):
		if self.se.getCheckedPos().isNull():
			return
		if evName == "keyrefMsgEvent":
			self.insertKeyrefEvent()
		elif evName == "xrefMsgEvent":
			self.insertRefEvent()
		elif evName == "idMsgEvent":
			self.appendIdEvent()


	def getKey2Fo(self, params):
		''' Returns key value '''
		key = unicode(params[0].getString())
		try:
			return XpathValue(keys[self.docSrc][key])
		except:
			return XpathValue(unicode(exc_info()[1]))	# debug
	
	
	def insertKeyrefEvent(self):
		''' Issues InsertKeyDialog and inserts selected key '''
		self.docSrc = unicode(self.sernaDoc().getDsi().\
			getProperty('doc-src').getString()).replace('\\','/')	# docSrc could be changed after saveAs  
		
		mapKeys = keys[self.docSrc]
		if mapKeys.count() == 0:
			if mapKeys.ditamap() != '':
				self.sernaDoc().showMessageBox(0, u'Вставить ключ', \
				u'Не заданы ключи в ditamap \n' + mapKeys.ditamap(), 'OK')
			else:
				self.sernaDoc().showMessageBox(0, u'Вставить ключ', \
				u'Откройте ditamap, в котором имеется ссылка на текущий файл и заданы ключи.', 'OK')
			return
		keyDialog.setKeys(mapKeys)
		if keyDialog.exec_() == 1:
			fragment = GroveDocumentFragment()
			tag = GroveElement(keyDialog.tag())
			tag.attrs().appendChild(GroveAttr('keyref', keyDialog.key()))
			fragment.appendChild(tag)
			cmd = self.se.groveEditor().paste(fragment, self.se.getCheckedPos())
			self.se.executeAndUpdate(cmd)
		
	
	def appendIdEvent(self):
		''' Issues IdAppendDialog and appends id '''
		meta.contextNode = self.se.getCheckedPos().node()
		nodes = []
		for n in nset('ancestor-or-self::*'):
			nodes.insert(0,	{'name': unicode(n.nodeName()), 'id': vof('@id', n)})
		dlg = IdAppendDialog(nodes)
		if dlg.exec_() > 0:
			pos, val = dlg.id()
			node = nset('ancestor-or-self::*[' + str(pos) + ']').firstNode()
			idAtt = nset('@id', node).firstNode().asGroveAttr()
			setOptionalAttribute(self.se, node, idAtt, 'id', val)
		
	
	def insertRefEvent(self):
		''' Issues xrefInsertDialog and inserts xref, conref or link '''
		dlg = RefInsertDialog(self.sernaDoc(), self.currentFile)
		if dlg.exec_() == 1:
			res = dlg.result
			if res['action'] == 'edit':
				self.editRef(res)
			elif res['action'] == 'new':
				self.insertRef(res)
			elif res['action'] == 'wrap':
				self.wrapSelection(res)
			self.currentFile = dlg.currentFile()
	
	
	def editRef(self, res):
		''' Edits text or attributes of link, xref, conref '''
		# copy initial link
		node = res['spos'].node().copyAsFragment().firstChild()
		
		# remove source link from document
		command = GroveBatchCommand()
		command.executeAndAdd(self.se.groveEditor().removeNode(res['spos'].node()))
		res['spos'] = command.pos()
		self.se.executeAndUpdate(command)
		
		# preserve attributes except conref, href, scope, popup, format
		exclude = ('conref, href, scope, popup, format')
		res['attrs'] = []
		for a in nset('@*', node):
			a = a.asGroveAttr()
			if not(str(a.nodeName()) in exclude) and a.specified():
				res['attrs'].append(\
					GroveAttr(str(a.nodeName()), unicode(a.value())) )
					
		# preserve href element
		href = nset('href', node).firstNode().takeAsFragment() 
		if href.countChildren() > 0 and res['href-as-text']:
			res['href-preserve'] = href
		
		# preserve text
		if not(res['text-enable']):
			if vof('@class', node).find(' topic/link ') > 0:
				node = nset('linktext', node).firstNode()
			res['text-preserve'] = node.takeAsFragment()
		
		
		self.insertRef(res)
		
		
	def insertRef(self, res):
		''' Inserts new link, xref, conref '''
		if res['tag'] == '':
			return
		frag = GroveDocumentFragment()
		elem = GroveElement(res['tag'])
		
		# special case when insert conref on table - append required children
		if res['attr'] == 'conref' and res['action'] == 'new' \
				and res['tag'] == 'table':
			tgroup = GroveElement('tgroup')
			tgroup.attrs().setAttribute(GroveAttr('cols', '-dita-use-conref-target'))
			tbody = GroveElement('tbody')
			row = GroveElement('row')
			entry = GroveElement('entry')
			row.appendChild(entry)
			tbody.appendChild(row)
			tgroup.appendChild(tbody)
			elem.appendChild(tgroup)
		 
		# attributes
		if res['link'] and not(res['href-as-text']):
			elem.attrs().setAttribute(GroveAttr(res['attr'], res['link']))
		if res['scope'] == 'external':
			elem.attrs().setAttribute(GroveAttr('scope', 'external'))
		if res['popup'] == 'yes':
			elem.attrs().setAttribute(GroveAttr('popup', 'yes'))
		if 'attrs' in res.keys():
			for a in res['attrs']:
				elem.attrs().setAttribute(a)

		# text
		if 'text-preserve' in res.keys():
			# stored nodes
			node = res['text-preserve'].firstChild()
			if node.nodeName() == 'linktext':
				elem.appendChild(node.cloneNode(True))
			else:
				for n in nset('node()', node):
					elem.appendChild(n.cloneNode(True))
		elif res['text'] != '':
			linktext = GroveText(res['text'])
			# for <link> put text in <linktext>
			if res['tag'] == 'link':
				e = GroveElement('linktext')
				e.appendChild(linktext)
				linktext = e
			elem.appendChild(linktext)
		
		# href as text
		if 'href-preserve' in res.keys():
			elem.appendChild(\
				res['href-preserve'].firstChild().cloneNode(True))
		elif res['href-as-text']:
			href = GroveElement('href')
			href.appendChild(GroveText(res['link']))
			elem.appendChild(href)
		frag.appendChild(elem)
		self.se.executeAndUpdate(\
			self.se.groveEditor().paste(frag, res['spos']))
		
		
	def wrapSelection(self, res):
		''' Deletes selected text before inserting ref '''
		tlen = res['epos'].idx() - res['spos'].idx()	# selection lengtch 
		self.se.executeAndUpdate(\
			self.se.groveEditor().removeText(res['spos'], tlen))
		res['action'] = 'new'
		self.insertRef(res)
		
