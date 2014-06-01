# coding=UTF-8

# Teux plugin for Serna, 2012

from os import chdir
from os.path import basename, dirname, join, abspath, relpath
from PyQt4 import QtGui, QtCore, uic
from PyQt4 import Qt 

import meta
from lib import *
from refs.xref import targets, FilterIds


geometry = None	# reuseable dialog geometry 

class RefInsertDialog(QtGui.QDialog):
	
	def __init__(self, doc, lastFile):
		''' lastFile — absolute path of last target file	'''
		super(RefInsertDialog, self).__init__()
		uiPath = join(dirname(__file__), 'ui/refInsert.ui')
		uic.loadUi(uiPath, self)
		self.buildDialog()
		self.setModal(True)
		if geometry != None:
			self.setGeometry(geometry)
		# vars
		self.se = doc.structEditor()
		self.file = unicode(doc.getDsi(). \
			getProperty('doc-src').getString()).replace('\\','/')
		meta.contextNode = nset('ancestor-or-self::*[1]', \
			self.se.getCheckedPos().node()).firstNode()
		self.spos = GrovePos()		# selection start	
		self.epos = GrovePos()		# selection end
		self.filter = FilterIds()	# source of ids
		self.lastFile = lastFile
		self.mess = {
			'fileAccess': {
				'type': QtGui.QMessageBox.Warning,
				'title': u'Нет доступа',
				'message': u'Файл %s недоступен.'},
			'wrongConrefTarget': {
				'type': QtGui.QMessageBox.Warning,
				'title': u'Неподходящая цель',
				'message': u'В текущем контексте не допускается ссылка conref на элемент <%s>.'}}
		self.state = State(
			('new','edit'), 
			('link','conref'), 
			('local','external'), 
			('text-enable','text-lock'), 
			('insert','wrap'), 
			('use-link','no-link'), 
			('tag-link', 'tag-xref'), 
			('run', 'init'),
			('href-as-attr', 'href-as-text'),
			('href-text-absent', 'href-text-present'))
		# init
		chdir(dirname(self.file))
		targets.setActive(doc, self.file)		# !important
		self.setInitialState()
		
	
	def buildDialog(self):
		''' Sets signal events and icons '''
		# icons
		icoDir = dirname(dirname(dirname(dirname(__file__)))) + '/icons/'
		self.icoLocal = QtGui.QIcon(icoDir + 'item.png')
		self.icoExternal = QtGui.QIcon(icoDir + 'earth.png')
		self.icoBul = QtGui.QIcon(icoDir + 'bullet.png')
		self.icoTopic = QtGui.QIcon(icoDir + 'smpage.png')
		# scope menu
		scopeMenu = QtGui.QMenu(self.tbScope)
		localAction = scopeMenu.addAction(self.icoLocal, u'local')
		externalAction = scopeMenu.addAction(self.icoExternal, u'external')
		self.connect(localAction, QtCore.SIGNAL('triggered()'), self.localEvent)
		self.connect(externalAction, \
			QtCore.SIGNAL('triggered()'), self.externalEvent)
		self.tbScope.setMenu(scopeMenu)
		# files
		self.connect(self.tbFile, QtCore.SIGNAL('clicked()'), self.selectFileEvent)
		self.connect(self.lstFile, \
			QtCore.SIGNAL('currentRowChanged(int)'), self.fileChangeEvent)
		# targets
		self.connect(self.lstTarget, \
			QtCore.SIGNAL('currentRowChanged(int)'), self.targetChangeEvent)
		self.connect(self.leSearch, \
			QtCore.SIGNAL('textChanged(QString)'), self.searchEvent)
		self.connect(self.rbLink, QtCore.SIGNAL('clicked()'), self.linkEvent)
		self.connect(self.rbPopup, QtCore.SIGNAL('clicked()'), self.linkEvent)
		self.connect(self.rbConref, QtCore.SIGNAL('clicked()'), self.conrefEvent)
		self.connect(self.cbHrefText, QtCore.SIGNAL('clicked()'), self.hrefTextEvent)
		
				
	def setInitialState(self):
		''' Sets state and ui elements depending on the context '''
		self.state.set('init')
		self.parentLink = \
			nset('ancestor-or-self::*[contains(@class, " topic/xref ")' + \
			' or contains(@class, " topic/link ")][1]').firstNode()
		# edit conref
		if vof('@conref'):
			self.state.set('edit conref no-link')
			self.initEdit(meta.contextNode)
		# edit any link 
		elif not self.parentLink.isNull():
			self.state.set('edit link')
			self.initEdit(self.parentLink)
		else:
			self.state.set('new')
			self.initNew()
		# fill		
		self.fillFiles()
		self.filter.ids = targets[0].ids()	# filtered list of ids
		self.lstFile.setCurrentRow(0)
		self.fillTargets()
		if self.state.get('edit local'):
			self.lstTarget.setCurrentRow(self.filter[unicode(self.leLink.text())])
		self.setFacility()
		self.leText.setFocus()
		self.state.set('run')
		
		# set initial file if new link inserting
		if self.state.get('new') and self.lastFile:
			for row in range(0, self.lstFile.count()):
				if self.lstFile.item(row).toolTip() == self.lastFile:
					self.lstFile.setCurrentRow(row)
					return
		
	
	def initEdit(self, node):
		''' Prepares for editing ref or conref '''
		if self.state.get('conref'):
			link = vof('@conref', node)
			self.leLink.setText(link)
			self.rbConref.setChecked(True)
		else:
			self.state.set(vof('@scope', node)) # local or external
			
			# href - attribute or element
			if not(nset('href', node).firstNode().isNull()):
				self.cbHrefText.setChecked(True)
				self.state.set('href-as-text href-text-present')
			link = self.getHrefAsText(node)
			self.leLink.setText(link)
			
			# popup
			if vof('@popup', node) == 'yes':
				self.rbPopup.setChecked(True)
			else:
				self.rbLink.setChecked(True)
				
			tag = unicode(node.nodeName())
			self.rbLink.setText(tag)
			self.state.set('tag-' + tag)
			
			# text
			self.leText.setText(self.getText(node))
			# text-enable
			cc = nset('linktext/*', node).size() if self.state.get('tag-link') \
				else nset('*[name() != "href"]', node).size()
			self.state.set('text-enable' if cc == 0 else 'text-lock')
		
		# append pointed file
		if self.state.get('local'):
			file = link.partition('#')[0]
			if file and not targets.append(abspath(file).replace('\\','/')):
				self.message('fileAccess', file)
	
	
	def getHrefAsText(self, node):
		''' Returns element href with keys resolved or returns @href '''
		if self.state.get('href-text-absent'):
			return vof('@href', node)
		else:
			return textWithKeys(nset('href', node).firstNode(), self.file)
			
	
	def getText(self, node):
		''' Returns link text '''
		if vof('@class', node).find(' topic/link ') > 0:
			node = nset('*[contains(@class, " topic/linktext ")]', node).firstNode()
		return '' if node.isNull() else textWithKeys(node, self.file)
		
		
	def initNew(self):
		''' Prepares for adding ref or conref '''
		# check if link avialable
		tag = 'xref' if self.se.canInsertElement('xref')\
			else 'link' if self.se.canInsertElement('link') else ''
		if tag == '':
			self.state.set('conref no-link')	# link inavialable
			self.rbConref.setChecked(True)
		else:
			self.state.set('external link tag-' + tag)	# external by default
			self.rbLink.setText(tag)
			if self.se.getSelection(self.spos, self.epos):
				frag = GroveDocumentFragment()
				self.se.groveEditor().copy(self.spos, self.epos, frag)
				if frag.countChildren() == 1 and frag.firstChild().nodeType() == 3:
					self.state.set('wrap')
					self.leText.setText(\
						unicode(frag.firstChild().asGroveText().data()))

				
	def currentFile(self):
		''' Returns file path on selected file (for outside calls) '''
		return self.lstFile.currentItem().toolTip() \
			if self.lstFile.currentRow() != -1 else None 
		
	
	# Routine
	# ======================================================

	def setFacility(self, states=None):
		''' Sets ui parameters '''
		if states:
			self.state.set(states)
		self.leText.setEnabled(False if self.state.getOr('conref text-lock') else True)
		self.rbLink.setEnabled(False if self.state.get('no-link') else True)
		self.rbPopup.setEnabled(False if self.state.get('no-link') else True)
		self.rbConref.setEnabled(False if self.state.get('edit link') else True)
		self.cbHrefText.setEnabled(False if self.state.get('conref') else True)
		self.leLink.setEnabled(False if self.state.get('href-as-text href-text-present') else True)
		# scope
		if self.state.get('link external'):
			self.tbScope.setIcon(self.icoExternal)
			self.tbScope.setToolTip('scope="external"')
		else:
		 self.tbScope.setIcon(self.icoLocal)
		 self.tbScope.setToolTip('scope="local"')

	
	def fillFiles(self):
		self.lstFile.clear()
		for file, active in targets:
			fileName = basename(file)
			if active:
				li = QtGui.QListWidgetItem(self.icoBul, fileName)
			else:
				li = QtGui.QListWidgetItem(fileName)
			li.setToolTip(file)
			self.lstFile.addItem(li)
	
	
	def fillTargets(self):
		self.lstTarget.clear()
		if self.state.get('conref'):
			self.setConrefTags()	# conref filtering by tag
			
		for id in self.filter:
			topicId, id, tag, text, level = \
				id['topicId'], id['id'], id['tag'], id['text'], id['level'] 
			if not id:		# topic
				li = QtGui.QListWidgetItem(self.icoTopic, u'%s  <%s>' %(text, tag))
				li.setToolTip('#' + topicId)
			else:		# target
				indent = u''.center(4) + u''.center(level*3) 
				li = QtGui.QListWidgetItem(u'%s%s  <%s>'%(indent, id, tag))
				li.setToolTip(text)
			self.lstTarget.addItem(li)
			
	
	def setConrefTags(self):
		''' Sets suitable tags for conref '''
		self.filter.tags = []
		tags = set([id['tag'] for id in self.filter])
		for tag in tags:
			pos = GrovePos(meta.contextNode.parent(), meta.contextNode) \
					if self.state.get('edit conref') else self.se.getCheckedPos()
			if self.se.canInsertElement(tag, '', pos):
				self.filter.tags.append(tag)
		self.filter.tags.append('')	# empty string means no-tag
		
	
	def message(self, key, *args):
		''' Issues message box '''
		QtGui.QMessageBox(self.mess[key]['type'], self.mess[key]['title'], \
				self.mess[key]['message']%args, QtGui.QMessageBox.Ok, self).exec_()
		
	
	# Events
	# ======================================================
	
	def selectFileEvent(self):
		''' Opens file selection dialog and appends file '''
		file = QtGui.QFileDialog.getOpenFileName(self, u'Выберите ditamap', \
				getattr(self, 'idir', dirname(self.file)), 'Dita file (*.xml *.dita *.ditamap)')
		if file:
			targets.append(unicode(file).replace('\\','/'))
			self.fillFiles()
			self.lstFile.setCurrentRow(0)
			self.idir = dirname(unicode(file))
			self.fileChangeEvent(0)
			self.setFacility('local')

			
	def fileChangeEvent(self, row):
		''' Sets link on file when selected in file list.
				Also tests if file acessible '''
		item = self.lstFile.currentItem()
		if not item or self.state.get('init'):
			return
		self.state.set('init')
		ft = targets[row] 
		if ft.acessible():
			self.filter.ids = ft.ids()
			self.leLink.setText('' if ft.active() else \
				relpath(unicode(item.toolTip())).replace('\\','/') )
		else:
			self.message('fileAccess', unicode(item.toolTip()))
			self.fillFiles()	# removes inacessible files
			self.lstFile.setCurrentRow(0)
			self.filter.ids = targets[0].ids()	# renew ids in filter
		self.fillTargets()
		self.setFacility('local')
		self.state.set('run')
	
	
	def searchEvent(self, pattern):
		self.state.set('init')
		self.filter.pattern = unicode(pattern)
		self.fillTargets()
		self.state.set('run')
	
	
	def targetChangeEvent(self, row):
		item = self.lstFile.currentItem()
		if not item or self.state.get('init'):
			return
		self.setFacility('local')
		# link
		ft = targets[self.lstFile.currentRow()]
		vector = '' if ft.active() else \
			relpath(unicode(item.toolTip())).replace('\\','/')
		self.leLink.setText(vector + self.filter.id(row))
	
	
	def linkEvent(self):
		if self.state.get('link'):
			return
		self.filter.tags = []
		self.setFacility('link')
		self.fillTargets()
		
		
	def conrefEvent(self):
		self.setFacility('conref')
		self.fillTargets()
		self.leLink.setText(\
			relpath(unicode(self.lstFile.currentItem().toolTip())).replace('\\','/'))
			
	
	def localEvent(self):
		self.setFacility('local')
	
	
	def externalEvent(self):
		self.setFacility('external')
		
		
	def resizeEvent(self, event):
		global geometry
		geometry = self.geometry()
		
		
	def moveEvent(self, event):
		global geometry
		geometry = self.geometry()
	
	
	def hrefTextEvent(self):
		if self.cbHrefText.isChecked():
			self.setFacility('href-as-text')
		else:
			self.setFacility('href-as-attr')
	
	
	def accept(self):
		''' Builds result dictionary and hides dialog '''
		# check target for conref (may be topic)
		row = self.lstTarget.currentRow()
		if self.state.get('conref') and \
				not self.filter.tag(row) in self.filter.tags:
			self.message('wrongConrefTarget', self.filter.tag(row))
			return
		res = {}
		res['action'] = \
			'wrap' if self.state.get('new link wrap') else \
			'edit' if self.state.get('edit') else \
			'new'
		res['attr'] = \
			'conref' if self.state.get('conref') else \
			'href'
		res['tag'] = \
			'link' if self.state.get('link tag-link') else \
			'xref' if self.state.get('link tag-xref') else \
			self.filter.tag(row) if row >= 0 else ''
		res['scope'] = \
			'external' if self.state.get('external') else \
			'local'
		res['text'] = unicode(self.leText.text()).strip()
		res['text-enable'] = self.state.get('text-enable')
		res['link'] = unicode(self.leLink.text()).strip()
		res['spos'] = \
			self.spos if self.state.get('wrap') else \
			GrovePos(meta.contextNode) if self.state.get('edit conref') else \
			GrovePos(self.parentLink) if self.state.get('edit link') else \
			self.se.getCheckedPos()
		res['epos'] = self.epos
		res['popup'] = \
			'yes' if self.state.get('link') and self.rbPopup.isChecked() else 'no'
		res['href-as-text'] = True if self.state.get('href-as-text link') else False
		self.result = res
		
		meta.contextNode = None
		self.setResult(1)
		self.hide()
	
		
	def reject(self):
		meta.contextNode = None
		self.setResult(0)
		self.hide()
