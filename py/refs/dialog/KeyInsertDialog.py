# coding=UTF-8

# Teux plugin for Serna, 2012

from os.path import dirname, join
from PyQt4 import QtGui, QtCore, uic
from PyQt4 import Qt 


class KeyInsertDialog(QtGui.QDialog):
	
	def __init__(self):
		super(KeyInsertDialog, self).__init__()
		uiPath = join(dirname(__file__), 'ui/keyInsert.ui')
		uic.loadUi(uiPath, self)
		self._keys = None
		self.setModal(True)
		self.buildDialog()
		
		
	def buildDialog(self):
		self.connect(self.lstKey, QtCore.SIGNAL('itemClicked(QListWidgetItem*)'), self.clickKey)
		self.connect(self.lstKey, QtCore.SIGNAL('currentRowChanged(int)'), self.currentRowChanged)
		self.lstTag.addItem('ph')
		self.lstTag.addItem('parmname')
		self.lstTag.addItem('uicontrol')
		self.lstTag.setCurrentRow(0)
		
	
	def clickKey(self, keyItem):
		if keyItem:
			self.teVal.setText(self._keys[unicode(keyItem.text())])
		
	
	def currentRowChanged(self, row):
		self.clickKey(self.lstKey.item(row))
		
		
	def fillData(self):
		self.lstKey.clear()
		for k in self._keys:
			self.lstKey.addItem(k)
		self.lstKey.sortItems()
		# set previous selected key
		row = self._keys.selected()
		if row >= 0:
			self.lstKey.setCurrentRow(row)
		elif self.lstKey.count() > 0:
			self.lstKey.setCurrentRow(0)
		self.lstKey.setFocus()
			
		
	def key(self):
		''' Returns selected key '''
		if self.lstKey.currentItem() == None:
			return ''
		else:
			return unicode(self.lstKey.currentItem().text())
				
	
	def tag(self):
		''' Returns selected tag '''
		if self.lstTag.currentItem() == None:
			return 'ph'
		else:
			return unicode(self.lstTag.currentItem().text())
			
		
	def setKeys(self, keys):
		''' Fills avialable keys '''
		if self._keys != keys:
			self._keys = keys
		self.fillData()
			
	
	def accept(self):
		''' Stores selected key '''
		if self.lstKey.currentItem() != None:
			self._keys.selected(self.lstKey.currentRow())
			self.setResult(1)
		else:
			self.setResult(0)
		self.hide()
	

keyDialog = KeyInsertDialog()